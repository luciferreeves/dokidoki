import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart' show rootBundle;

const githubScopes = [
  'repo',
  'admin:repo_hook',
  'admin:org',
  'admin:public_key',
  'admin:org_hook',
  'gist',
  'notifications',
  'user',
  'project',
  'delete_repo',
  'admin:gpg_key',
  'workflow',
  'write:discussion',
  'write:packages',
  'read:packages',
  'delete:packages',
  'codespace'
];

final authorizationEndpoint =
    Uri.parse('https://github.com/login/oauth/authorize');
final tokenEndpoint = Uri.parse('https://github.com/login/oauth/access_token');

class _JSONAcceptingHttpClient extends http.BaseClient {
  final _httpClient = http.Client();
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Accept'] = 'application/json';
    return _httpClient.send(request);
  }
}

// If there is no token, hide the main window and open the browser to get the token
Future<oauth2.Client> _getOAuth2Client(
    Uri redirectUri, HttpServer redirectServer) async {
  await dotenv.load(fileName: ".env");
  var grant = oauth2.AuthorizationCodeGrant(
    dotenv.env['GITHUB_CLIENT_ID']!,
    authorizationEndpoint,
    tokenEndpoint,
    secret: dotenv.env['GITHUB_CLIENT_SECRET']!,
    httpClient: _JSONAcceptingHttpClient(),
  );
  var authorizationUrl =
      grant.getAuthorizationUrl(redirectUri, scopes: githubScopes);

  await _redirect(authorizationUrl);
  var responseQueryParameters = await _listen(redirectServer);
  try {
    var client =
        await grant.handleAuthorizationResponse(responseQueryParameters);
    return client;
  } catch (e) {
    return oauth2.Client(oauth2.Credentials('null'));
  }
}

Future<void> _redirect(Uri authorizationUrl) async {
  if (await canLaunchUrl(authorizationUrl)) {
    await launchUrl(authorizationUrl);
  } else {
    throw 'Could not launch ${authorizationUrl.toString()}.';
  }
}

Future<Map<String, String>> _listen(redirectServer) async {
  var request = await redirectServer.first;
  var params = request.uri.queryParameters;
  request.response.statusCode = 200;
  request.response.headers.set('content-type', 'text/html');
  var error = params['error'];
  if (error != null) {
    // request.response.write('Error: ${params.error}');
    String failedHtml = await rootBundle.loadString('html/failed.html');
    request.response.write(failedHtml);
  } else {
    // request.response.write('Success! You can close this window now.');
    String successHtml = await rootBundle.loadString('html/success.html');
    request.response.write(successHtml);
  }
  await request.response.close();
  await redirectServer.close();
  redirectServer = null;
  return params;
}

class GithubAuth {
  static Future<oauth2.Client> getOAuth2Client() async {
    var redirectServer = await HttpServer.bind('localhost', 51691);
    var authenticatedHttpClient = await _getOAuth2Client(
        Uri.parse('http://localhost:${redirectServer.port}'), redirectServer);
    return authenticatedHttpClient;
  }
}
