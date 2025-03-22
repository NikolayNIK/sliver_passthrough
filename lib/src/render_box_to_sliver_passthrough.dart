import 'package:flutter/rendering.dart';
import 'package:sliver_passthrough/src/render_sliver_passthrough.dart';

class RenderBoxToSliverPassthrough extends RenderBox
    with RenderObjectWithChildMixin<RenderSliver> {
  RenderBoxToSliverPassthrough();

  RenderSliverPassthrough? passthroughParent;

  @override
  bool get sizedByParent => true;

  RenderSliverPassthrough findPassthroughParent() {
    RenderObject? parent = this.parent;
    while (parent != null) {
      if (parent is RenderSliverPassthrough) {
        return parent;
      }

      parent = parent.parent;
    }

    assert(
      false,
      'No SliverPassthrough ancestor found in the hierarchy.'
      ' Make sure this BoxToSliverPassthrough is either direct or indirect'
      ' descendant of SliverPassthrough.',
    );

    throw AssertionError();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);

    (passthroughParent = findPassthroughParent()).passthroughChild = this;
  }

  @override
  void detach() {
    super.detach();

    passthroughParent?.passthroughChild = null;
    passthroughParent = null;
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) =>
      constraints.biggest;

  void performEarlyLayout() => performLayout();

  @override
  void performLayout() => child!.layout(passthroughParent!.constraints);

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child!;
    if (!child.geometry!.visible) return;

    context.paintChild(child, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final child = this.child!;

    return child.geometry!.visible &&
        child.hitTest(
          SliverHitTestResult.wrap(result),
          mainAxisPosition: position.dy,
          crossAxisPosition: position.dx,
        );
  }
}
