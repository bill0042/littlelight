import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';

typedef OnButtonTap = void Function();

class FilterButtonWidget extends StatelessWidget {
  final Widget child;
  final bool selected;
  final bool excluded;
  final OnButtonTap? onTap;
  final OnButtonTap? onLongPress;
  final Widget? background;
  final double padding;
  const FilterButtonWidget(
    this.child, {
    Key? key,
    this.selected = false,
    this.excluded = false,
    this.onTap,
    this.onLongPress,
    this.background,
    this.padding = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final background = this.background;
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: context.theme.surfaceLayers.layer3,
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (background != null) Positioned.fill(child: background),
            Material(
              borderRadius: BorderRadius.circular(4),
              color: Colors.transparent,
              child: InkWell(
                enableFeedback: false,
                onTap: onTap,
                onLongPress: onLongPress,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: excluded ? context.theme.highlightedObjectiveLayers : context.theme.onSurfaceLayers.layer0,
                      width: 3,
                      style: (selected || excluded) ? BorderStyle.solid : BorderStyle.none,
                    ),
                  ),
                  constraints: const BoxConstraints(minWidth: double.infinity),
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(this.padding),
                  child: DefaultTextStyle(style: context.textTheme.button, child: child),
                ),
              ),
            ),
            if (excluded)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: CustomPaint(painter: _StrikethroughPainter(color: context.theme.highlightedObjectiveLayers)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StrikethroughPainter extends CustomPainter {
  final Color color;

  _StrikethroughPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, 0),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _StrikethroughPainter oldDelegate) {
    return false;
  }
}
