import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'page_render_delegate.dart';
import 'size_negotiating_page_wrapper.dart';

class AutoSizingPageView extends StatefulWidget {
  const AutoSizingPageView({
    Key? key,
    required this.padEnds,
    required this.scrollDirection,
    required this.viewportFraction,
    required this.initialPage,
    required this.startingHeight,
    required this.pageSnapping,
    required this.children,
    EdgeInsets? margins,
  }) : super(key: key);

  final double startingHeight;
  final bool padEnds;
  final Axis scrollDirection;
  final double viewportFraction;
  final int initialPage;
  final bool pageSnapping;
  final List<Widget> children;

  @override
  State<AutoSizingPageView> createState() => AutoSizingPageViewState();
}

class AutoSizingPageViewState extends State<AutoSizingPageView>
    with SingleTickerProviderStateMixin {
  List<Widget>? wrappedChildren;
  AnimationController? _animationController;
  PageController? _pageController;
  Animation<double>? heightAnimation;
  double? _maxHeight;
  Set<void Function(double)> heightListeners = {};
  Set<void Function(int)> pageListeners = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(
        milliseconds: 150,
      ),
      vsync: this,
    );
    _pageController = PageController(
      initialPage: widget.initialPage,
      viewportFraction: widget.viewportFraction,
    );
    wrappedChildren = _wrapChildren();
  }

  @override
  void dispose() {
    super.dispose();
    _animationController?.dispose();
    _pageController?.dispose();
    heightListeners.clear();
    pageListeners.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: heightAnimation?.value ?? 0,
      child: PageView(
        controller: _pageController,
        padEnds: widget.padEnds,
        scrollDirection: widget.scrollDirection,
        pageSnapping: widget.pageSnapping,
        children: wrappedChildren ?? [],
        onPageChanged: (int page) {
          for (var listener in pageListeners) {
            listener(page);
          }
        },
      ),
    );
  }

  Future<void> _beginAnimation(_) async {
    try {
      await _animationController?.forward().orCancel;
    } on TickerCanceled {
      // ignore disposed animation controller
    }
  }

  bool _updatePageViewHeight(Size size) {
    if (size.height > (_maxHeight ?? 0)) {
      final double? oldHeight = _maxHeight;
      _maxHeight = size.height;
      for (var listener in heightListeners) {
        listener(_maxHeight!);
      }
      heightAnimation = _buildHeightAnimation(oldHeight ?? 0, _maxHeight!);
      _animationController?.reset();
      _beginAnimation(null);
    }
    return true;
  }

  List<Widget> _wrapChildren() {
    return widget.children.mapIndexed((index, child) {
      return PageRenderDelegate(
        pageIndex: index,
        addHeightNotifier: addHeightNotifier,
        addPageNotifier: addPageNotifier,
        removeHeightListener: removeHeightListener,
        removePageListener: removePageListener,
        child: SizeReportingWrapper(
          onRender: _updatePageViewHeight,
          child: child,
        ),
      );
    }).toList();
  }

  Animation<double> _buildHeightAnimation(double starting, double ending) {
    return Tween<double>(
      begin: starting,
      end: ending,
    ).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeIn),
    );
  }

  void addHeightNotifier(void Function(double) listener) {
    heightListeners.add(listener);
  }

  void addPageNotifier(Function(int) listener) {
    pageListeners.add(listener);
  }

  void removeHeightListener(void Function(double) listener) {
    heightListeners.remove(listener);
  }

  void removePageListener(void Function(int) listener) {
    pageListeners.remove(listener);
  }
}
