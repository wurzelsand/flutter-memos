import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import 'package:flutter/scheduler.dart' show timeDilation;

void main() {
  timeDilation = 4;
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MainWidget());
  }
}

class MainWidget extends StatefulWidget {
  const MainWidget({super.key});

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  int page = 1;
  final int maxPage = 3;
  bool _reverse = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(
        width: 150,
        child: ListView(
          children: [
            if (page < maxPage)
              ListTile(
                leading: const Icon(Icons.navigate_next),
                title: const Text('Next'),
                onTap: nextPage,
              ),
            if (page > 1)
              ListTile(
                leading: const Icon(Icons.navigate_before),
                title: const Text('Back'),
                onTap: previousPage,
              ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('This text will not move. But the one below will:'),
          PageTransitionSwitcher(
            reverse: _reverse,
            transitionBuilder: (child, animation, secondaryAnimation) {
              return SharedAxisTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                transitionType: SharedAxisTransitionType.horizontal,
                child: child,
              );
            },
            child: PageWithLongText(key: ValueKey(page), page: page),
          ),
        ],
      ),
    );
  }

  void nextPage() => setState(() {
        if (page < maxPage) {
          page += 1;
          _reverse = false;
        }
      });

  void previousPage() => setState(() {
        if (page > 1) {
          page -= 1;
          _reverse = true;
        }
      });
}

class PageWithLongText extends StatelessWidget {
  const PageWithLongText({required super.key, required this.page});

  final int page;

  @override
  Widget build(BuildContext context) {
    final text = List<String>.generate(200, (_) => 'Page $page').join(' ');
    return Text(
      maxLines: 20,
      text,
      overflow: TextOverflow.ellipsis,
    );
  }
}
