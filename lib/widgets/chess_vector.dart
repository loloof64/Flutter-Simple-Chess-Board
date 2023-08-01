// Using code from the package chess_vectors_flutter
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';

/// Just a translation from List of double to a Float64List.
Float64List? convertListIntoMatrix4(List<double>? matrixValues) {
  if (matrixValues == null) return null;
  return Float64List.fromList(<double>[
    matrixValues[0],
    matrixValues[1],
    0.0,
    0.0,
    matrixValues[2],
    matrixValues[3],
    0.0,
    0.0,
    0.0,
    0.0,
    1.0,
    0.0,
    matrixValues[4],
    matrixValues[5],
    0.0,
    1.0
  ]);
}

/// Drawing parameters for each element of the Vector
class DrawingParameters {
  /// Fill color : null for the absence of fill color.
  Color? fillColor;

  /// Stroke color: null for the absence of stroke color.
  Color? strokeColor;

  /// Stroke width
  double? strokeWidth;

  /// Stroke line cap : null for the absence of stroke line cap.
  StrokeCap? strokeLineCap;

  /// Stroke line join : null for the absence of stroke line join.
  StrokeJoin? strokeLineJoin;

  /// Stroke line miter limit
  double? strokeLineMiterLimit;

  /// Translation of the element : null for the absence of translation.
  Offset? translate;

  /// Transform matrix of the element :  null for the absence of transform matrix.
  Float64List? transformMatrix;

  /// Constructor : all values are optional.
  /// fillColor (Color) : Fill color : null for the absence of fill color.
  /// strokeColor (Color) : Stroke color: null for the absence of stroke color.
  /// strokeWidth (double)
  /// strokeLineCap (StrokeCap) : Stroke line cap : null for the absence of stroke line cap.
  /// strokeLineJoin (StrokeJoin) : Stroke line join : null for the absence of stroke line join.
  /// strokeLineMiterLimit (double) : Stroke line miter limit
  /// translate (Offset) : Translation of the element : null for the absence of translation.
  /// transformMatrix (Float64List) : Transform matrix of the element :  null for the absence of transform matrix.
  DrawingParameters(
      {this.fillColor,
      this.strokeColor,
      this.strokeWidth,
      this.strokeLineCap,
      this.strokeLineJoin,
      this.translate,
      this.strokeLineMiterLimit,
      List<double>? transformMatrixValues})
      : transformMatrix = convertListIntoMatrix4(transformMatrixValues);

  @override
  String toString() {
    return "DrawingParameters("
        "fillColor = $fillColor,"
        "strokeColor = $strokeColor,"
        "strokeWidth = $strokeWidth,"
        "strokeLineCap = $strokeLineCap,"
        "strokeLineJoin = $strokeLineJoin,"
        "strokeLineMiterLimit = $strokeLineMiterLimit,"
        "translate = $translate,"
        "transfromMatrix = $transformMatrix"
        ")";
  }
}

/// Use each property of childDrawingParameters in priority, and properties of
/// parentDrawingParameters if not defined in child parameters.
/// Note that it is allowed for a property that both definitions are null.
DrawingParameters mergeDrawingParameters(
    DrawingParameters childDrawingParameters,
    DrawingParameters? parentDrawingParameters) {
  DrawingParameters usedDrawingParameters = DrawingParameters(
      fillColor: childDrawingParameters.fillColor ??
          parentDrawingParameters!.fillColor,
      strokeColor: childDrawingParameters.strokeColor ??
          parentDrawingParameters!.strokeColor,
      strokeWidth: childDrawingParameters.strokeWidth ??
          parentDrawingParameters!.strokeWidth,
      strokeLineCap: childDrawingParameters.strokeLineCap ??
          parentDrawingParameters!.strokeLineCap,
      strokeLineJoin: childDrawingParameters.strokeLineJoin ??
          parentDrawingParameters!.strokeLineJoin,
      strokeLineMiterLimit: childDrawingParameters.strokeLineMiterLimit ??
          parentDrawingParameters!.strokeLineMiterLimit,
      translate: childDrawingParameters.translate ??
          parentDrawingParameters!.translate,
      transformMatrixValues: childDrawingParameters.transformMatrix ??
          parentDrawingParameters!.transformMatrix);
  return usedDrawingParameters;
}

/// A drawable element of the Vector.
abstract class VectorDrawableElement {
  /// Drawing parameters for this element
  DrawingParameters? drawingParameters;

  /// drawingParameters (DrawingParameters) : Drawing parameters for this element
  VectorDrawableElement(this.drawingParameters);

  void paintIntoCanvas(
      Canvas targetCanvas, DrawingParameters? parentDrawingParameters);
}

/// A Vector path element (<path>).
class VectorImagePathDefinition extends VectorDrawableElement {
  /// Elements of this path
  List<PathElement> pathElements;

  /// path (string) REQUIRED : path definition ('d' attribute)
  /// drawingParameters (DrawingParameters) : drawing parameters for this Circle
  VectorImagePathDefinition({
    required String path,
    DrawingParameters? drawingParameters,
  })  : pathElements = parsePath(path),
        super(drawingParameters);

  @override
  void paintIntoCanvas(
      Canvas targetCanvas, DrawingParameters? parentDrawingParameters) {
    DrawingParameters usedDrawingParameters =
        mergeDrawingParameters(drawingParameters!, parentDrawingParameters);

    targetCanvas.save();
    if (drawingParameters!.transformMatrix != null) {
      targetCanvas.transform(drawingParameters!.transformMatrix!);
    }
    if (drawingParameters!.translate != null) {
      targetCanvas.translate(
          drawingParameters!.translate!.dx, drawingParameters!.translate!.dy);
    }

    var commonPath = Path();
    for (var element in pathElements) {
      element.addToPath(commonPath);
    }

    if (usedDrawingParameters.fillColor != null) {
      var fillPathPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = usedDrawingParameters.fillColor!;
      targetCanvas.drawPath(commonPath, fillPathPaint);
    }

    var strokePathPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = usedDrawingParameters.strokeColor!
      ..strokeWidth = usedDrawingParameters.strokeWidth!;
    if (usedDrawingParameters.strokeLineCap != null) {
      strokePathPaint.strokeCap = usedDrawingParameters.strokeLineCap!;
    }
    if (usedDrawingParameters.strokeLineJoin != null) {
      strokePathPaint.strokeJoin = usedDrawingParameters.strokeLineJoin!;
    }
    if (usedDrawingParameters.strokeLineMiterLimit != null) {
      strokePathPaint.strokeMiterLimit =
          usedDrawingParameters.strokeLineMiterLimit!;
    }
    targetCanvas.drawPath(commonPath, strokePathPaint);

    targetCanvas.restore();
  }
}

/// Transform a path definition (value of 'd' attribute in SVG <path> tag) into
/// a List of PathElement.
List<PathElement> parsePath(String pathStr) {
  interpretCommand(RegExp commandRegex, String input) {
    var commandInterpretation = commandRegex.firstMatch(input);
    if (commandInterpretation == null) return null;

    var commandType = commandInterpretation.group(1)!;
    var relativeCommand = commandType.toLowerCase() == commandType;
    switch (commandType) {
      case 'M':
      case 'm':
        var element = MoveElement(
            relative: relativeCommand,
            moveParams: Offset(double.parse(commandInterpretation.group(2)!),
                double.parse(commandInterpretation.group(3)!)));
        var remainingPathStr = input.substring(commandInterpretation.end);
        return (element, remainingPathStr);
      case 'L':
      case 'l':
        var element = LineElement(
            relative: relativeCommand,
            lineParams: Offset(double.parse(commandInterpretation.group(2)!),
                double.parse(commandInterpretation.group(3)!)));
        var remainingPathStr = input.substring(commandInterpretation.end);
        return (element, remainingPathStr);
      case 'c':
      case 'C':
        var element = CubicCurveElement(
            relative: relativeCommand,
            firstControlPoint: Offset(
                double.parse(commandInterpretation.group(2)!),
                double.parse(commandInterpretation.group(3)!)),
            secondControlPoint: Offset(
                double.parse(commandInterpretation.group(4)!),
                double.parse(commandInterpretation.group(5)!)),
            endPoint: Offset(double.parse(commandInterpretation.group(6)!),
                double.parse(commandInterpretation.group(7)!)));
        var remainingPathStr = input.substring(commandInterpretation.end);
        return (element, remainingPathStr);
      case 'a':
      case 'A':
        var element = ArcElement(
            relative: relativeCommand,
            radius: Offset(double.parse(commandInterpretation.group(2)!),
                double.parse(commandInterpretation.group(3)!)),
            center: Offset(double.parse(commandInterpretation.group(7)!),
                double.parse(commandInterpretation.group(8)!)),
            xAxisRotation: double.parse(commandInterpretation.group(4)!));
        var remainingPathStr = input.substring(commandInterpretation.end);
        return (element, remainingPathStr);
      case 'z':
      case 'Z':
        var element = CloseElement();
        var remainingPathStr = input.substring(commandInterpretation.end);
        return (element, remainingPathStr);
    }
    return null;
  }

  String valueFormat = r"(\d+(?:\.\d+)?)";
  String separatorFormat = r"(?:\s+|,)";

  var moveRegex =
      RegExp("^(M|m)$separatorFormat$valueFormat$separatorFormat$valueFormat");
  var lineRegex =
      RegExp("^(L|l)$separatorFormat$valueFormat$separatorFormat$valueFormat");
  var cubicCurveRegex = RegExp(
      "^(C|c)$separatorFormat$valueFormat$separatorFormat$valueFormat$separatorFormat$valueFormat$separatorFormat$valueFormat$separatorFormat$valueFormat$separatorFormat$valueFormat");
  var arcRegex = RegExp(
      "^(A|a)$separatorFormat$valueFormat$separatorFormat$valueFormat$separatorFormat$valueFormat$separatorFormat$valueFormat$separatorFormat$valueFormat$separatorFormat$valueFormat$separatorFormat$valueFormat");
  var closeRegex = RegExp("^(z)");

  var elementsToReturn = <PathElement>[];
  var remainingPath = pathStr.trim();

  while (remainingPath.isNotEmpty) {
    var moveElementTuple = interpretCommand(moveRegex, remainingPath);
    var lineElementTuple = interpretCommand(lineRegex, remainingPath);
    var cubicCurveElementTuple =
        interpretCommand(cubicCurveRegex, remainingPath);
    var arcElementTuple = interpretCommand(arcRegex, remainingPath);
    var closeElementTuple = interpretCommand(closeRegex, remainingPath);

    if (moveElementTuple != null) {
      elementsToReturn.add(moveElementTuple.$1);
      remainingPath = moveElementTuple.$2.trim();
    } else if (lineElementTuple != null) {
      elementsToReturn.add(lineElementTuple.$1);
      remainingPath = lineElementTuple.$2.trim();
    } else if (cubicCurveElementTuple != null) {
      elementsToReturn.add(cubicCurveElementTuple.$1);
      remainingPath = cubicCurveElementTuple.$2.trim();
    } else if (arcElementTuple != null) {
      elementsToReturn.add(arcElementTuple.$1);
      remainingPath = arcElementTuple.$2.trim();
    } else if (closeElementTuple != null) {
      elementsToReturn.add(closeElementTuple.$1);
      remainingPath = closeElementTuple.$2.trim();
    } else {
      throw "Unrecognized path in $remainingPath !";
    }
  }

  return elementsToReturn;
}

/// Element of a Path integrated into a Vector
abstract class PathElement {
  /// add the given path to the PathElement
  void addToPath(Path path);
}

/// Path element of type MoveTo
class MoveElement extends PathElement {
  /// Is it a relative move ?
  bool relative;

  /// Move x and y if not relative, otherwise move dx and dy.
  Offset moveParams;

  /// moveParams (Offset) REQUIRED : Move x and y if not relative, otherwise move dx and dy.
  /// relative (bool) REQUIRED : Is it a relative move ?
  MoveElement({required this.moveParams, required this.relative});

  @override // ignore: missing_function_body
  void addToPath(Path path) {
    if (relative) {
      path.relativeMoveTo(moveParams.dx, moveParams.dy);
    } else {
      path.moveTo(moveParams.dx, moveParams.dy);
    }
  }

  @override
  String toString() {
    return "MoveElement("
        "relative = $relative, "
        "moveParams = $moveParams"
        ")";
  }
}

/// Path element of type Close
class CloseElement extends PathElement {
  @override
  void addToPath(Path path) {
    path.close();
  }

  @override
  String toString() {
    return "CloseElement()";
  }
}

/// Path element of type Line
class LineElement extends PathElement {
  /// Is it a relative move ?
  bool relative;

  /// Line x and y if not relative, otherwise move dx and dy.
  Offset lineParams;

  /// lineParams (Offset) REQUIRED : Line x and y if not relative, otherwise line dx and dy.
  /// relative (bool) REQUIRED :Is it a relative line ?
  LineElement({required this.lineParams, required this.relative});

  @override
  void addToPath(Path path) {
    if (relative) {
      path.relativeLineTo(lineParams.dx, lineParams.dy);
    } else {
      path.lineTo(lineParams.dx, lineParams.dy);
    }
  }

  @override
  String toString() {
    return "LineElement("
        "relative = $relative, "
        "lineParams = $lineParams"
        ")";
  }
}

/// Path element of type CubicCurve
class CubicCurveElement extends PathElement {
  /// Is it a relative move ?
  bool relative;

  /// First control point
  Offset firstControlPoint;

  /// Second control point
  Offset secondControlPoint;

  /// End point
  Offset endPoint;

  /// relative (bool) REQUIRED : Is it a relative move ?
  /// firstControlPoint (Offset) REQUIRED : First control point
  /// secondControlPoint (Offset) REQUIRED : Second control point
  /// endPoint (Offset) REQUIRED : end point
  CubicCurveElement({
    required this.relative,
    required this.firstControlPoint,
    required this.secondControlPoint,
    required this.endPoint,
  });

  @override
  void addToPath(Path path) {
    if (relative) {
      path.relativeCubicTo(
          firstControlPoint.dx,
          firstControlPoint.dy,
          secondControlPoint.dx,
          secondControlPoint.dy,
          endPoint.dx,
          endPoint.dy);
    } else {
      path.cubicTo(
          firstControlPoint.dx,
          firstControlPoint.dy,
          secondControlPoint.dx,
          secondControlPoint.dy,
          endPoint.dx,
          endPoint.dy);
    }
  }

  @override
  String toString() {
    return "CubicCurveElement("
        "relative = $relative, "
        "firstControlPoint = $firstControlPoint,"
        "secondControlPoint = $secondControlPoint,"
        "endPoint = $endPoint"
        ")";
  }
}

/// Path element of type Arc
class ArcElement extends PathElement {
  /// Is it a relative move ?
  bool relative;

  /// Radius
  Offset radius;

  /// Rotation along X axis
  double xAxisRotation;

  /// Center
  Offset center;

  /// relative (bool) REQUIRED : Is it a relative move ?
  /// radius (Offset) REQUIRED : Radius
  /// xAxisRotation (double) REQUIRED : Rotation along x axis
  /// center (Offset) REQUIRED : Center
  ArcElement(
      {required this.relative,
      required this.radius,
      required this.xAxisRotation,
      required this.center});

  @override
  void addToPath(Path path) {
    if (relative) {
      path.relativeArcToPoint(
        center,
        rotation: xAxisRotation,
        radius: Radius.elliptical(radius.dx, radius.dy),
      );
    } else {
      path.arcToPoint(
        center,
        rotation: xAxisRotation,
        radius: Radius.elliptical(radius.dx, radius.dy),
      );
    }
  }

  @override
  String toString() {
    return "ArcElement("
        "relative = $relative, "
        "radius = $radius,"
        "xAxisRotation = $xAxisRotation,"
        "center = $center"
        ")";
  }
}

/// A Vector circle element.
class VectorCircle extends VectorDrawableElement {
  /// Position of the Circle
  Offset position;

  /// Radius of the Circle
  double radius;

  /// position (Offset) REQUIRED : Position of the Circle
  /// radius (double) REQUIRED : Radius of the Circle
  /// drawingParameters (DrawingParameters) : drawing parameters for this Circle
  VectorCircle(
      {required this.position,
      required this.radius,
      DrawingParameters? drawingParameters})
      : super(drawingParameters);

  @override
  void paintIntoCanvas(
      Canvas targetCanvas, DrawingParameters? parentDrawingParameters) {
    DrawingParameters usedDrawingParameters =
        mergeDrawingParameters(drawingParameters!, parentDrawingParameters);

    var commonPath = Path()
      ..addOval(Rect.fromPoints(position.translate(-radius, -radius),
          position.translate(radius, radius)));

    if (usedDrawingParameters.fillColor != null) {
      var fillPathPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = usedDrawingParameters.fillColor!;
      targetCanvas.drawPath(commonPath, fillPathPaint);
    }

    var strokePathPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = usedDrawingParameters.strokeColor!
      ..strokeWidth = usedDrawingParameters.strokeWidth!;
    targetCanvas.drawPath(commonPath, strokePathPaint);
  }
}

/// A Vector group element (<g>).
class VectorImageGroup extends VectorDrawableElement {
  /// Children elements of this Group
  List<VectorDrawableElement>? children;

  /// children (List of VectorDrawableElement) : Children elements of this Group
  /// drawingParameters (DrawingParameters) : drawing parameters for this Group
  VectorImageGroup({
    this.children,
    DrawingParameters? drawingParameters,
  }) : super(drawingParameters);

  @override
  void paintIntoCanvas(
      Canvas targetCanvas, DrawingParameters? parentDrawingParameters) {
    DrawingParameters usedDrawingParameters =
        mergeDrawingParameters(drawingParameters!, parentDrawingParameters);

    for (var currentChild in children!) {
      currentChild.paintIntoCanvas(targetCanvas, usedDrawingParameters);
    }
  }
}
