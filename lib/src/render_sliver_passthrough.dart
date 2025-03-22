import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:sliver_passthrough/src/render_box_to_sliver_passthrough.dart';

class RenderSliverPassthrough extends RenderSliverSingleBoxAdapter {
  ValueNotifier<double>? boxScrollOffset;

  double _minBoxExtent = .0;

  RenderBoxToSliverPassthrough? _passthroughChild;

  get passthroughConstraints => constraints;

  set minBoxExtent(double value) {
    if (_minBoxExtent != value) {
      _minBoxExtent = value;
      markNeedsLayout();
    }
  }

  set passthroughChild(RenderBoxToSliverPassthrough? value) {
    assert(
      value == null || _passthroughChild == null,
      'Multiple BoxToSliverPassthrough descendants are not allowed for a single SliverPassthrough',
    );

    _passthroughChild = value;
  }

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }

    final SliverConstraints constraints = this.constraints;

    final passthroughChild = _passthroughChild;
    if (passthroughChild == null) {
      // we just act like a [SliverToBoxAdapter]
      // since we have no [BoxToSliverPassthrough] to go off of

      child.layout(constraints.asBoxConstraints(), parentUsesSize: true);
      final double childExtent = switch (constraints.axis) {
        Axis.horizontal => child.size.width,
        Axis.vertical => child.size.height,
      };
      final double paintedChildSize = calculatePaintOffset(
        constraints,
        from: 0.0,
        to: childExtent,
      );
      final double cacheExtent = calculateCacheOffset(
        constraints,
        from: 0.0,
        to: childExtent,
      );

      assert(paintedChildSize.isFinite);
      assert(paintedChildSize >= 0.0);
      geometry = SliverGeometry(
        scrollExtent: childExtent,
        paintExtent: paintedChildSize,
        cacheExtent: cacheExtent,
        maxPaintExtent: childExtent,
        hitTestExtent: paintedChildSize,
        hasVisualOverflow:
            childExtent > constraints.remainingPaintExtent ||
            constraints.scrollOffset > 0.0,
      );
      setChildParentData(child, constraints, geometry!);

      return;
    }

    // layout sliver passthrough descendant first
    passthroughChild.performEarlyLayout();

    final sliverChild = passthroughChild.child!;
    final childGeometry = sliverChild.geometry!;

    // layout ourselves based on a sliver descendant
    final scrollExtent = childGeometry.scrollExtent + _minBoxExtent;
    final paintExtent = calculatePaintOffset(
      constraints,
      from: .0,
      to: scrollExtent,
    );

    geometry = SliverGeometry(
      scrollExtent: scrollExtent,
      paintExtent: paintExtent,
      cacheExtent: calculateCacheOffset(
        constraints,
        from: .0,
        to: scrollExtent,
      ),
      maxPaintExtent: scrollExtent,
    );

    // layout the box child based on sliver descendant information
    final childExtent = max(_minBoxExtent, paintExtent);

    child.layout(
      constraints.axis == Axis.vertical
          ? BoxConstraints.tightFor(
            width: constraints.crossAxisExtent,
            height: childExtent,
          )
          : BoxConstraints.tightFor(
            width: childExtent,
            height: constraints.crossAxisExtent,
          ),
    );

    // whether we've reached the full box child height
    final fullBox =
        childExtent > constraints.remainingPaintExtent ||
        paintExtent > _minBoxExtent;

    final mainAxisPaintOffset = fullBox ? .0 : paintExtent - _minBoxExtent;

    // TODO up and left probably? SliverToBoxAdapter does that
    (child.parentData! as SliverPhysicalParentData).paintOffset =
        constraints.axis == Axis.vertical
            ? Offset(.0, mainAxisPaintOffset)
            : Offset(mainAxisPaintOffset, .0);

    boxScrollOffset?.value = fullBox ? constraints.scrollOffset : .0;
  }

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) => child!.hitTest(
    BoxHitTestResult.wrap(result),
    position: Offset(crossAxisPosition, mainAxisPosition),
  );
}
