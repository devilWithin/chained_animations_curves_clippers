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

extension on VoidCallback {
  Future<void> delayedOneSecond() async {
    Future.delayed(const Duration(seconds: 1), this);
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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late AnimationController _counterClockwiseRotationAnimationController;
  late Animation<double> _counterClockwiseRotationAnimation;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

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
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _flipAnimation = Tween<double>(begin: 0, end: -pi).animate(
      CurvedAnimation(
        parent: _flipController,
        curve: Curves.bounceOut,
      ),
    );

    _counterClockwiseRotationAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _flipAnimation = Tween<double>(
                begin: _flipAnimation.value, end: _flipAnimation.value + pi)
            .animate(
          CurvedAnimation(
            parent: _flipController,
            curve: Curves.bounceOut,
          ),
        );
        _flipController
          ..reset()
          ..forward();
      }
    });
    _flipAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _counterClockwiseRotationAnimation = Tween<double>(
          begin: _counterClockwiseRotationAnimation.value,
          end: _counterClockwiseRotationAnimation.value - (pi / 2),
        ).animate(
          CurvedAnimation(
            parent: _counterClockwiseRotationAnimationController,
            curve: Curves.bounceOut,
          ),
        );
        _counterClockwiseRotationAnimationController
          ..reset()
          ..forward();
      }
    });
  }

  @override
  void dispose() {
    _counterClockwiseRotationAnimationController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _counterClockwiseRotationAnimationController
      ..reset()
      ..forward.delayedOneSecond();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _counterClockwiseRotationAnimation,
            builder: (context, child) => Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..rotateZ(_counterClockwiseRotationAnimation.value),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _flipAnimation,
                    builder: (context, child) => Transform(
                      transform: Matrix4.identity()
                        ..rotateY(_flipAnimation.value),
                      alignment: Alignment.centerRight,
                      child: ClipPath(
                        clipper: HalfCircle(circle: Circle.left),
                        child: Container(
                          height: 100,
                          width: 100,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _flipAnimation,
                    builder: (context, child) => Transform(
                      transform: Matrix4.identity()
                        ..rotateY(_flipAnimation.value),
                      alignment: Alignment.centerLeft,
                      child: ClipPath(
                        clipper: HalfCircle(circle: Circle.right),
                        child: Container(
                          height: 100,
                          width: 100,
                          color: Colors.yellow,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
