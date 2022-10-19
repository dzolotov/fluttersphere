import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class CircleContainerParentData extends ContainerBoxParentData<RenderBox> {
  int? flex;
  double angle = 0.0;
  double delta = 0.0;
  double radius = 0.0;
}

class CircleContainer extends MultiChildRenderObjectWidget {

  final double radius;

  CircleContainer({super.key, required this.radius, super.children,});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderCircleContainer(radius);

  @override
  void updateRenderObject(BuildContext context, covariant RenderObject renderObject) {
    (renderObject as RenderCircleContainer).radius = radius;
  }
}

class RenderCircleContainer extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, CircleContainerParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, CircleContainerParentData> {

  RenderCircleContainer(double radius) {
    _radius = radius;
  }

  double _radius = 0;

  double get radius => _radius;

  set radius(double value) {
    if (value != _radius) {
      _radius = value;
      markNeedsPaint();
    }
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! CircleContainerParentData) {
      child.parentData = CircleContainerParentData();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) => defaultPaint(context, offset);

  @override
  void performLayout() {
    var child = firstChild;
    int total = 0;
    //distribute around circle
    while (child != null) {
      final data = child.parentData as CircleContainerParentData;
      total += data.flex ?? 1;
      child = data.nextSibling;
    }
    final angleStep = 2 * pi / total;
    child = firstChild;
    double angle = 0.0;
    while (child != null) {
      final data = child.parentData as CircleContainerParentData;
      child.layout(constraints, parentUsesSize: false);
      data.angle = angle;
      data.radius = radius;
      data.delta = (data.flex ?? 1) *
          angleStep;
      angle += data.delta;
      child = data.nextSibling;
    }
    size = constraints.constrain(Size.square(2*radius.toDouble()));
  }
}

class Arc extends LeafRenderObjectWidget {

  final Color color;

  final int? flex;

  const Arc({super.key, required this.color, this.flex,});

  @override
  RenderObject createRenderObject(BuildContext context) => RenderArc(color: color, flex: flex);
}

class RenderArc extends RenderBox {
  Color color;
  int? flex;
  RenderArc({required this.color, this.flex});

  @override
  void attach(covariant PipelineOwner owner) {
    final parentData = (this.parentData as CircleContainerParentData);
    parentData.flex = flex;
    super.attach(owner);
  }

  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final data = (parentData as CircleContainerParentData);
    final rect = (offset-Offset(data.radius, data.radius) & size).center & Size.square(2*data.radius);
    context.canvas.drawArc(rect, data.angle, data.delta, true, Paint()..color = color);
  }
}

