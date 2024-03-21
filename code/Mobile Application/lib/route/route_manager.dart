import 'dart:async';

class Stop {
  final int pickupPointPosition;
  final int cubeDropperPosition;
  final bool passed;

  Stop({
    required this.pickupPointPosition,
    required this.cubeDropperPosition,
    required this.passed,
  });
}

class RouteManager {
  static final List<Stop> _stops = [];
  static final StreamController<List<Stop>> routeUpdateStream =
      StreamController<List<Stop>>.broadcast();

  static void startNewRoute(List<Stop> stops) {
    _stops.clear();
    for (var stop in stops) {
      _stops.add(stop);
    }

    routeUpdateStream.sink.add(_stops);
  }

  static void onRouteUpdate(
      int pickupPointPosition, int cubeDropperPosition, bool passed) {
    var s = Stop(
      pickupPointPosition: pickupPointPosition,
      cubeDropperPosition: cubeDropperPosition,
      passed: passed,
    );
    _stops[_stops.indexWhere((e) =>
        e.pickupPointPosition == pickupPointPosition &&
        e.cubeDropperPosition == cubeDropperPosition)] = s;

    routeUpdateStream.sink.add(_stops);
  }

  static void endRoute() {
    _stops.clear();
    routeUpdateStream.sink.add(_stops);
  }
}
