import 'dart:math' as math;

import 'package:flutter/material.dart';

enum Direction { left, top, right, bottom }

class HalfButton extends StatelessWidget {
  HalfButton(
    this.size,
    this.direction,
  );
  double size;
  Direction direction;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: HalfCirclePainter(context, direction),
      size: Size(size, size),
    );
  }
}

class HalfCirclePainter extends CustomPainter {
  HalfCirclePainter(
    this.context,
    this.direction,
  );
  BuildContext context;
  Direction direction;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawArc(
        Rect.fromLTWH(
          direction == Direction.right
              ? size.width / 2
              : direction == Direction.left
                  ? -size.width / 2
                  : 0,
          direction == Direction.bottom
              ? size.width / -2
              : direction == Direction.top
                  ? size.width / 2
                  : 0,
          size.width,
          size.height,
        ),
        direction == Direction.right
            ? math.pi / 2
            : direction == Direction.left
                ? math.pi * 1.5
                : direction == Direction.bottom
                    ? 0
                    : math.pi,
        math.pi,
        true,
        Paint()..color = Colors.blue.withOpacity(0.2));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
