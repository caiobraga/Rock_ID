import 'dart:math';

import 'package:flutter/material.dart';

class HexagonBorder extends ShapeBorder {
  const HexagonBorder();

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(0.0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final double width = rect.width;
    final double height = rect.height;
    final double radius = min(width, height) / 2;
    final double centerX = rect.width / 2;
    final double centerY = rect.height / 2;
    const double angle = pi / 3;

    Path path = Path();
    for (int i = 0; i < 6; i++) {
      double x = centerX + radius * cos(angle * i - pi / 2);
      double y = centerY + radius * sin(angle * i - pi / 2);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) {
    return const HexagonBorder();
  }
}

class HexagonFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color backgroundColor;
  final String heroTag;

  const HexagonFloatingActionButton({
    Key? key,
    required this.heroTag,
    required this.onPressed,
    required this.child,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const HexagonBorder(),
      color: backgroundColor,
      child: InkWell(
        customBorder: const HexagonBorder(),
        onTap: onPressed,
        child: Container(
          height: 70.0,
          width: 70.0,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}
