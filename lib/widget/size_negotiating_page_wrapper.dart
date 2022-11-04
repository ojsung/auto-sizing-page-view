import 'package:flutter/material.dart';

class SizeReportingWrapper extends StatefulWidget {
  const SizeReportingWrapper({
    Key? key,
    required this.onRender,
    required this.child,
  }) : super(key: key);

  final dynamic Function(Size) onRender;
  final Widget child;

  @override
  State<SizeReportingWrapper> createState() => _SizeReportingWrapperState();
}

class _SizeReportingWrapperState extends State<SizeReportingWrapper> {
  double? height;
  double? page;
  bool shouldPaint = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_postLayout);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _postLayout(_) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      widget.onRender(renderBox.size);
    }
  }
}
