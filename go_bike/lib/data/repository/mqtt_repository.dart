import 'package:mqtt_client/mqtt_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttRepository {
  final MqttServerClient _client = MqttServerClient.withPort(
      dotenv.env['MQTT_HOST']!,
      dotenv.env['MQTT_USERNAME']!,
      int.parse(dotenv.env['MQTT_PORT']!));

  _onDisconnected() {
    print('MQTT: Disconnected');
    _client.connect();
  }

  _onConnected() {
    print('MQTT: Connected');
    _client.subscribe("bike/position", MqttQos.exactlyOnce);
  }

  _onSubscribed(String topic) {
    print('MQTT: Subscribed to $topic');
    // _mqttClient.publishMessage(topic, MqttQos.exactlyOnce, data)
  }

  _onSubscribeFail(String? topic) {
    print('MQTT: Subscribe failed to $topic');
  }

  Future connect() async {
    _client.logging(on: true);
    _client.onDisconnected = _onDisconnected;
    _client.onConnected = _onConnected;
    _client.onSubscribed = _onSubscribed;
    _client.onSubscribeFail = _onSubscribeFail;

    print(dotenv.env['MQTT_USERNAME']!);
    print(dotenv.env['MQTT_PASSWORD']!);
    final connMessage = MqttConnectMessage()
        .authenticateAs(
            dotenv.env['MQTT_USERNAME']!, dotenv.env['MQTT_PASSWORD']!)
        .withWillTopic('bike/position')
        .withWillMessage('Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    _client.connectionMessage = connMessage;
    try {
      await _client.connect();
    } catch (e) {
      print('Exception: $e');
      _client.disconnect();
    }

    _client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttMessage message = c[0].payload;
      // final payload =
      // MqttPublishPayload.bytesToStringAsString(message.payload.message);

      // print('Received message:$payload from topic: ${c[0].topic}>');
    });

    // _client.setProtocolV311();
    // _client.connect(dotenv.env['MQTT_USERNAME']!, dotenv.env['MQTT_PASSWORD']!);
    // _client.updates?.listen(_onMessage);
  }
}
