import 'package:flutter/material.dart';
import 'dart:math';

class ArmorStatTuningIconWidget extends StatelessWidget {
  final Color color;
  const ArmorStatTuningIconWidget({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: AspectRatio(
      aspectRatio: 1.1,
      child: CustomPaint(
        painter: _ArmorStatTuningIconPainter(color),
        size: Size.infinite,
      ),
      ),
    );
  }
}

class _ArmorStatTuningIconPainter extends CustomPainter {
  final Color color;
  _ArmorStatTuningIconPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final lineWidth = size.height / 7;
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), linePaint);

    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final arrowPath = getArrowPath(size, lineWidth);
    canvas.drawPath(arrowPath, arrowPaint);
    // draw again reversed from bottom right corner
    canvas.save();
    canvas.translate(size.width, size.height);
    canvas.scale(-1, -1);
    canvas.drawPath(arrowPath, arrowPaint);
    canvas.restore();
  }

  Path getArrowPath(Size size, double lineWidth) {
    final arrowHeight = size.height / 2 - lineWidth * 1.5;
    final horizontalLineWidth = lineWidth * sqrt2;
    return Path()..addPolygon([
      // leftmost, top, rightmost, inside bottom right, inside top, inside bottom left
      Offset(0, arrowHeight),
      Offset(arrowHeight, 0),
      Offset(arrowHeight * 2, arrowHeight),
      Offset(arrowHeight * 2 - horizontalLineWidth, arrowHeight),
      Offset(arrowHeight, horizontalLineWidth),
      Offset(horizontalLineWidth, arrowHeight),
    ], true);
  }

  @override
  bool shouldRepaint(covariant _ArmorStatTuningIconPainter oldDelegate) {
    return false;
  }
}
