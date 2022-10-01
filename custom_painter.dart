import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final myPainter = MyPainter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.yellow,
            child: CustomPaint(painter: myPainter),
          ),
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.green
      ..strokeWidth = 4;
    final path = Path();
    path.moveTo(0, size.height / 2);
    path.cubicTo(
      size.width / 2, // control point 1
      0,
      size.width / 2, // control point 2
      size.height,
      size.width, // end point
      size.height / 2,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
