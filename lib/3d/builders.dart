import 'dart:math';
import 'dart:ui';

import 'triangle.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Triangle, Colors;

List<Triangle> buildCube(
    Vector3 offset,
    Vector3 size,
    ) {
  /*
        5-------6
       /|      /|
      1-------2 |
      | 7-----|-8
      |/      |/
      3-------4
     */
  final p1 = Vector3(offset.x, offset.y, offset.z);
  final p2 = Vector3(offset.x + size.x, offset.y, offset.z);
  final p3 = Vector3(offset.x, offset.y + size.y, offset.z);
  final p4 = Vector3(offset.x + size.x, offset.y + size.y, offset.z);

  final p5 = Vector3(offset.x, offset.y, offset.z + size.z);
  final p6 = Vector3(offset.x + size.x, offset.y, offset.z + size.z);
  final p7 = Vector3(offset.x, offset.y + size.y, offset.z + size.z);
  final p8 = Vector3(offset.x + size.x, offset.y + size.y, offset.z + size.z);

  final triangles = <Triangle>[];
  triangles.addAll(buildPlane(p1, p2, p3, p4));
  triangles.addAll(buildPlane(p5, p6, p7, p8));
  triangles.addAll(buildPlane(p1, p2, p6, p5));
  triangles.addAll(buildPlane(p3, p7, p8, p4));
  triangles.addAll(buildPlane(p4, p8, p6, p2));
  triangles.addAll(buildPlane(p1, p5, p7, p3));
  return triangles;
}

List<Triangle> buildPlane(Vector3 p1, Vector3 p2, Vector3 p3, Vector3 p4, {Color? color}) {
  final paint = Paint()..style=PaintingStyle.stroke..color = color ?? Colors.white;
  final triangle1 = Triangle(p2, p1, p3, paint: paint);
  final triangle2 = Triangle(p3, p4, p2, paint: paint);
  triangle1.update();
  triangle2.update();
  return [triangle1, triangle2];
}

List<Triangle> buildSphere(Vector3 offset, double radius, {double latSegments = 64, double lngSegments = 64, Color? color}) {
  var sphere = <Triangle>[];
  final deltaLat = 2 * pi / latSegments;
  final deltaLng = 2 * pi / lngSegments;
  for (int lat = 0; lat < latSegments; lat++) {
    for (int lng = 0; lng < lngSegments; lng++) {
      final phi = 2 * pi * (lat / latSegments);
      final theta = 2 * pi * (lng / lngSegments);
      final x1 = offset.x + radius * sin(phi) * cos(theta);
      final y1 = offset.y + radius * sin(phi) * sin(theta);
      final z1 = offset.z + radius * cos(phi);
      final x2 = offset.x + radius * sin(phi + deltaLat) * cos(theta);
      final y2 = offset.y + radius * sin(phi + deltaLat) * sin(theta);
      final z2 = offset.z + radius * cos(phi + deltaLat);
      final x3 = offset.x + radius * sin(phi + deltaLat) * cos(theta + deltaLng);
      final y3 = offset.y + radius * sin(phi + deltaLat) * sin(theta + deltaLng);
      final z3 = offset.z + radius * cos(phi + deltaLat);
      final x4 = offset.x + radius * sin(phi) * cos(theta + deltaLng);
      final y4 = offset.y + radius * sin(phi) * sin(theta + deltaLng);
      final z4 = offset.z + radius * cos(phi);
      sphere.addAll(
        buildPlane(
          Vector3(x1, y1, z1),
          Vector3(x2, y2, z2),
          Vector3(x3, y3, z3),
          Vector3(x4, y4, z4),
          color: color,
        ),
      );
    }
  }
  return sphere;
}

