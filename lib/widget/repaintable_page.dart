import 'package:flutter/material.dart';

class RepaintablePage extends StatelessWidget {
  const RepaintablePage({
    super.key,
    required this.shouldPaint,
    required this.height,
    required this.child,
  });
  final bool shouldPaint;
  final double? height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: shouldPaint,
      child: OverflowBox(
        alignment: Alignment.center,
        minHeight: null,
        minWidth: null,
        maxHeight: double.infinity,
        maxWidth: null,
        child: child,
      ),
    );
  }
}
