import 'package:flutter/material.dart';

import 'repaintable_page.dart';

class PageRenderDelegate extends StatefulWidget {
  const PageRenderDelegate({
    super.key,
    required this.addHeightNotifier,
    required this.addPageNotifier,
    required this.removeHeightListener,
    required this.removePageListener,
    required this.pageIndex,
    required this.child,
  });

  final void Function(void Function(double)) addHeightNotifier;
  final void Function(void Function(int)) addPageNotifier;
  final void Function(void Function(double)) removeHeightListener;
  final void Function(void Function(int)) removePageListener;
  final int pageIndex;
  final Widget child;

  @override
  State<PageRenderDelegate> createState() => _PageRenderDelegateState();
}

class _PageRenderDelegateState extends State<PageRenderDelegate> {
  bool shouldPaint = false;
  double? height;

  @override
  void initState() {
    super.initState();
    widget.addHeightNotifier(_heightListener);
    widget.addPageNotifier(_pageListener);
  }

  @override
  void dispose() {
    super.dispose();
    widget.removeHeightListener(_heightListener);
    widget.removePageListener(_pageListener);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintablePage(
      height: height,
      shouldPaint: shouldPaint,
      child: widget.child,
    );
  }

  void _heightListener(double newHeight) {
    if (height != null && newHeight > height!) {
      setState(() {
        height = newHeight;
      });
    }
  }

  void _pageListener(int newPage) {
    final bool paint = (newPage - widget.pageIndex).abs() > 1;
    if (paint != shouldPaint) {
      setState(() {
        shouldPaint = paint;
      });
    }
  }
}
