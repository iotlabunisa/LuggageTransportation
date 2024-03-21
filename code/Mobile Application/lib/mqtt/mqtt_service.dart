import 'dart:async';
import 'dart:convert';

import 'package:sm_iot_lab/mqtt/mqtt_client.dart';
import 'package:sm_iot_lab/route/route_manager.dart';

enum ComponentType {
  scanner,
  pickupPoint,
}

class CubeScannedMessage {
  final int cubeScanner;
  final String message;

  CubeScannedMessage({required this.cubeScanner, required this.message});
}

class ComponentStatusMessage {
  final ComponentType type;
  final int position;
  final String message;

  ComponentStatusMessage({
    required this.type,
    required this.position,
    required this.message,
  });
}

class MQTTService {
  static MQTTClient client = MQTTClient();

  static final List<ComponentStatusMessage> _componentStatus =
      List.empty(growable: true);

  static final StreamController<CubeScannedMessage> currentQRcodeScanned =
      StreamController<CubeScannedMessage>.broadcast();
  static final StreamController<ComponentStatusMessage> componentsStatus =
      StreamController<ComponentStatusMessage>.broadcast();
  static final StreamController<ComponentStatusMessage> carRouteUpdate =
      StreamController<ComponentStatusMessage>.broadcast();

  static Future<void> setup() async {
    bool connected = false;
    while (!connected) {
      connected = await client.start();
    }

    client.subscribe("sm_iot_lab/pickup_point/+/cube/insert/response");
    client.subscribe("sm_iot_lab/pickup_point/+/cube/+/release/response");
    client.subscribe("sm_iot_lab/cube_scanner/+/cube/scanned");
    client.subscribe("sm_iot_lab/scanner/+/status");
    client.subscribe("sm_iot_lab/pickup_point/+/status");

    client.subscribe("sm_iot_lab/car/route/start");
    client.subscribe("sm_iot_lab/car/route/end");
    client.subscribe("sm_iot_lab/car/route/update");

    client.registerTopicMessageHandler(
        "cube/insert/response", onCubeInsertedMessage);
    client.registerTopicMessageHandler(
        "cube/release/response", onCubeReleasedMessage);
    client.registerTopicMessageHandler(
        "0/cube/scanned", (String message) => onCubeScanned(0, message));
    client.registerTopicMessageHandler(
        "1/cube/scanned", (String message) => onCubeScanned(1, message));
    client.registerTopicMessageHandler(
      "scanner/0/status",
      (String message) =>
          onComponentStatusUpdate(0, ComponentType.scanner, message),
    );
    client.registerTopicMessageHandler(
      "scanner/1/status",
      (String message) =>
          onComponentStatusUpdate(1, ComponentType.scanner, message),
    );
    client.registerTopicMessageHandler(
      "pickup_point/0/status",
      (String message) =>
          onComponentStatusUpdate(0, ComponentType.pickupPoint, message),
    );
    client.registerTopicMessageHandler(
      "pickup_point/1/status",
      (String message) =>
          onComponentStatusUpdate(1, ComponentType.pickupPoint, message),
    );

    client.registerTopicMessageHandler(
        "car/route/start", (String message) => onCarRouteStart(message));
    client.registerTopicMessageHandler(
        "car/route/end", (String message) => onCarRouteEnd(message));
    client.registerTopicMessageHandler(
        "car/route/update", (String message) => onCarRouteUpdate(message));
  }

  static void onCubeInsertedMessage(String message) {
    // process the message
  }

  static void onCubeReleasedMessage(String message) {
    // process the message
  }

  static void onCubeScanned(int cubeScanner, String message) {
    currentQRcodeScanned.sink
        .add(CubeScannedMessage(cubeScanner: cubeScanner, message: message));
  }

  static void onComponentStatusUpdate(
      int position, ComponentType type, String message) {
    print("status update");

    _componentStatus
        .removeWhere((e) => e.type == type && e.position == position);
    _componentStatus.add(ComponentStatusMessage(
        type: type, position: position, message: message));

    componentsStatus.sink.add(
      ComponentStatusMessage(type: type, position: position, message: message),
    );
  }

  static List<ComponentStatusMessage> getLastComponentStatusMessages() {
    return _componentStatus;
  }

  static void onCarRouteUpdate(String message) {
    // final body = jsonDecode(message);

    RouteManager.onRouteUpdate(
        int.parse(message[1]), int.parse(message[3]), true);
  }

  static void onCarRouteStart(String message) {
    final body = jsonDecode(message);
    List<Stop> stops = List.empty(growable: true);

    for (var stop in body) {
      stops.add(Stop(
        pickupPointPosition: int.parse(stop[1]),
        cubeDropperPosition: int.parse(stop[3]),
        passed: false,
      ));
    }

    RouteManager.startNewRoute(stops);
  }

  static void onCarRouteEnd(String message) {
    RouteManager.endRoute();
  }
}
