import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final shortcuts = <LogicalKeySet, Intent>{
    LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyT):
        const ToggleIntent(),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Shortcuts(
        shortcuts: shortcuts,
        child: Column(children: const [
          ColorToggler(),
          SizedBox(height: 8),
          WeightToggler()
        ]),
      ),
    );
  }
}

class ColorToggler extends StatefulWidget {
  const ColorToggler({super.key});

  @override
  State<ColorToggler> createState() => _ColorTogglerState();
}

class _ColorTogglerState extends State<ColorToggler> {
  var color = Colors.white;

  late final actions = <Type, Action<Intent>>{
    ToggleIntent: ToggleAction(toggleColor),
  };

  void toggleColor() {
    setState(() {
      color = color == Colors.white ? Colors.greenAccent : Colors.white;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: actions,
      child: Builder(
        builder: (context) {
          return ElevatedButton(
            onPressed: Actions.handler(context, const ToggleIntent()),
            child: Text(
              'toggle',
              style: TextStyle(fontWeight: FontWeight.normal, color: color),
            ),
          );
        },
      ),
    );
  }
}

class WeightToggler extends StatefulWidget {
  const WeightToggler({super.key});

  @override
  State<WeightToggler> createState() => _WeightTogglerState();
}

class _WeightTogglerState extends State<WeightToggler> {
  var fontWeight = FontWeight.normal;

  late final actions = <Type, Action<Intent>>{
    ToggleIntent: ToggleAction(toggleFontWeight),
  };

  void toggleFontWeight() {
    setState(() {
      fontWeight =
          fontWeight == FontWeight.normal ? FontWeight.bold : FontWeight.normal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: actions,
      child: Builder(
        builder: (context) {
          return ElevatedButton(
            onPressed: Actions.handler(context, const ToggleIntent()),
            child: Text(
              'toggle',
              style: TextStyle(fontWeight: fontWeight, color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}

class ToggleIntent extends Intent {
  const ToggleIntent();
}

class ToggleAction extends Action<ToggleIntent> {
  ToggleAction(this.toggleCallback);

  final VoidCallback toggleCallback;

  @override
  void invoke(ToggleIntent intent) => toggleCallback();
}
