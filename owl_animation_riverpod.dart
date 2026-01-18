import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Opacity {
  opaque(raw: 1.0),
  transparent(raw: 0.0);

  const Opacity({required this.raw});

  final double raw;
}

class FadeNotifier extends Notifier<Opacity> {
  @override
  Opacity build() => .transparent;

  void fadeIn() => state = .opaque;

  void fadeOut() => state = .transparent;
}

class LabelNotifier extends Notifier<String> {
  @override
  String build() => 'Show Details';

  void set(String label) => state = label;
}

final fadeProvider = NotifierProvider<FadeNotifier, Opacity>(() {
  return FadeNotifier();
});

final labelProvider = NotifierProvider<LabelNotifier, String>(() {
  return LabelNotifier();
});

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: FadeInDemo())),
    );
  }
}

const owlUrl =
    'https://raw.githubusercontent.com/flutter/website/master/src/images/owl.jpg';

class FadeInDemo extends ConsumerWidget {
  const FadeInDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opacity = ref.watch(fadeProvider);
    final label = ref.watch(labelProvider);

    return Column(
      children: <Widget>[
        Image.network(owlUrl),
        TextButton(
          onPressed: opacity == Opacity.transparent
              ? ref.read(fadeProvider.notifier).fadeIn
              : ref.read(fadeProvider.notifier).fadeOut,
          child: Text(label, style: const TextStyle(color: Colors.blueAccent)),
        ),
        AnimatedOpacity(
          duration: const Duration(seconds: 2),
          opacity: opacity.raw,
          onEnd: () => ref
              .read(labelProvider.notifier)
              .set(
                opacity == Opacity.transparent
                    ? 'Show Details'
                    : 'Hide Details',
              ),
          child: Column(
            children: const [
              Text('Type: Owl'),
              Text('Age: 39'),
              Text('Employment: None'),
            ],
          ),
        ),
      ],
    );
  }
}
