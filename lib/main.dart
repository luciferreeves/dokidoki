import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'dokidoki/dokidoki.dart';
import 'github/auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    titleBarStyle: TitleBarStyle.hidden,
    minimumSize: Size(800, 600),
  );
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  windowManager.waitUntilReadyToShow(windowOptions);
  if (token == null) {
    var client = await GithubAuth.getOAuth2Client();
    if (client.credentials.accessToken != 'null') {
      prefs.setString('token', client.credentials.accessToken);
    } else {
      exit(0);
    }
  }
  windowManager.show();
  runApp(const DokiDoki());
}
