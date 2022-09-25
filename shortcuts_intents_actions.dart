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
        child: Column(children: [
          ColorToggler(),
          const SizedBox(height: 8),
          WeightToggler()
        ]),
      ),
    );
  }
}

class ColorToggler extends StatelessWidget {
  ColorToggler({super.key});

  final model = ColorToggleModel();

  late final actions = <Type, Action<Intent>>{
    ToggleIntent: ColorToggleAction(model),
  };

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: actions,
      child: Builder(
        builder: (context) {
          return ElevatedButton(
            onPressed: Actions.handler(context, const ToggleIntent()),
            child: AnimatedBuilder(
              animation: model.color,
              builder: (context, child) => Text(
                'toggle',
                style: TextStyle(
                    fontWeight: FontWeight.normal, color: model.color.value),
              ),
            ),
          );
        },
      ),
    );
  }
}

class WeightToggler extends StatelessWidget {
  WeightToggler({super.key});

  final model = WeightToggleModel();

  late final actions = <Type, Action<Intent>>{
    ToggleIntent: WeightToggleAction(model),
  };

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: actions,
      child: Builder(
        builder: (context) {
          return ElevatedButton(
            onPressed: Actions.handler(context, const ToggleIntent()),
            child: AnimatedBuilder(
              animation: model.weight,
              builder: (context, child) => Text(
                'toggle',
                style: TextStyle(
                    fontWeight: model.weight.value, color: Colors.white),
              ),
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

class ColorToggleAction extends Action<ToggleIntent> {
  ColorToggleAction(this.model);

  final ColorToggleModel model;

  @override
  void invoke(ToggleIntent intent) {
    model.color.value =
        (model.color.value == Colors.white) ? Colors.greenAccent : Colors.white;
  }
}

class ColorToggleModel {
  var color = ValueNotifier<Color>(Colors.white);
}

class WeightToggleAction extends Action<ToggleIntent> {
  WeightToggleAction(this.model);

  final WeightToggleModel model;

  @override
  void invoke(ToggleIntent intent) {
    model.weight.value = (model.weight.value == FontWeight.normal)
        ? FontWeight.bold
        : FontWeight.normal;
  }
}

class WeightToggleModel {
  var weight = ValueNotifier<FontWeight>(FontWeight.normal);
}
