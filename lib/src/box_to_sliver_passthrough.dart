import 'package:flutter/widgets.dart';
import 'package:sliver_passthrough/sliver_passthrough.dart';
import 'package:sliver_passthrough/src/render_box_to_sliver_passthrough.dart';
import 'package:sliver_passthrough/src/sliver_passthrough_adapter.dart';

/// This widget is a box that takes a sliver child laying it out with the help
/// of a [SliverPassthrough] ancestor (either direct or indirect) which converts
/// sliver to a box beforehand.
@immutable
class BoxToSliverPassthrough extends SingleChildRenderObjectWidget {
  BoxToSliverPassthrough({super.key, required Widget sliver})
    : super(child: SliverPassthroughAdapter(sliver: sliver));

  @override
  RenderBox createRenderObject(BuildContext context) =>
      RenderBoxToSliverPassthrough();
}
