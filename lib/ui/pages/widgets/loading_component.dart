import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';

class LoadingComponent extends StatefulWidget {
  final bool scanningForPrice;

  const LoadingComponent({
    super.key,
    this.scanningForPrice = false,
  });

  @override
  _LoadingComponentState createState() => _LoadingComponentState();
}

class _LoadingComponentState extends State<LoadingComponent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.18, end: 0.82).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                left: 10,
                right: 10,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: ScanLinePainter(_animation.value),
                    );
                  },
                ),
              ),
              Image.asset(
                !widget.scanningForPrice
                    ? 'assets/images/rocktap.png'
                    : 'assets/images/coinstap.png',
                height: 80,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ScanLinePainter extends CustomPainter {
  final double progress;

  ScanLinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Constants.lightestRed.withOpacity(0.8)
      ..strokeWidth = 1;

    final y = size.height * progress;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
