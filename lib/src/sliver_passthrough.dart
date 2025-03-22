import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:sliver_passthrough/sliver_passthrough.dart';
import 'package:sliver_passthrough/src/render_sliver_passthrough.dart';

/// This widget is a sliver that takes a box child
/// (similarly to the [SliverToBoxAdapter]) with the one key feature of
/// being able then continue using slivers with the help of
/// a single [BoxToSliverPassthrough] as its descendant down the hierarchy
/// (either direct or indirect,
/// multiple [BoxToSliverPassthrough]s are not allowed).
/// If such is not present, acts like a regular [SliverToBoxAdapter].
///
/// When scrolling forwards this box will gradually expand together with its
/// scrolling sliver until the box (and its sliver) fills the entire area.
/// Upon reaching the end of the sliver, the box will start to shrink until
/// it completely comes out of visible area.
///
/// Keep in mind, that between [SliverPassthrough] and [SliverToBoxAdapter]
/// deferring layout until the widget build (like [LayoutBuilder] does)
/// is not allowed.
@immutable
class SliverPassthrough extends RenderObjectWidget {
  const SliverPassthrough({super.key, required this.builder}) : super();

  // TODO My gut tells me this value needs to somehow get split in two
  // to cover more use cases. As it stands, it significantly limits
  // the functionality to a couple niche use cases.
  final double minBoxExtent = .0;

  /// Builder function that should return a box child of this widget.
  /// Arguments are:
  /// 1. `context` - nearest build context;
  /// 2. `boxScrollOffset` - amount of pixels the descendant sliver got scrolled
  /// to relative to the box, can useful for [CustomPaint] and such.
  final Widget Function(
    BuildContext context,
    ValueListenable<double> boxScrollOffset,
  )
  builder;

  @override
  RenderObjectElement createElement() => _SliverPassthroughElement(this);

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderSliverPassthrough()..minBoxExtent = minBoxExtent;

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverPassthrough renderObject,
  ) => renderObject.minBoxExtent = minBoxExtent;
}

class _SliverPassthroughElement extends RenderObjectElement {
  _SliverPassthroughElement(SliverPassthrough super.widget);

  final _boxScrollOffset = ValueNotifier<double>(.0);

  Element? _child;

  @override
  void visitChildren(ElementVisitor visitor) {
    if (_child != null) visitor(_child!);
  }

  @override
  void forgetChild(Element child) {
    assert(child == _child);
    _child = null;

    super.forgetChild(child);
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);

    rebuild(force: true);
  }

  @override
  void update(SliverPassthrough newWidget) {
    super.update(newWidget);

    rebuild(force: true);
  }

  @override
  void performRebuild() {
    super.performRebuild();

    (renderObject as RenderSliverPassthrough).boxScrollOffset =
        _boxScrollOffset;

    _updateChild();
  }

  void _updateChild() =>
      _child = updateChild(
        _child,
        (widget as SliverPassthrough).builder(this, _boxScrollOffset),
        null,
      );

  @override
  void insertRenderObjectChild(RenderObject child, Object? slot) {
    final RenderObjectWithChildMixin<RenderObject> renderObject =
        this.renderObject as RenderObjectWithChildMixin<RenderObject>;
    assert(slot == null);
    assert(renderObject.debugValidateChild(child));
    renderObject.child = child;
    assert(renderObject == this.renderObject);
  }

  @override
  void moveRenderObjectChild(
    RenderObject child,
    Object? oldSlot,
    Object? newSlot,
  ) {
    assert(false);
  }

  @override
  void removeRenderObjectChild(RenderObject child, Object? slot) {
    final RenderObjectWithChildMixin<RenderObject> renderObject =
        this.renderObject as RenderObjectWithChildMixin<RenderObject>;
    assert(slot == null);
    assert(renderObject.child == child);
    renderObject.child = null;
    assert(renderObject == this.renderObject);
  }
}
