import 'dart:ui' as ui;

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: MyWidget(),
      ),
    );
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  Future<ui.Image> textToImage(String? text, TextStyle? style) async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final textSpan = TextSpan(
      text: text,
      style: style,
    );
    final painter =
        TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    painter.layout();
    painter.paint(canvas, Offset.zero);
    final ui.Image image = await recorder
        .endRecording()
        .toImage(painter.width.floor(), painter.height.floor());
    return image;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: textToImage('Hello', const TextStyle(fontSize: 200)),
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final ui.Image? image = snapshot.data;
          if (image != null) {
            return Stack(
              children: [
                Container(
                    width: image.width.toDouble(),
                    height: image.height.toDouble(),
                    color: Colors.green),
                RawImage(
                  image: image,
                ),
              ],
            );
          }
        }
        return Container();
      }),
    );
  }
}
