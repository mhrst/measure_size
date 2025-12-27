import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef PrototypeWidgetBuilder<T> = Widget Function(
    BuildContext context, Map<T, Size> sizes);

typedef PrototypeConstraintCalculator = BoxConstraints Function(
    BoxConstraints parentConstraints);

class PrototypeId<T> extends ParentDataWidget<PrototypeParentData> {
  const PrototypeId({super.key, required this.id, required super.child});

  final T id;

  @override
  void applyParentData(RenderObject renderObject) {
    final PrototypeParentData parentData =
        renderObject.parentData as PrototypeParentData;
    if (parentData.id != id) {
      parentData.id = id;
      final RenderObject? targetParent = renderObject.parent;
      targetParent?.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => MeasureSizeBuilder;
}

class MeasureSizeBuilder<T> extends RenderObjectWidget {
  const MeasureSizeBuilder({
    super.key,
    required this.prototypes,
    required this.builder,
    required this.prototypeConstraints,
  });

  final List<PrototypeId<T>> prototypes;
  final PrototypeWidgetBuilder<T> builder;
  final PrototypeConstraintCalculator prototypeConstraints;

  @override
  RenderObjectElement createElement() => _PrototypeBuilderElement<T>(this);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderPrototypeBuilder<T>(
      constraintCalculator: prototypeConstraints,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderPrototypeBuilder<T> renderObject,
  ) {
    renderObject.constraintCalculator = prototypeConstraints;
  }
}

class _PrototypeBuilderElement<T> extends RenderObjectElement {
  _PrototypeBuilderElement(MeasureSizeBuilder<T> super.widget);

  List<Element> _prototypeElements = [];
  Element? _contentElement;

  final Set<Element> _forgottenChildren = HashSet<Element>();

  @override
  MeasureSizeBuilder<T> get widget => super.widget as MeasureSizeBuilder<T>;

  @override
  RenderPrototypeBuilder<T> get renderObject =>
      super.renderObject as RenderPrototypeBuilder<T>;

  @override
  void visitChildren(ElementVisitor visitor) {
    for (final Element child in _prototypeElements) {
      visitor(child);
    }
    if (_contentElement != null) {
      visitor(_contentElement!);
    }
  }

  @override
  void forgetChild(Element child) {
    if (_contentElement == child) {
      _contentElement = null;
    } else {
      _forgottenChildren.add(child);
    }
    super.forgetChild(child);
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    renderObject.onLayout = _buildContent;

    _prototypeElements = widget.prototypes.asMap().entries.map((entry) {
      return updateChild(null, entry.value, entry.key)!;
    }).toList();
  }

  @override
  void update(MeasureSizeBuilder<T> newWidget) {
    super.update(newWidget);
    renderObject.onLayout = _buildContent;

    _prototypeElements = updateChildren(
      _prototypeElements,
      newWidget.prototypes,
      forgottenChildren: _forgottenChildren,
      slots: List<int>.generate(newWidget.prototypes.length, (i) => i),
    );
    _forgottenChildren.clear();

    renderObject.markNeedsLayout();
  }

  @override
  void insertRenderObjectChild(RenderObject child, Object? slot) {
    final RenderPrototypeBuilder<T> renderObject = this.renderObject;
    if (slot is int) {
      renderObject.insertPrototype(child as RenderBox, slot);
    } else {
      renderObject.content = child as RenderBox;
    }
  }

  @override
  void moveRenderObjectChild(
    RenderObject child,
    Object? oldSlot,
    Object? newSlot,
  ) {
    final RenderPrototypeBuilder<T> renderObject = this.renderObject;
    if (newSlot is int) {
      renderObject.movePrototype(child as RenderBox, newSlot);
    }
  }

  @override
  void removeRenderObjectChild(RenderObject child, Object? slot) {
    final RenderPrototypeBuilder<T> renderObject = this.renderObject;
    if (child == renderObject.content) {
      renderObject.content = null;
    } else {
      renderObject.removePrototype(child as RenderBox);
    }
  }

  void _buildContent(Map<T, Size> sizes) {
    owner!.buildScope(this, () {
      final Widget builtWidget = widget.builder(this, sizes);
      _contentElement = updateChild(_contentElement, builtWidget, 'content');
    });
  }
}

class PrototypeParentData extends ContainerBoxParentData<RenderBox> {
  dynamic id;
}

class RenderPrototypeBuilder<T> extends RenderBox {
  RenderPrototypeBuilder({
    required PrototypeConstraintCalculator constraintCalculator,
  }) : _constraintCalculator = constraintCalculator;

  final List<RenderBox> _prototypes = [];
  RenderBox? _content;

  void Function(Map<T, Size> sizes)? onLayout;

  PrototypeConstraintCalculator _constraintCalculator;

  PrototypeConstraintCalculator get constraintCalculator =>
      _constraintCalculator;
  set constraintCalculator(PrototypeConstraintCalculator value) {
    if (_constraintCalculator == value) return;
    _constraintCalculator = value;
    markNeedsLayout();
  }

  RenderBox? get content => _content;
  set content(RenderBox? value) {
    if (_content != value) {
      if (_content != null) dropChild(_content!);
      _content = value;
      if (_content != null) adoptChild(_content!);
      markNeedsLayout();
    }
  }

  void insertPrototype(RenderBox child, int index) {
    setupParentData(child);
    if (index >= 0 && index < _prototypes.length) {
      _prototypes.insert(index, child);
    } else {
      _prototypes.add(child);
    }
    adoptChild(child);
    markNeedsLayout();
  }

  void movePrototype(RenderBox child, int newIndex) {
    _prototypes.remove(child);
    if (newIndex >= 0 && newIndex < _prototypes.length) {
      _prototypes.insert(newIndex, child);
    } else {
      _prototypes.add(child);
    }
    markNeedsLayout();
  }

  void removePrototype(RenderBox child) {
    if (_prototypes.remove(child)) {
      dropChild(child);
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! PrototypeParentData) {
      child.parentData = PrototypeParentData();
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    for (final child in _prototypes) {
      child.attach(owner);
    }
    _content?.attach(owner);
  }

  @override
  void detach() {
    super.detach();
    for (final child in _prototypes) {
      child.detach();
    }
    _content?.detach();
  }

  @override
  void redepthChildren() {
    for (final child in _prototypes) {
      redepthChild(child);
    }
    if (_content != null) redepthChild(_content!);
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    for (final child in _prototypes) {
      visitor(child);
    }
    if (_content != null) visitor(_content!);
  }

  @override
  void performLayout() {
    final Map<T, Size> sizes = {};
    late final BoxConstraints prototypeConstraints;
    prototypeConstraints = _constraintCalculator(constraints);

    for (final RenderBox child in _prototypes) {
      child.layout(prototypeConstraints, parentUsesSize: true);
      final PrototypeParentData parentData =
          child.parentData as PrototypeParentData;
      if (parentData.id != null) {
        sizes[parentData.id as T] = child.size;
      }
    }

    if (onLayout != null) {
      invokeLayoutCallback((constraints) {
        onLayout!(sizes);
      });
    }

    if (_content != null) {
      _content!.layout(constraints, parentUsesSize: true);
      size = constraints.constrain(_content!.size);
    } else {
      size = constraints.biggest;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_content != null) context.paintChild(_content!, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (_content != null) return _content!.hitTest(result, position: position);
    return false;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return _content?.getMinIntrinsicWidth(height) ?? 0.0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _content?.getMaxIntrinsicWidth(height) ?? 0.0;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _content?.getMinIntrinsicHeight(width) ?? 0.0;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _content?.getMaxIntrinsicHeight(width) ?? 0.0;
  }
}
