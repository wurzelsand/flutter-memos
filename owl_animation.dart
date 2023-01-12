import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(
    const MyApp(),
  );
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

class MyPage extends StatelessWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<FadeCubit>(create: (_) => FadeCubit(Opacity.transparent)),
        BlocProvider<LabelCubit>(create: (_) => LabelCubit('Show Details')),
      ],
      child: const FadeInDemo(),
    );
  }
}

const owlUrl =
    'https://raw.githubusercontent.com/flutter/website/master/src/images/owl.jpg';

class FadeInDemo extends StatelessWidget {
  const FadeInDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FadeCubit, Opacity>(
      builder: (_, opacity) {
        return BlocBuilder<LabelCubit, String>(
          builder: (_, label) {
            return Column(children: <Widget>[
              Image.network(owlUrl),
              TextButton(
                onPressed: opacity == Opacity.transparent
                    ? context.read<FadeCubit>().fadeIn
                    : context.read<FadeCubit>().fadeOut,
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.blueAccent),
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(seconds: 2),
                opacity: opacity.raw,
                onEnd: () => context.read<LabelCubit>().set(
                    opacity == Opacity.transparent
                        ? 'Show Details'
                        : 'Hide Details'),
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
      },
    );
  }
}

enum Opacity {
  opaque(raw: 1.0),
  transparent(raw: 0.0);

  const Opacity({required this.raw});

  final double raw;
}

class FadeCubit extends Cubit<Opacity> {
  FadeCubit(Opacity opacity) : super(opacity);

  void fadeIn() => emit(Opacity.opaque);

  void fadeOut() => emit(Opacity.transparent);
}

class LabelCubit extends Cubit<String> {
  LabelCubit(String initial) : super(initial);

  void set(String label) => emit(label);
}
