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
  Future<Image>? imageRequest;

  Future<Image> textToImage({
    required TextSpan text,
    required BuildContext context,
  }) async {
    final mediaQueryData = MediaQuery.of(context);
    final devicePixelRatio = mediaQueryData.devicePixelRatio;
    final textScaleFactor = mediaQueryData.textScaleFactor;

    ui.PictureRecorder recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final painter = TextPainter(
      text: text,
      textDirection: Directionality.of(context),
      textScaleFactor: devicePixelRatio * textScaleFactor,
    );
    painter.layout();
    painter.paint(canvas, Offset.zero);
    final ui.Image uiImage = await recorder.endRecording().toImage(
          painter.width.ceil(),
          painter.height.ceil(),
        );
    final data = await uiImage.toByteData(format: ui.ImageByteFormat.png);
    return Image.memory(data!.buffer.asUint8List(),
        scale: devicePixelRatio,
        width: uiImage.width / devicePixelRatio,
        height: uiImage.height / devicePixelRatio);
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
    imageRequest ??= textToImage(text: textSpan, context: context);
    return FutureBuilder(
      future: imageRequest,
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final image = snapshot.data;
          if (image != null) {
            return Stack(
              children: [
                Container(
                  width: image.width,
                  height: image.height,
                  color: Colors.green,
                ),
                image,
              ],
            );
          }
        }
        return Container();
      }),
    );
  }
}
