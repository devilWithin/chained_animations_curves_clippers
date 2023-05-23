import 'package:flutter/material.dart';

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

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
    );
  }
}
