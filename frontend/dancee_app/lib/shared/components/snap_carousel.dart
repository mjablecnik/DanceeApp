import 'package:flutter/material.dart';
import '../../core/theme.dart';

class SnapCarousel extends StatefulWidget {
  final int itemCount;
  final double itemWidth;
  final double spacing;
  final double scaleFactor;
  final Widget Function(BuildContext context, int index, double scale) itemBuilder;

  const SnapCarousel({
    super.key,
    required this.itemCount,
    this.itemWidth = 280,
    this.spacing = AppSpacing.lg,
    this.scaleFactor = 0.05,
    required this.itemBuilder,
  });

  @override
  State<SnapCarousel> createState() => _SnapCarouselState();
}

class _SnapCarouselState extends State<SnapCarousel> {
  late final ScrollController _controller;
  double _scrollOffset = 0;

  double get _itemExtent => widget.itemWidth + widget.spacing;

  double _sidePadding(BuildContext context) {
    return (MediaQuery.of(context).size.width - widget.itemWidth) / 2;
  }

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(() {
      setState(() => _scrollOffset = _controller.offset);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _scaleForIndex(int index) {
    final itemCenter = index * _itemExtent + widget.itemWidth / 2;
    final viewportCenter = _scrollOffset + MediaQuery.of(context).size.width / 2;
    final distance = (itemCenter - viewportCenter).abs();
    final normalizedDistance = (distance / _itemExtent).clamp(0.0, 1.0);
    return 1.0 - (normalizedDistance * widget.scaleFactor);
  }

  @override
  Widget build(BuildContext context) {
    final padding = _sidePadding(context);
    return SizedBox(
      height: 340,
      child: ListView.separated(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: padding),
        physics: _SnapScrollPhysics(itemExtent: _itemExtent),
        itemCount: widget.itemCount,
        separatorBuilder: (_, __) => SizedBox(width: widget.spacing),
        itemBuilder: (context, index) {
          final scale = _scaleForIndex(index);
          return SizedBox(
            width: widget.itemWidth,
            child: Transform.scale(
              scale: scale,
              child: widget.itemBuilder(context, index, scale),
            ),
          );
        },
      ),
    );
  }
}

class _SnapScrollPhysics extends ScrollPhysics {
  final double itemExtent;

  const _SnapScrollPhysics({required this.itemExtent, super.parent});

  @override
  _SnapScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _SnapScrollPhysics(itemExtent: itemExtent, parent: buildParent(ancestor));
  }

  double _getTargetPixels(ScrollMetrics position, Tolerance tolerance, double velocity) {
    double page = position.pixels / itemExtent;
    if (velocity < -tolerance.velocity * 0.5) {
      page = page.floorToDouble();
    } else if (velocity > tolerance.velocity * 0.5) {
      page = page.ceilToDouble();
    } else {
      page = page.roundToDouble();
    }
    return (page * itemExtent).clamp(position.minScrollExtent, position.maxScrollExtent);
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final target = _getTargetPixels(position, toleranceFor(position), velocity);
    if (target != position.pixels) {
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: toleranceFor(position));
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}
