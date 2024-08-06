import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainWidget(),
    );
  }
}

class MainWidget extends StatefulWidget {
  const MainWidget({super.key});

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  final _menuController = MenuController();
  bool _menuOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: IgnorePointer(
        ignoring: _menuOpen,
        child: Opacity(
          opacity: _menuOpen ? 0.0 : 1.0,
          child: FloatingActionButton.small(
            onPressed: () {
              if (!_menuController.isOpen) {
                _menuController.open();
              }
            },
            child: MenuAnchor(
              controller: _menuController,
              onOpen: () => setState(() => _menuOpen = true),
              onClose: () => setState(() => _menuOpen = false),
              menuChildren: [
                IconButton(
                  onPressed: _menuController.close,
                  icon: const Icon(Icons.close),
                ),
                MenuItemButton(
                  onPressed: () => _menuController.close,
                  child: const Text('Close'),
                ),
                const MenuItemButton(
                  closeOnActivate: false,
                  child: Text('Do absolutely nothing'),
                ),
                MenuItemButton(
                  closeOnActivate: false,
                  onPressed: () => {},
                  child: const Text('Do nothing'),
                ),
              ],
              child: const Icon(Icons.menu),
            ),
          ),
        ),
      ),
    );
  }
}
