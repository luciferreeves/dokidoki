import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';

import 'theme.dart';

void main() {
  runApp(const DokiDoki());
}

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

  @override
  Widget build(BuildContext context) {
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
            top: const MacosSearchField(
              placeholder: 'Search Repositories',
            ),
            minWidth: 200,
            builder: (context, scrollController) {
              return SidebarItems(
                currentIndex: pageIndex,
                onChanged: (page) => setState(() => pageIndex = page),
                items: const [
                  SidebarItem(label: Text('Repositories')),
                  SidebarItem(label: Text('Pull Requests')),
                  SidebarItem(label: Text('Issues')),
                  SidebarItem(label: Text('Gists')),
                ],
              );
            },
          ),
          child: IndexedStack(
            index: pageIndex,
            children: const [
              Center(child: Text('Repositories')),
            ],
          )),
    );
  }
}
