import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// A stateful widget that measures the size of a child widget immediately after it is rendered.
class MeasureSize extends StatefulWidget {
  /// A [Widget] to be rendered and measured
  final Widget child;

  /// A callback fired exactly once after rendering [child] with the [Size] of
  /// the child widget
  final Function(Size) onChange;

  const MeasureSize({
    required this.onChange,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  State<MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<MeasureSize> {
  final widgetKey = GlobalKey();

  Size? oldSize;

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);
    return Container(
      key: widgetKey,
      child: widget.child,
    );
  }

  void postFrameCallback(_) {
    var context = widgetKey.currentContext;
    if (context == null) return;

    var newSize = context.size;
    if (oldSize == newSize || newSize == null) return;

    oldSize = newSize;
    widget.onChange(newSize);
  }
}
