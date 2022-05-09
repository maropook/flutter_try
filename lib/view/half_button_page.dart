import 'package:flutter/material.dart';
import 'package:flutter_try/half_button.dart';

class HalfButtonPage extends StatelessWidget {
  const HalfButtonPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double size = 160;

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: <Widget>[
            HalfButton(size, Direction.bottom),
            HalfButton(size, Direction.left),
            HalfButton(size, Direction.right),
            HalfButton(size, Direction.top),
          ],
        ),
      ),
    );
  }
}
