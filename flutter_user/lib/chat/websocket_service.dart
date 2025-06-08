import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anyen_clinic/utils/jwt_utils.dart';
import 'package:anyen_clinic/storage.dart';

class WebSocketService {
  IO.Socket? socket;
  bool isConnected = false;
  final String serverUrl = apiUrl;
  String? userId;

  WebSocketService();

  // Connect manually with a token
  Future<void> connect(String token,
      {Function()? onConnect,
      Function(dynamic)? onError,
      Function()? onDisconnect}) async {
    if (socket != null && isConnected) {
      onError?.call('Already connected');
      return;
    }

    // Get user ID from token
    userId = await JwtUtils.getUserId();
    if (userId == null) {
      onError?.call('Failed to get user ID from token');
      return;
    }

    final completer = Completer<void>();

    socket = IO.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': {
        'token': token,
      },
    });

    socket!.onConnect((_) {
      isConnected = true;
      onConnect?.call();
      completer.complete();
    });

    socket!.onDisconnect((_) {
      isConnected = false;
      onDisconnect?.call();
    });

    socket!.onError((error) {
      onError?.call(error);
    });

    socket!.onConnectError((error) {
      onError?.call(error);
    });

    socket!.connect();
  }

  // Subscribe to a conversation/room with acknowledgement
  void subscribeToConversation(String conversationId,
      {Function(dynamic)? ack}) {
    print("trying here response");
    if (!isConnected || socket == null) return;
    print("trying to subcribe $conversationId");
    socket!.emitWithAck('subscribe', conversationId, ack: ack);
  }

  // Unsubscribe from a conversation/room
  void unsubscribeFromConversation(String conversationId) {
    if (!isConnected || socket == null) return;
    socket!.emit('unsubscribe', conversationId);
  }

  // Send a chat message
  void sendMessage(String roomId, String message) {
    if (!isConnected || socket == null) return;
    final msg = {
      'room': roomId,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      'sender': userId,
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
      if (data is Map<String, dynamic>) {
        callback(data);
      } else if (data is Map) {
        callback(Map<String, dynamic>.from(data));
      }
    });
  }

  // Handle call requests
  void onReceiveCall(Function(Map<String, dynamic>) callback) {
    socket?.on('receive-call', (data) {
      if (data is Map<String, dynamic>) {
        callback(data);
      } else if (data is Map) {
        callback(Map<String, dynamic>.from(data));
      }
    });
  }

  // Handle call answers
  void onCallAnswered(Function(Map<String, dynamic>) callback) {
    socket?.on('call-answered', (data) {
      if (data is Map<String, dynamic>) {
        callback(data);
      } else if (data is Map) {
        callback(Map<String, dynamic>.from(data));
      }
    });
  }

  //handle declined call
  void onCallDeclined(Function(Map<String, dynamic>) callback) {
    socket?.on('call-declined', (data) {
      if (data is Map<String, dynamic>) {
        callback(data);
      } else if (data is Map) {
        callback(Map<String, dynamic>.from(data));
      }
    });
  }

  // Listen for general WebSocket errors
  void onError(Function(dynamic) callback) {
    socket?.on('error', (error) {
      callback(error);
    });
  }

  // Initiate a call
  void callUser(String room, dynamic signal) {
    socket?.emit('call-user', {
      'room': room,
      'signal': signal,
    });
  }

  // Answer a call
  void answerCall(String room, dynamic signal) {
    socket?.emit('answer-call', {
      'room': room,
      'signal': signal,
    });
  }

//decline call
  void declineCall(String room) {
    socket?.emit('call-declined', {
      'room': room,
    });
  }

  void dispose() {
    disconnect();
  }

  void disconnect() {
    socket?.disconnect();
    socket?.dispose();
    socket = null;
    isConnected = false;
  }
}

// Provider for WebSocket service
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  return WebSocketService();
});
