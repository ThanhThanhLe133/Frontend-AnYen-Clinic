import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

final websocketServiceProvider = Provider((ref) => WebSocketService());

class WebSocketService {
  late IO.Socket socket;
  Function(Map<String, dynamic>)? onMessageCallback;

  void connect() {
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      print('Connected to WebSocket server');
    });

    socket.onDisconnect((_) {
      print('Disconnected from WebSocket server');
    });

    socket.onError((error) {
      print('WebSocket error: $error');
    });

    socket.on('message', (data) {
      if (onMessageCallback != null) {
        onMessageCallback!(data);
      }
    });
  }

  void subscribeToTopic(String topic) {
    socket.emit('subscribe', topic);
  }

  void sendMessage(String topic, String message) {
    socket.emit('message', {
      'topic': topic,
      'content': message,
    });
  }

  void onMessageReceived(Function(Map<String, dynamic>) callback) {
    onMessageCallback = callback;
  }

  void disconnect() {
    socket.disconnect();
  }
}
