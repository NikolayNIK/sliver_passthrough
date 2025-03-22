import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:sliver_passthrough/sliver_passthrough.dart';
import 'package:sliver_passthrough/src/render_box_to_sliver_passthrough.dart';

/// Just a proxy sliver widget created exclusively by [BoxToSliverPassthrough]
/// to make the weird layout algorithm possible.
@immutable
class SliverPassthroughAdapter extends SingleChildRenderObjectWidget {
  const SliverPassthroughAdapter({super.key, required Widget sliver})
    : super(child: sliver);

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderSliverPassthroughAdapter();
}

class RenderSliverPassthroughAdapter extends RenderProxySliver {
  @override
  void markNeedsLayout() {
    super.markNeedsLayout();

    final parent = this.parent;
    if (parent != null) {
      (parent as RenderBoxToSliverPassthrough).passthroughParent
          ?.markNeedsLayout();
    }
  }
}
