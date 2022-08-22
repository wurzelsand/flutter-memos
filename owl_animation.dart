import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum Opacity {
  opaque(raw: 1.0),
  transparent(raw: 0.0);

  const Opacity({required this.raw});

  final double raw;
}

class FadeLabel {
  const FadeLabel({required this.label, required this.opacity});

  final String label;
  final Opacity opacity;
}

class FadeLabelCubit extends Cubit<FadeLabel> {
  FadeLabelCubit({required FadeLabel fadeLabel}) : super(fadeLabel);

  void fadeIn() =>
      emit(FadeLabel(label: state.label, opacity: Opacity.opaque));

  void fadeOut() =>
      emit(FadeLabel(label: state.label, opacity: Opacity.transparent));

  void setLabel(String label) =>
      emit(FadeLabel(label: label, opacity: state.opacity));
}

const owlUrl =
    'https://raw.githubusercontent.com/flutter/website/master/src/images/owl.jpg';

class FadeInDemo extends StatelessWidget {
  const FadeInDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FadeLabelCubit, FadeLabel>(
      builder: (context, state) {
        return Column(children: <Widget>[
          Image.network(owlUrl),
          TextButton(
              child: Text(
                state.label,
                style: const TextStyle(color: Colors.blueAccent),
              ),
              onPressed: () => state.opacity == Opacity.transparent
                  ? context.read<FadeLabelCubit>().fadeIn()
                  : context.read<FadeLabelCubit>().fadeOut()),
          AnimatedOpacity(
            duration: const Duration(seconds: 2),
            opacity: state.opacity.raw,
            onEnd: () => state.opacity == Opacity.transparent
                ? context.read<FadeLabelCubit>().setLabel('Show Details')
                : context.read<FadeLabelCubit>().setLabel('Hide Details'),
            child: Column(
              children: const [
                Text('Type: Owl'),
                Text('Age: 39'),
                Text('Employment: None'),
              ],
            ),
          )
        ]);
      },
    );
  }
}

class MyPage extends StatelessWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FadeLabelCubit(
          fadeLabel: const FadeLabel(
              label: 'Show Details', opacity: Opacity.transparent)),
      child: const FadeInDemo(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: MyPage(),
        ),
      ),
    );
  }
}

void main() {
  runApp(
    const MyApp(),
  );
}
