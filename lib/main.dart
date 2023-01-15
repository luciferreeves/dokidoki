import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:window_manager/window_manager.dart';
import 'dokidoki.dart';
import 'github/auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token == null) {
    var client = await GithubAuth.getOAuth2Client();
    if (client.credentials.accessToken != 'null') {
      prefs.setString('token', client.credentials.accessToken);
    } else {
      exit(0);
    }
  }
  runApp(const DokiDoki());
}
