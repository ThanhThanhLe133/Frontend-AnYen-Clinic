import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anyen_clinic/storage.dart';

class WebSocketService {
  IO.Socket? socket;
  bool isConnected = false;
  final String serverUrl = apiUrl;

  WebSocketService(); // Default to Android emulator localhost

  // Connect manually with a token
  void connect(String token,
      {Function()? onConnect, Function(dynamic)? onError}) {
    if (socket != null && isConnected) {
      onError?.call('Already connected');
      return;
    }
    socket = IO.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': {'token': token},
    });

    socket!.onConnect((_) {
      isConnected = true;
      onConnect?.call();
    });

    socket!.onDisconnect((_) {
      isConnected = false;
    });

    socket!.onError((error) {
      onError?.call(error);
    });

    socket!.onConnectError((error) {
      onError?.call(error);
    });

    socket!.connect();
  }

  void disconnect() {
    socket?.disconnect();
    socket?.dispose();
    socket = null;
    isConnected = false;
  }

  // Subscribe to a conversation/room with acknowledgement
  void subscribeToConversation(String conversationId,
      {Function(dynamic)? ack}) {
    if (!isConnected || socket == null) return;
    socket!.emitWithAck('subscribe', conversationId, ack: ack);
  }

  // Unsubscribe from a conversation/room
  void unsubscribeFromConversation(String conversationId) {
    if (!isConnected || socket == null) return;
    socket!.emit('unsubscribe', conversationId);
  }

  // Send a chat message as a JSON object
  void sendMessage(String roomId, String message) {
    if (!isConnected || socket == null) return;
    final msg = {
      'room': roomId,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    };
    socket!.emit('chatMessage', msg);
  }

  // Listen for incoming chat messages
  void onChatMessage(Function(Map<String, dynamic>) callback) {
    socket?.on('chatMessage', (data) {
      if (data is Map<String, dynamic>) {
        callback(data);
      } else if (data is Map) {
        callback(Map<String, dynamic>.from(data));
      }
    });
  }

  // Listen for user joined events
  void onUserJoined(Function(Map<String, dynamic>) callback) {
    socket?.on('userJoined', (data) {
      if (data is Map<String, dynamic>) {
        callback(data);
      } else if (data is Map) {
        callback(Map<String, dynamic>.from(data));
      }
    });
  }

  // Handle user left events
  void onUserLeft(Function(Map<String, dynamic>) callback) {
    socket?.on('userLeft', (data) {
      callback(data);
    });
  }

  // Handle call requests
  void onReceiveCall(Function(Map<String, dynamic>) callback) {
    socket?.on('receive-call', (data) {
      callback(data);
    });
  }

  // Handle call answers
  void onCallAnswered(Function(Map<String, dynamic>) callback) {
    socket?.on('call-answered', (data) {
      callback(data);
    });
  }

  // Initiate a call
  void callUser(String to, dynamic signal) {
    socket?.emit('call-user', {
      'to': to,
      'signal': signal,
    });
  }

  // Answer a call
  void answerCall(String to, dynamic signal) {
    socket?.emit('answer-call', {
      'to': to,
      'signal': signal,
    });
  }

  void dispose() {
    disconnect();
  }
}

// Provider for WebSocket service (no tokenProvider dependency)
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  return WebSocketService();
});
