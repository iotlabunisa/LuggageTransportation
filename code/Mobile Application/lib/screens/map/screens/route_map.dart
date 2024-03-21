import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:sm_iot_lab/route/route_manager.dart';

class RouteMap extends StatefulWidget {
  const RouteMap({super.key});

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  final notifier = ValueNotifier<List<Stop>>([]);
  late StreamSubscription<List<Stop>> _stopsSubscription;
  int i = 0;

  @override
  void initState() {
    super.initState();

    _stopsSubscription = RouteManager.routeUpdateStream.stream
        .asBroadcastStream()
        .listen((stops) {
      setState(() {
        notifier.value = stops;
      });
      if (i == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Route started",
              style: const TextStyle(color: Colors.white),
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.grey[600],
          ),
        );
      }
      if (i == 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Route ended",
              style: const TextStyle(color: Colors.white),
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.grey[600],
          ),
        );
      }
      setState(() {
        i = i + 1;
      });
    });
  }

  @override
  void dispose() {
    _stopsSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 8, 0),
      child: CustomPaint(
        painter: WorldMapPainter(notifier),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class Shape {
  Shape(strPath) : _path = parseSvgPathData(strPath);

  /// transforms a [_path] into [_transformedPath] using given [matrix]
  void transform(Matrix4 matrix) =>
      _transformedPath = _path.transform(matrix.storage);

  final Path _path;
  Path? _transformedPath;
}

class WorldMapPainter extends CustomPainter {
  WorldMapPainter(this._notifier) : super(repaint: _notifier);

  static final _data =
      '''M37.5 8H58.5V15H59.5V8H66.5V7H59.5V0H58.5V7H37.5V0H36.5V7H26H25.5V7.5V27H0V28H25.5V48.5V49H26H36.5V56H37.5V49H58.5V56H59.5V49H66.5V48H59.5V41H58.5V48H37.5V41H36.5V48H26.5V27.5V8H36.5V15H37.5V8 
M 37 7.5 m 5, 0 a 5,5 0 1,0 -10,0 a 5,5 0 1,0  10,0 
M 37 48.5 m 5, 0 a 5,5 0 1,0 -10,0 a 5,5 0 1,0  10,0 
M 59 7.5 m 5, 0 a 5,5 0 1,0 -10,0 a 5,5 0 1,0  10,0 
M 59 48.5 m 5, 0 a 5,5 0 1,0 -10,0 a 5,5 0 1,0  10,0'''
          .split('\n');

  final _shapes = [
    Shape(_data[0]),
    Shape(_data[1]),
    Shape(_data[2]),
    Shape(_data[3]),
    Shape(_data[4]),
  ];

  final ValueNotifier<List<Stop>> _notifier;
  final Paint _paint = Paint();
  Size _size = Size.zero;

  @override
  void paint(Canvas canvas, Size size) {
    if (size != _size) {
      _size = size;
      final fs = applyBoxFit(BoxFit.contain, const Size(70, 70), size);
      final r = Alignment.center.inscribe(fs.destination, Offset.zero & size);
      final matrix = Matrix4.translationValues(r.left, r.top, 0)
        ..scale(fs.destination.width / fs.source.width);
      for (var shape in _shapes) {
        shape.transform(matrix);
      }
    }

    canvas
      ..clipRect(Offset.zero & size)
      ..drawColor(Colors.white, BlendMode.src);

    // paint the track
    _paint
      ..color = Colors.black87
      ..strokeWidth = 3
      ..style = PaintingStyle.fill;
    canvas.drawPath(_shapes[0]._transformedPath!, _paint);

    for (var stop in _notifier.value) {
      if (stop.pickupPointPosition == 0 && stop.cubeDropperPosition == 0) {
        _paint
          ..color = stop.passed ? Colors.green : Colors.grey
          ..strokeWidth = 3
          ..style = PaintingStyle.fill;
        canvas.drawPath(_shapes[1]._transformedPath!, _paint);
      }
      if (stop.pickupPointPosition == 0 && stop.cubeDropperPosition == 1) {
        _paint
          ..color = stop.passed ? Colors.green : Colors.grey
          ..strokeWidth = 3
          ..style = PaintingStyle.fill;
        canvas.drawPath(_shapes[3]._transformedPath!, _paint);
      }
      if (stop.pickupPointPosition == 1 && stop.cubeDropperPosition == 0) {
        _paint
          ..color = stop.passed ? Colors.green : Colors.grey
          ..strokeWidth = 3
          ..style = PaintingStyle.fill;
        canvas.drawPath(_shapes[2]._transformedPath!, _paint);
      }
      if (stop.pickupPointPosition == 1 && stop.cubeDropperPosition == 1) {
        _paint
          ..color = stop.passed ? Colors.green : Colors.grey
          ..strokeWidth = 3
          ..style = PaintingStyle.fill;
        canvas.drawPath(_shapes[4]._transformedPath!, _paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
