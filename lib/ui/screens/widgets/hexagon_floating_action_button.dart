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
    return Path()
      ..moveTo(rect.width * 0.25, 0)
      ..lineTo(rect.width * 0.75, 0)
      ..lineTo(rect.width, rect.height * 0.5)
      ..lineTo(rect.width * 0.75, rect.height)
      ..lineTo(rect.width * 0.25, rect.height)
      ..lineTo(0, rect.height * 0.5)
      ..close();
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
          height: 56.0,
          width: 56.0,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}