import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:sm_iot_lab/constants/mqtt.dart';

class MQTTClient {
  late MqttServerClient client;
  Map<String, Function(String)> topicMessageHandlers = {};

  Future<bool> start() async {
    client = MqttServerClient(mqttServerUrl, '');
    client.port = mqttServerPort;

    client.setProtocolV311();
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.onDisconnected = _onDisconnected;
    client.onSubscribed = _onSubscribed;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(mqttClientId)
        .startClean(); // Non persistent session
    print('client connecting....');
    client.connectionMessage = connMess;

    try {
      await client.connect();
    } on Exception catch (e) {
      print('client connection exception - $e');
      client.disconnect();
    }

    /// Check we are connected
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('client connected');
    } else {
      print(
          'ERROR client connection failed - disconnecting, state is ${client.connectionStatus!.state}');
      client.disconnect();
      return false;
    }

    client.updates!.listen((messageList) {
      for (MqttReceivedMessage receivedMessage in messageList) {
        final topic = receivedMessage.topic;
        print("Received message from topic $topic");

        for (var key in topicMessageHandlers.keys) {
          if (topic.endsWith(key)) {
            print("Accepted message from topic $topic");
            final received = receivedMessage.payload as MqttPublishMessage;
            String message = MqttPublishPayload.bytesToStringAsString(
                received.payload.message);
            topicMessageHandlers[key]?.call(message);
            return;
          }
        }
      }
    });

    return true;
  }

  /// The subscribed callback
  void _onSubscribed(String topic) {
    print('Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void _onDisconnected() {
    print('OnDisconnected client callback - Client disconnection');
  }

  void subscribe(String topic) {
    print('Subscription to topic $topic');
    client.subscribe(topic, MqttQos.exactlyOnce);
  }

  void sendMessage(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    print('Publish on topic $topic');
    client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }

  void registerTopicMessageHandler(String topic, Function(String) handler) {
    topicMessageHandlers[topic] = handler;
  }
}
