import 'package:flutter/material.dart';
import 'dart:math';

enum Circle {
  right,
  left,
}

extension ToPath on Circle {
  Path toPath({required Size size}) {
    final path = Path();
    late Offset offset;
    late bool clockwise;
    switch (this) {
      case Circle.left:
        path.moveTo(size.width, 0);
        offset = Offset(size.width, size.height);
        clockwise = false;
        break;
      case Circle.right:
        offset = Offset(0, size.height);
        clockwise = true;
        break;
    }
    path.arcToPoint(
      offset,
      clockwise: clockwise,
      radius: Radius.elliptical(
        size.width / 2,
        size.height / 2,
      ),
    );
    path.close();
    return path;
  }
}

class HalfCircle extends CustomClipper<Path> {
  final Circle circle;

  HalfCircle({required this.circle});

  @override
  Path getClip(Size size) => circle.toPath(size: size);

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _counterClockwiseRotationAnimationController;
  late Animation<double> _counterClockwiseRotationAnimation;

  @override
  void initState() {
    super.initState();
    _counterClockwiseRotationAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _counterClockwiseRotationAnimation = Tween<double>(
      begin: 0,
      end: (-pi / 2),
    ).animate(
      CurvedAnimation(
        parent: _counterClockwiseRotationAnimationController,
        curve: Curves.bounceOut,
      ),
    );
  }

  @override
  void dispose() {
    _counterClockwiseRotationAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 1), () {
      _counterClockwiseRotationAnimationController
        ..reset()
        ..forward();
    });

    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _counterClockwiseRotationAnimation,
          builder: (context, child) => Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..rotateZ(_counterClockwiseRotationAnimation.value),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipPath(
                  clipper: HalfCircle(circle: Circle.left),
                  child: Container(
                    height: 100,
                    width: 100,
                    color: Colors.blue,
                  ),
                ),
                ClipPath(
                  clipper: HalfCircle(circle: Circle.right),
                  child: Container(
                    height: 100,
                    width: 100,
                    color: Colors.yellow,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
