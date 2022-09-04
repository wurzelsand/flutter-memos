// https://stackoverflow.com/questions/46589633/how-to-draw-on-a-custompaint-widget-at-position-of-the-pointer-down-event
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final _paintKey = GlobalKey();
  Offset? _offset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CustomPaint example'),
      ),
      body: Listener(
        onPointerDown: (PointerDownEvent event) {
          RenderBox referenceBox =
              _paintKey.currentContext?.findRenderObject() as RenderBox;
          Offset offset = referenceBox.globalToLocal(event.position);
          setState(() {
            _offset = offset;
          });
        },
        child: CustomPaint(
          key: _paintKey,
          painter: MyCustomPainter(_offset),
          child: ConstrainedBox(
            constraints: const BoxConstraints.expand(),
          ),
        ),
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  MyCustomPainter(this._offset);

  final Offset? _offset;

  @override
  void paint(Canvas canvas, Size size) {
    if (_offset != null) {
      canvas.drawCircle(_offset!, 10.0, Paint()..color = Colors.blue);
    }
  }

  @override
  bool shouldRepaint(MyCustomPainter oldDelegate) =>
      oldDelegate._offset != _offset;
}
