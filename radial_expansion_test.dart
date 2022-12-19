import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with SingleTickerProviderStateMixin {
  late final _controller =
      AnimationController(duration: const Duration(seconds: 2), vsync: this);

  void run() {
    switch (_controller.status) {
      case AnimationStatus.forward:
      case AnimationStatus.completed:
        _controller.reverse();
        break;
      default:
        _controller.forward();
    }
  }

  static const _maxRadius = 150.0;
  static const _minRadius = 50.0;

  static final _widthTween =
      Tween<double>(begin: 2 * _minRadius, end: 2 * _maxRadius);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GestureDetector(
        onTap: run,
        child: Scaffold(
          body: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return SizedBox(
                  width: _widthTween.evaluate(_controller),
                  height: _widthTween.evaluate(_controller),
                  child: RadialExpansion(
                    maxRadius: _maxRadius,
                    minRadius: _minRadius,
                    child: Container(color: Colors.red),
                  ),
                );
              }),
        ),
      ),
    );
  }
}

// RadialExpansion will clip its `child` depending on how it is constrained. For
// example, if `RadialExpansion` is constrained by a `SizedBox` whose dimensions
// are small, the `child` will be circularly clipped. If its dimensions are
// large, the `child` will appear as a square. If its dimensions are in between,
// the clipping results in a combination of square and circle.
class RadialExpansion extends StatelessWidget {
  RadialExpansion({
    super.key,
    required this.minRadius,
    required this.maxRadius,
    this.child,
  }) : clipTween = Tween<double>(
            begin: 2 * minRadius, end: 2 * (maxRadius / math.sqrt2));

  final double minRadius;
  final double maxRadius;
  final Tween<double> clipTween;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    // The ClipOval matches the RadialExpansion widget's bounds,
    // which change per the Hero's bounds as the Hero flies to
    // the new route, while the ClipRect's bounds depend on the constraints of
    // the LayoutBuilder: the larger the allowed extents, the larger ClipRect
    // will be.
    return LayoutBuilder(
      builder: (context, constraints) {
        final double t =
            (constraints.maxWidth / 2 - minRadius) / (maxRadius - minRadius);
        final clipRectExtent = clipTween.transform(t); // #3
        return ClipOval(
          child: Center(
            child: SizedBox(
              width: clipRectExtent,
              height: clipRectExtent,
              child: ClipRect(
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
