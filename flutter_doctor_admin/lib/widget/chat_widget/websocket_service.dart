import 'dart:async';
import 'dart:io';

import 'package:ayclinic_doctor_admin/DOCTOR/chat/CallScreen.dart';
import 'package:ayclinic_doctor_admin/dialog/snackBar.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:ayclinic_doctor_admin/utils/jwt_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:path/path.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../DOCTOR/chat/SignalingService.dart';

class WebSocketService {
  final bool _isCallInProgress = false;
  IO.Socket? socket;
  bool isConnected = false;
  final String conversationId;
  final String serverUrl = apiUrl;
  String? userId;

  WebSocketService(this.conversationId);

  // Connect manually with a token
  Future<void> connect(String token,
      {Function()? onConnect,
      Function(dynamic)? onError,
      Function()? onDisconnect}) async {
    userId = await jwtUtils.getUserId();
    if (userId == null) {
      onError?.call('Failed to get user ID from token');
      return;
    }

    final completer = Completer<void>();

    socket = IO.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'auth': {
        'token': token,
      },
    });

    socket!.onConnect((_) {
      // isConnected = true;
      subscribeToConversation(conversationId);
      onConnect?.call();
      completer.complete();
    });

    socket!.onDisconnect((_) {
      // isConnected = false;
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
    if (!isConnected || socket == null) return;
    socket!.emitWithAck('subscribe', conversationId, ack: ack);
    print('Joined room: $conversationId');
  }

  // Unsubscribe from a conversation/room
  void unsubscribeFromConversation(String conversationId) {
    print('Unsubscribing from room: $conversationId');
    if (!isConnected || socket == null) return;
    socket!.emit('unsubscribe', conversationId);
  }

  // Send a chat message
  void sendMessage(String roomId, String message, String type) {
    // if (!isConnected || socket == null) return;
    final msg = {
      'room': roomId,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      'sender': userId,
      'type': type
    };
    socket!.emit('chatMessage', msg);
  }

  // Listen for incoming chat messages
  void onChatMessage(Function(Map<String, dynamic>) callback) {
    socket?.on('chatMessage', (data) => wrapCallback(data, callback));
  }

  // Listen for user joined events
  void onUserJoined(Function(Map<String, dynamic>) callback) {
    socket?.on('userJoined', (data) => wrapCallback(data, callback));
  }

  // Handle user left events
  void onUserLeft(Function(Map<String, dynamic>) callback) {
    socket?.on('userLeft', (data) => wrapCallback(data, callback));
  }

  // Handle call requests
  void onReceiveCall(Function(Map<String, dynamic>) callback) {
    socket?.on('receive-call', (data) => wrapCallback(data, callback));
  }

//handle declined call
  void onCallUnreceived(Function(Map<String, dynamic>) callback) {
    socket?.on('call-unreceived', (data) => wrapCallback(data, callback));
  }

  //handle declined call
  void onCallDeclined(Function(Map<String, dynamic>) callback) {
    socket?.on('call-declined', (data) => wrapCallback(data, callback));
  }

  // Handle call answers
  void onCallAnswered(Function(Map<String, dynamic>) callback) {
    socket?.on('call-answered', (data) => wrapCallback(data, callback));
  }

  void onEndCall(Function(Map<String, dynamic>) callback) {
    socket?.on('call-ended', (data) => wrapCallback(data, callback));
  }

  void onEndCreatingCall(Function(Map<String, dynamic>) callback) {
    socket?.on('call-creating-ended', (data) => wrapCallback(data, callback));
  }

  void onUnavailableToken(Function(Map<String, dynamic>) callback) {
    socket?.on('unavailable', (data) => wrapCallback(data, callback));
  }

  // Listen for general WebSocket errors
  void onError(Function(dynamic) callback) {
    socket?.on('error', (error) {
      callback(error);
    });
  }

  // Initiate a call
  void callUser(String room, dynamic signal, bool isVideoCall) {
    socket?.emit('call-user',
        {'room': room, 'signal': signal, 'isVideoCall': isVideoCall});
  }

  // Handle unreceive call
  void callUnreceived() {
    socket?.emit('call-unreceived', {
      'room': conversationId,
    });
  }

  // Answer a call
  void answerCall(dynamic signal) {
    socket?.emit('answer-call', {
      'room': conversationId,
      'signal': signal,
    });
  }

//decline call
  void declineCall() {
    socket?.emit('call-declined', {
      'room': conversationId,
    });
  }

  void endCall() {
    socket?.emit('end-call', {
      'room': conversationId,
    });
  }

  void endCreatingCall() {
    socket?.emit('end-creating-call', {
      'room': conversationId,
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

  void sendIceCandidate(RTCIceCandidate candidate) {
    print("sending st here");
    print('sending st $conversationId');
    print('sending st $candidate');
    socket?.emit('ice-candidate', {
      'room': conversationId,
      'candidate': {
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      }
    });
  }

  void onReceiveIceCandidate(Function(Map<String, dynamic>) callback) {
    print("receive st here");
    socket?.on('ice-candidate-res', (data) {
      if (data is Map<String, dynamic>) {
        callback(data);
      } else if (data is Map) {
        callback(Map<String, dynamic>.from(data));
      }
    });
  }

  Future<void> setupWebSocket(String currentUserId, BuildContext context,
      SignalingService signaling) async {
    try {
      // Listen for user joined events
      onUserJoined((data) {
        print('👋 User joined: $data');
        if (data['sender'] != currentUserId) {
          showInfoSnackBar('A user joined the chat', context);
        }
      });

      // Listen for user left events
      onUserLeft((data) {
        print('👋 User left: $data');
        if (data['sender'] != currentUserId) {
          showInfoSnackBar('A user left the chat', context);
        }
      });
      //unavailable token
      onUnavailableToken((data) {
        showErrorSnackBar('❌ Kết nối WebSocket thất bại', context,
            websocket: this, showRetry: true);
      });
      //receive call
      onReceiveCall((data) {
        final String fromSocketId = data['sender'];
        final Map<String, dynamic> signal = data['signal'];
        final isVideoCall = data['isVideoCall'];
        if (fromSocketId != currentUserId) {
          showIncomingCallPopup(this, context, signal, isVideoCall);
        }
      });

      onCallUnreceived((data) async {
        if (data['sender'] != currentUserId) {
          Navigator.of(context).pop();
          showInfoSnackBar('Cuộc gọi bị nhỡ', context);
        }
        signaling.close();
      });

      // onCallDeclined((data) {
      //   print('✅ Call was declined');
      //   if (data['sender'] != currentUserId) {
      //     Navigator.of(context).pop();
      //     showInfoSnackBar('📴 Người nhận đã từ chối cuộc gọi', context);
      //   }
      // });

      onEndCall((data) async {
        await signaling.close();
        signaling.onAddRemoteStream = null;
        signaling.onSendIceCandidate = null;
        print('✅ Call was ended');
        if (data['sender'] != currentUserId) {
          CallScreenState.close();
        }
        showInfoSnackBar('📴 Cuộc gọi đã kết thúc', context);
      });

      onEndCreatingCall((data) {
        signaling.close();
        if (data['sender'] != currentUserId) {
          closeIncomingCallDialog();
        }

        showInfoSnackBar('📴 Cuộc gọi đã kết thúc', context);
      });

      // Listen for errors
      onError((error) {
        print('❌ WebSocket error: $error');
        // showErrorSnackBar('Chat error: $error');
        showErrorSnackBar(error, context, showRetry: true);
      });
    } catch (e) {
      print('❌ Error setting up WebSocket: $e');
      rethrow;
    }
  }

  Future<void> handleCallAnswered(
      Map<String, dynamic> data,
      String currentUserId,
      SignalingService signaling,
      BuildContext context,
      bool isVideoCall) async {
    showInfoSnackBar('Cuộc gọi đã được kết nối thành công!', context);

    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(
            roomId: conversationId,
            signaling: signaling,
            isVideoCall: isVideoCall,
            webSocketService: this),
      ),
    );
  }

  void answerCallComing(Map<String, dynamic> signal, BuildContext context,
      bool isVideoCall) async {
    final signaling = SignalingService();
    try {
      await signaling.init();
      await signaling.setRemoteDescription(signal);

      final answer = await signaling.createAnswer();
      answerCall(answer);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(
              roomId: conversationId,
              signaling: signaling,
              isVideoCall: isVideoCall,
              webSocketService: this),
        ),
      );
    } catch (e) {
      print("❌ Error while creating answer: $e");
      showInfoSnackBar("❌ Không thể tạo answer: $e", context);
    }
  }

  void disposeWebSocketService() {
    final service = webSocketServiceMap.remove(conversationId);
    service?.dispose();
  }
}

final Map<String, WebSocketService> webSocketServiceMap = {};

Future<WebSocketService?> getExistWebSocketService(
    String conversationId) async {
  String? accessToken = await getAccessToken();
  String token = accessToken!.replaceFirst("Bearer ", "");

  if (webSocketServiceMap.containsKey(conversationId)) {
    return webSocketServiceMap[conversationId]!;
  }
  return null;
}

Future<WebSocketService> getWebSocketService(
    String conversationId, BuildContext context) async {
  String? accessToken = await getAccessToken();
  String token = accessToken!.replaceFirst("Bearer ", "");

  if (webSocketServiceMap.containsKey(conversationId)) {
    webSocketServiceMap[conversationId]?.disconnect();
    webSocketServiceMap.remove(conversationId);
  }

  final newService = WebSocketService(conversationId);
  webSocketServiceMap[conversationId] = newService;
  try {
    await newService.connect(token);
    newService.isConnected = true;
    newService.subscribeToConversation(conversationId);
  } catch (e) {
    showErrorSnackBar('❌ Kết nối WebSocket thất bại: $e', context,
        websocket: newService, showRetry: true);
  }
  return newService;
}

void wrapCallback(dynamic data, Function(Map<String, dynamic>) callback) {
  if (data is Map<String, dynamic>) {
    callback(data);
  } else if (data is Map) {
    callback(Map<String, dynamic>.from(data));
  }
}

BuildContext? incomingCallContext;
void showIncomingCallPopup(WebSocketService webSocketService,
    BuildContext context, Map<String, dynamic> signal, bool isVideoCall) {
  showDialog(
    context: context,
    barrierDismissible: false, // Không cho đóng khi bấm ra ngoài
    builder: (BuildContext dialogContext) {
      incomingCallContext = dialogContext;
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hình đại diện người gọi
            Padding(
              padding: const EdgeInsets.all(20),
              child: CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                  "https://i.pravatar.cc/150?img=3",
                ), // Ảnh giả lập
              ),
            ),
            Text(
              isVideoCall ? "Cuộc gọi video đến" : "Cuộc gọi thoại đến",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 5),
            Text(
              "Nguyễn Văn A",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Nút nhận & từ chối cuộc gọi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.call_end, color: Colors.red, size: 40),
                  onPressed: () {
                    Navigator.pop(context);
                    webSocketService.declineCall();
                    showInfoSnackBar("🚫 Bạn đã từ chối cuộc gọi", context);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.call, color: Colors.green, size: 40),
                  onPressed: () async {
                    Navigator.pop(context);
                    webSocketService.answerCallComing(
                        signal, context, isVideoCall);
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      );
    },
  );
}

void closeIncomingCallDialog() {
  if (incomingCallContext != null &&
      Navigator.of(incomingCallContext!, rootNavigator: true).canPop()) {
    Navigator.of(incomingCallContext!, rootNavigator: true).pop();
    incomingCallContext = null;
  }
}
