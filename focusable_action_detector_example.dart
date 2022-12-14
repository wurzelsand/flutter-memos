// from: https://api.flutter.dev/flutter/widgets/FocusableActionDetector-class.html

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FocusableActionDetector Example'),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                  onPressed: () => debugPrint('TextButton pressed'),
                  child: const Text('Press Me')),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FadButton(
                  onPressed: () => debugPrint('FadButton toggled'),
                  child: const Text('And Me')),
            ),
          ],
        ),
      ),
    );
  }
}

class FadButton extends StatefulWidget {
  const FadButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  final VoidCallback onPressed;
  final Widget child;

  @override
  State<FadButton> createState() => _FadButtonState();
}

class _FadButtonState extends State<FadButton> {
  bool _focused = false;
  bool _hovering = false;
  bool _on = false;

  late final Map<Type, Action<Intent>> _actionMap;
  final _shortcutMap = const <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.keyX): ActivateIntent(),
  };

  @override
  void initState() {
    super.initState();
    _actionMap = <Type, Action<Intent>>{
      ActivateIntent: CallbackAction<ActivateIntent>(
        onInvoke: (ActivateIntent intent) => _toggleState(),
      ),
    };
  }

  Color get color {
    Color baseColor = Colors.lightBlue;
    if (_focused) {
      baseColor = Color.alphaBlend(Colors.black.withOpacity(0.25), baseColor);
    }
    if (_hovering) {
      baseColor = Color.alphaBlend(Colors.black.withOpacity(0.1), baseColor);
    }
    return baseColor;
  }

  void _toggleState() {
    setState(() {
      _on = !_on;
    });
    widget.onPressed();
  }

  void _handleFocusHighlight(bool value) {
    setState(() {
      _focused = value;
    });
  }

  void _handleHoverHighlight(bool value) {
    setState(() {
      _hovering = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      actions: _actionMap,
      shortcuts: _shortcutMap,
      onShowFocusHighlight: _handleFocusHighlight,
      onShowHoverHighlight: _handleHoverHighlight,
      child: Builder(
        builder: (context) {
          return GestureDetector(
            onTap: Actions.handler(context, const ActivateIntent()),
            child: Center(
              child: Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    color: color,
                    child: widget.child,
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    margin: const EdgeInsets.all(10.0),
                    color: _on ? Colors.red : Colors.transparent,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
