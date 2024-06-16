import 'dart:math';
import 'package:flutter/material.dart';

class RoundedHexagonBorder extends ShapeBorder {
  final double borderRadius;

  const RoundedHexagonBorder({this.borderRadius = 15.0});

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
    final double centerX = width / 2;
    final double centerY = height / 2;
    final double radius = min(width, height) / 2;
    const double angle = pi / 3;

    Path path = Path();

    for (int i = 0; i < 6; i++) {
      double xMid1 =
          centerX + (radius - borderRadius) * cos(angle * i - pi / 2);
      double yMid1 =
          centerY + (radius - borderRadius) * sin(angle * i - pi / 2);
      double xMid2 =
          centerX + (radius - borderRadius) * cos(angle * (i + 1) - pi / 2);
      double yMid2 =
          centerY + (radius - borderRadius) * sin(angle * (i + 1) - pi / 2);

      if (i == 0) {
        path.moveTo(xMid1, yMid1);
      } else {
        path.arcToPoint(
          Offset(xMid1, yMid1),
          radius: Radius.circular(borderRadius),
          clockwise: false,
        );
      }

      path.lineTo(xMid2, yMid2);
    }

    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) {
    return RoundedHexagonBorder(borderRadius: borderRadius * t);
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
      shape: const RoundedHexagonBorder(borderRadius: 5.0),
      color: backgroundColor,
      child: InkWell(
        customBorder: const RoundedHexagonBorder(borderRadius: 5.0),
        onTap: onPressed,
        child: Container(
          height: 80.0,
          width: 80.0,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}
