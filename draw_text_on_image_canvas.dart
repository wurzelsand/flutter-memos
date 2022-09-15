import 'package:flutter/material.dart';
import 'dart:ui' as ui;

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
  Future<ui.Image>? imageRequest;

  Future<ui.Image> textToImage({
    required TextSpan text,
    required double upscale,
  }) async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final painter = TextPainter(
      text: text,
      textDirection: TextDirection.ltr,
      textScaleFactor: upscale,
    );
    painter.layout();
    painter.paint(canvas, Offset.zero);
    final ui.Image image = await recorder
        .endRecording()
        .toImage(painter.width.floor(), painter.height.floor());
    return image;
  }

  @override
  Widget build(BuildContext context) {
    const textSpan = TextSpan(
      text: 'Hello',
      style: TextStyle(
        color: Colors.white,
        fontSize: 200,
      ),
    );
    final upscale = MediaQuery.of(context).devicePixelRatio;
    imageRequest ??= textToImage(text: textSpan, upscale: upscale);
    return FutureBuilder(
      future: imageRequest,
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final image = snapshot.data;
          if (image != null) {
            final width = image.width / upscale;
            final height = image.height / upscale;
            return Stack(
              children: [
                Container(
                  width: width,
                  height: height,
                  color: Colors.green,
                ),
                SizedBox(
                  width: width,
                  height: height,
                  child: RawImage(
                    image: image,
                  ),
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
