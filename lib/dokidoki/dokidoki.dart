import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';
import 'views/views.dart';
import '../github/profile.dart';
import 'package:github/github.dart';

// DokiDoki is a Github Client for MacOS
class DokiDoki extends StatelessWidget {
  const DokiDoki({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppTheme(),
      builder: (context, _) {
        final appTheme = context.watch<AppTheme>();
        return MacosApp(
          title: 'DokiDoki',
          theme: MacosThemeData.light(),
          darkTheme: MacosThemeData.dark(),
          themeMode: appTheme.mode,
          debugShowCheckedModeBanner: false,
          home: const StartDokiDoki(),
        );
      },
    );
  }
}

class StartDokiDoki extends StatefulWidget {
  const StartDokiDoki({super.key});

  @override
  State<StartDokiDoki> createState() => _StartDokiDokiState();
}

class _StartDokiDokiState extends State<StartDokiDoki> {
  int pageIndex = 0;
  SharedPreferences? prefs;
  String? token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  // Load the token from the shared preferences
  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      this.prefs = prefs;
      token = prefs.getString('token');
    });
  }

  // Get profile from Github
  Future _getProfile(token) async {
    if (token != null) {
      try {
        final github = GithubProfile(token);
        final user = await github.getProfile();
        return user;
      } catch (e) {
        prefs!.remove('token');
        exit(0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getProfile(token),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return MainApp(
            token: token!,
            user: snapshot.data,
            pageIndex: pageIndex,
            onChanged: (page) => setState(() => pageIndex = page),
          );
        } else {
          return const Center(
            child: ProgressCircle(),
          );
        }
      },
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({
    super.key,
    required this.token,
    required this.user,
    required this.pageIndex,
    required this.onChanged,
  });

  final String token;
  final User user;
  final int pageIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    var name = user.name ?? user.login;
    var email = user.email ?? '@${user.login}';
    var avatarUrl = user.avatarUrl ?? '';
    return PlatformMenuBar(
      menus: const [
        PlatformMenu(
          label: 'DokiDoki',
          menus: [
            PlatformProvidedMenuItem(
              type: PlatformProvidedMenuItemType.about,
            ),
            PlatformProvidedMenuItem(
              type: PlatformProvidedMenuItemType.quit,
            ),
          ],
        )
      ],
      child: MacosWindow(
          sidebar: Sidebar(
            minWidth: 200,
            isResizable: false,
            startWidth: 200,
            builder: (context, scrollController) {
              return SidebarItems(
                currentIndex: pageIndex,
                onChanged: onChanged,
                items: const [
                  SidebarItem(label: Text('Repositories')),
                  SidebarItem(label: Text('Pull Requests')),
                  SidebarItem(label: Text('Issues')),
                  SidebarItem(label: Text('Gists')),
                ],
              );
            },
            bottom: MacosListTile(
              leading: avatarUrl.isNotEmpty
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(avatarUrl),
                      maxRadius: 16,
                    )
                  : const MacosIcon(
                      CupertinoIcons.profile_circled,
                      size: 32,
                    ),
              title: Text('$name'),
              subtitle: Text(email),
              onClick: () => showMacosAlertDialog(
                context: context,
                builder: (context) => MacosAlertDialog(
                  appIcon: avatarUrl.isNotEmpty
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(avatarUrl),
                          maxRadius: 32,
                        )
                      : const MacosIcon(
                          CupertinoIcons.profile_circled,
                          size: 64,
                        ),
                  title: const Text(
                    'Not Implemented Yet',
                  ),
                  message: const Text(
                    'This is a placeholder for the user profile page',
                  ),
                  //horizontalActions: false,
                  primaryButton: PushButton(
                    buttonSize: ButtonSize.large,
                    onPressed: Navigator.of(context).pop,
                    child: const Text('Okie!'),
                  ),
                ),
              ),
            ),
          ),
          child: IndexedStack(
            index: pageIndex,
            children: getViews(token),
          )),
    );
  }
}
