import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors, Triangle;

import '../3d/builders.dart';
import '../3d/triangle.dart';

class Constraints3D extends Constraints {
  Constraints3D()
      : min = Vector3.zero(),
        max = Vector3.zero();

  const Constraints3D.tight(Vector3 value)
      : min = value,
        max = value;

  final Vector3? min;

  final Vector3? max;

  @override
  bool get isNormalized => true;

  @override
  bool get isTight => min == max;

  Vector3? get biggest => max;

  Vector3? get smallest => min;
}

class SpaceToWidgetAdapter extends SingleChildRenderObjectWidget {
  const SpaceToWidgetAdapter({
    super.key,
    super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderSpaceToWidgetAdapter();
}

class RenderSpaceToWidgetAdapter extends RenderBox
    with RenderObjectWithChildMixin<RenderCube> {
  @override
  void performLayout() {
    child!.layout(constraints);
    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      context.paintChild(
        child!,
        Offset(constraints.biggest.width / 2, constraints.biggest.height / 2),
      );
}

abstract class RenderCube extends RenderObject {
  Vector3? volume;

  @override
  void debugAssertDoesMeetConstraints() {}

  @override
  //отображаемый прямоугольник (для отладки)
  Rect get paintBounds => Rect.zero;

  @override
  Rect get semanticBounds => Rect.zero;

  @override
  void performResize() {}

  @override
  void performLayout() {}
}

class SpaceParentData extends ParentData
    with ContainerParentDataMixin<RenderCube> {
  Vector3? offset;
  double? scale;
  Vector3? volume;
}

abstract class Figure3D extends RenderCube {
  Vector3 size;

  Vector3? _scale;

  Quaternion? _rotation;

  Vector3? _translation;

  void updateVertices();

  Vector3 get scale => _scale ?? Vector3.all(1);

  set scale(Vector3 value) {
    _scale = value;
    markNeedsLayout();
  }

  Quaternion get rotation => _rotation ?? Quaternion.identity();

  set rotation(Quaternion rotation) {
    _rotation = rotation;
    markParentNeedsLayout();
    markNeedsLayout();
  }

  Vector3 get translation => _translation ?? Vector3.zero();

  set translation(Vector3 translation) {
    _translation = translation;
    markNeedsLayout();
  }

  Figure3D({
    required this.size,
    Quaternion? rotation,
    Vector3? scale,
    Vector3? translation,
  })
      : _rotation = rotation,
        _scale = scale,
        _translation = translation;

  void paint3D(PaintingContext context, Offset shift);

  void paint(PaintingContext context, Offset shift) => paint3D(context, shift);

  @override
  void performLayout() {
    volume = size;
    updateVertices();
  }

  @override
  bool get sizedByParent => false;
}

class HorizontalSpaceLayout extends MultiChildRenderObjectWidget {
  double? scale;

  HorizontalSpaceLayout({
    super.key,
    required super.children,
    this.scale,
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderSpace(scale: scale ?? 1.0);

  @override
  void updateRenderObject(BuildContext context,
      covariant RenderObject renderObject) {
    (renderObject as RenderSpace).scale = scale ?? 1;
  }
}

class RenderSpace extends RenderCube
    with ContainerRenderObjectMixin<RenderCube, SpaceParentData> {
  double? _scale;

  double get scale => _scale ?? 1;

  set scale(double value) {
    if (value != _scale) {
      _scale = value;
      markNeedsLayout();
    }
  }

  RenderSpace({double scale = 1.0}) : _scale = scale;

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! SpaceParentData) {
      child.parentData = SpaceParentData();
    }
  }

  @override
  bool get sizedByParent => false;

  @override
  void performLayout() {
    var child = firstChild;
    final offset = Vector3(0, 0, 0);
    while (child != null) {
      //workaround, parentData is created after first performLayout
      setupParentData(child);
      final data = (child.parentData as SpaceParentData);
      child.layout(constraints);      //define volume
      assert(child is Figure3D);
      data.offset = Vector3.copy(offset);
      (child as Figure3D).updateVertices();
      offset.x += data.volume!.x;
      data.scale = _scale;
      child = data.nextSibling;
    }
  }

  @override
  void paint(PaintingContext context, Offset shift) {
    RenderObject? child = firstChild;
    while (child != null) {
      final SpaceParentData childParentData =
      child.parentData! as SpaceParentData;
      context.paintChild(
          child, shift); //child сам прочитает свое положение, передаем центр
      child = childParentData.nextSibling;
    }
  }
}

class SphereWidget extends LeafRenderObjectWidget {
  final Vector3 volume;

  final Quaternion? rotation;

  final Vector3? scale;

  final Vector3? translation;

  final Color? color;

  const SphereWidget({
    super.key,
    required this.volume,
    required this.color,
    this.rotation,
    this.translation,
    this.scale,
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderSphereFigure(
        size: volume,
        rotation: rotation,
        color: color,
      );

  @override
  void updateRenderObject(BuildContext context, covariant RenderObject renderObject) {
    final obj = renderObject as RenderSphereFigure;
    obj.size = volume;
    obj.rotation = rotation ?? Quaternion.identity();
    obj.translation = translation ?? Vector3.zero();
    obj.scale = scale ?? Vector3.all(1);
    obj.color = color;
  }
}

class RenderSphereFigure extends Figure3D {

  Color? _color;

  Color? get color => _color;

  set color(Color? value) {
    if (value!=_color) {
      _color = value;
      markNeedsPaint();
    }
  }

  RenderSphereFigure({
    required super.size,
    Color? color,
    super.rotation,
    super.scale,
    super.translation,
  }): _color = color;

  @override
  bool get sizedByParent => false;

  @override
  void performLayout() {
    (parentData as SpaceParentData).volume = size;
    updateVertices();
  }

  List<Triangle> triangles = [];

  @override
  void paint3D(PaintingContext context, Offset shift) {
    for (final element in triangles) {
      element.render(context, shift, (parentData as SpaceParentData).scale);
    }
  }

  @override
  void updateVertices() {
    final data = parentData as SpaceParentData?;
    if (data != null && data.offset != null) {
      // print('Rebuild sphere');
      triangles =
          buildSphere(data.offset!, 5, latSegments: 32, lngSegments: 32, color: color,);
      //update matrices
      final matrix = Matrix4.compose(translation, rotation, scale);
      // print('Matrix is $matrix');
      for (final triangle in triangles) {
        triangle.applyMatrix(matrix);
      }
      // triangles = newTriangles;
      markNeedsPaint();
    }
  }
}