import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

class RepositoriesPage extends StatefulWidget {
  const RepositoriesPage({super.key});

  @override
  State<RepositoriesPage> createState() => _RepositoriesPageState();
}

class _RepositoriesPageState extends State<RepositoriesPage> {
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return MacosScaffold(
        toolBar: ToolBar(
          title: const Text('Repositories'),
          leading: MacosTooltip(
              message: 'Toggle Sidebar',
              child: MacosIconButton(
                icon: MacosIcon(
                  CupertinoIcons.sidebar_left,
                  color: MacosTheme.brightnessOf(context).resolve(
                    const Color.fromRGBO(0, 0, 0, 0.5),
                    const Color.fromRGBO(255, 255, 255, 0.5),
                  ),
                  size: 20.0,
                ),
                boxConstraints: const BoxConstraints(
                  minHeight: 20,
                  minWidth: 20,
                  maxWidth: 48,
                  maxHeight: 38,
                ),
                onPressed: () => MacosWindowScope.of(context).toggleSidebar(),
              )),
          actions: [
            ToolBarPullDownButton(
              label: 'New',
              icon: CupertinoIcons.add,
              items: [
                MacosPulldownMenuItem(
                  label: 'New Repository',
                  title: const Text("New Repository"),
                  onTap: () => debugPrint("Creating new repository"),
                ),
                MacosPulldownMenuItem(
                  label: 'New Gist',
                  title: const Text("New Gist"),
                  onTap: () => debugPrint("Creating new gist"),
                ),
                MacosPulldownMenuItem(
                  label: 'New Organization',
                  title: const Text("New Organization"),
                  onTap: () => debugPrint("Creating new organization"),
                ),
              ],
            )
          ],
        ),
        children: [
          ContentArea(builder: (context, scrollController) {
            return const RepositoriesList();
          }),
        ],
      );
    });
  }
}

class RepositoriesList extends StatefulWidget {
  const RepositoriesList({super.key});

  @override
  State<RepositoriesList> createState() => _RepositoriesListState();
}

class _RepositoriesListState extends State<RepositoriesList> {
  int _selectedIndex = 0;
  var _currentContent = "This is some sample content";

  @override
  Widget build(BuildContext context) {
    final isDarkMode = MacosTheme.brightnessOf(context) == Brightness.dark;
    return Row(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            border: isDarkMode
                ? const Border(
                    right: BorderSide(color: Color.fromRGBO(56, 56, 56, 1)))
                : const Border(
                    right: BorderSide(color: Color.fromRGBO(224, 224, 224, 1))),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              width: 300,
              child: ListView.builder(
                itemCount: 15,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                        _currentContent = "This is repository ${index + 1}";
                      });
                    },
                    child: Card(
                      elevation: 0,
                      color: _selectedIndex == index
                          ? const Color.fromRGBO(52, 120, 246, 1)
                          : Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                            width: 300,
                            child: MacosListTile(
                              leading: Icon(
                                CupertinoIcons.folder,
                                color: _selectedIndex == index
                                    ? Colors.white
                                    : Colors.blue,
                              ),
                              title: Text("Repository ${index + 1}",
                                  style: isDarkMode || _selectedIndex == index
                                      ? const TextStyle(color: Colors.white)
                                      : const TextStyle(color: Colors.black)),
                              subtitle: Text(
                                  "Longer description of repository $index. Adding more and more text to see how the multiline text will look.",
                                  style: isDarkMode || _selectedIndex == index
                                      ? const TextStyle(color: Colors.white70)
                                      : const TextStyle(color: Colors.black54)),
                            )),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: ScrollController(),
            child: Column(
              children: <Widget>[
                Text(_currentContent),
              ],
            ),
          ),
        )
      ],
    );
  }
}
