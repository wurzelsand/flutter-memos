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

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const textSpan = TextSpan(
      text: 'pixel',
      style: TextStyle(
        color: Colors.red,
        fontSize: 300,
        fontStyle: FontStyle.italic,
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: FutureBuilder(
        future: getTextBounds(text: textSpan, context: context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final bounds = snapshot.data;
            if (bounds != null) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: bounds.top,
                    left: bounds.left,
                    child: Container(
                      width: bounds.width,
                      height: bounds.height,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.black,
                            strokeAlign: StrokeAlign.outside),
                      ),
                    ),
                  ),
                  const Text.rich(textSpan),
                ],
              );
            }
          }
          return Container();
        },
      ),
    );
  }
}

Future<Rect> getTextBounds({
  required TextSpan text,
  required BuildContext context,
  ui.TextDirection textDirection = ui.TextDirection.ltr,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  final textScaleFactor = MediaQuery.of(context).textScaleFactor;
  final painter = TextPainter(
    text: text,
    textAlign: ui.TextAlign.center,
    textScaleFactor: textScaleFactor,
    textDirection: textDirection,
  );
  painter.layout();
  const extend = 1.2; // This 20 percent extra width should be enough
  final extraWidth = (extend * painter.width).toInt();
  final width = painter.width.toInt() + extraWidth;
  final height = painter.height.toInt();
  final shift = extraWidth / 2; // Create extra space to the left
  painter.paint(canvas, ui.Offset(shift, 0));
  final ui.Image image = await recorder.endRecording().toImage(width, height);
  final bounds = await _getImageBounds(image);
  return ui.Rect.fromLTWH(
    bounds.left - shift,
    bounds.top,
    bounds.width,
    bounds.height,
  );
}

Future<ui.Rect> _getImageBounds(ui.Image image) async {
  final data = await image.toByteData();
  if (data != null) {
    final list = data.buffer.asUint32List();
    return _getBufferBounds(list, image.width, image.height);
  }
  return Rect.zero;
}

// https://pub.dev/documentation/image/latest/image/findTrim.html
ui.Rect _getBufferBounds(
  List<int> list,
  int width,
  int height,
) {
  int getPixel(int x, int y) => list[y * width + x];

  var left = width;
  var right = 0;
  int? top;
  var bottom = 0;

  for (int y = 0; y < height; ++y) {
    var first = true;
    for (int x = 0; x < width; ++x) {
      // 8 bits alpha chanel threshold (0-254):
      const threshold = 64;
      if (getPixel(x, y) >>> 24 > threshold) {
        if (x < left) {
          left = x;
        }

        if (x > right) {
          right = x;
        }

        top ??= y;

        bottom = y;

        if (first) {
          first = false;
          x = right;
        }
      }
    }
  }

  if (top == null) {
    return ui.Rect.fromLTWH(
      0,
      0,
      width.toDouble(),
      height.toDouble(),
    );
  }

  return ui.Rect.fromLTRB(
    left.toDouble(),
    top.toDouble(),
    right.toDouble() + 1,
    bottom.toDouble() + 1,
  );
}
