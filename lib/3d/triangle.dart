import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

class Triangle {
  Vector3 point1;
  Vector3 point2;
  Vector3 point3;
  final Paint paint;
  Matrix4 matrix = Matrix4.identity();


  @override
  String toString() {
    return "P1=$point1, P2=$point2, P3=$point3";
  }

  Triangle(Vector3 point1, Vector3 point2, Vector3 point3, {Paint? paint})
      : point1 = Vector3(point1.x, point1.y, point1.z),
        point2 = Vector3(point2.x, point2.y, point2.z),
        point3 = Vector3(point3.x, point3.y, point3.z),
        paint = paint ?? (Paint()..color = Colors.white..style = PaintingStyle.stroke);

  List<Vector2> vertices = [];

  void applyMatrix(Matrix4 matrix) {
    point1.applyMatrix4(matrix);
    point2.applyMatrix4(matrix);
    point3.applyMatrix4(matrix);
    update();
  }

  void transform(Vector3 p1, Vector3 p2, Vector3 p3) {
    final vector1 = p2 - p1;
    final vector2 = p3 - p1;
    final cross = vector1.cross(vector2);
    final normalXY = Vector3(0, 0, 1);
    final rot = Quaternion.fromTwoVectors(cross, normalXY);
    vector1.applyQuaternion(rot);
    vector2.applyQuaternion(rot);
    vertices = [Vector2.zero(), vector1.xy, vector2.xy];
    final entry = Matrix4.identity()..setEntry(3, 2, 0.005);
    matrix = entry
        .multiplied(Matrix4.compose(p1.xyz, rot.inverted(), Vector3.all(1)));
  }

  void update() {
    transform(point1, point2, point3);
  }

  void render(PaintingContext context, Offset shift, double? scale) {
    context.pushTransform(
        true,
        Offset.zero,
        Matrix4.compose(Vector3(shift.dx, shift.dy, 0), Quaternion.identity(),
            Vector3.all(scale ?? 1)), (context, offset) {
      final canvas = context.canvas;
      canvas.save();
      canvas.transform(matrix.storage);
      final path = Path();

      final p1 = vertices[0];
      final p2 = vertices[1];
      final p3 = vertices[2];

      path.moveTo(p1.x, p1.y);
      path.lineTo(p2.x, p2.y);
      path.lineTo(p3.x, p3.y);
      path.close();
      canvas.drawPath(path, paint);
      canvas.restore();
    });
  }
}

