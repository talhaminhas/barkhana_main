import 'package:flutter/animation.dart';

Animation<double> curveAnimation(
    AnimationController controller, int index, int length) {
  return Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
    parent: controller,
    curve: Interval((1 / length) * index, 1, curve: Curves.easeOutQuart),
  ));
}
