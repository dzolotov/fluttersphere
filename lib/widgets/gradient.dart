import 'package:flutter/material.dart';

class GradientBox extends LeafRenderObjectWidget {
  const GradientBox({super.key});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      GradientRenderObject();
}

class GradientRenderObject extends RenderBox {
  @override
  void paint(PaintingContext context, Offset offset) {
    const gradient = LinearGradient(colors: [Colors.red, Colors.green]);
    final rect = offset & size;
    context.canvas.save();
    // context.canvas.clipRRect(
    //   RRect.fromRectAndRadius(
    //     offset & const Size(128, 128),
    //     const Radius.circular(32),
    //   ),
    // );
    context.canvas
        .drawRect(rect, Paint()..shader = gradient.createShader(rect));
    super.paint(context, offset);
    context.canvas.restore();
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.biggest;
  }

  @override
  void performResize() {
    size = constraints.biggest;
  }

// @override
// void performLayout() {
//   size = constraints.biggest;
// }
}
