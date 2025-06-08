import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:anyen_clinic/chat/CallScreen.dart';
import 'package:anyen_clinic/chat/services/SignalingService.dart';
import 'package:anyen_clinic/chat/widget/AudioPreview.dart';
import 'package:anyen_clinic/chat/widget/buildCameraButton.dart';
import 'package:anyen_clinic/chat/widget/buildMessageContent.dart';
import 'package:anyen_clinic/chat/widget/buildMicButton.dart';
import 'package:anyen_clinic/chat/widget/buildQuestionBubble.dart';
import 'package:anyen_clinic/makeRequest.dart';
import 'package:anyen_clinic/widget/CustomBackButton.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:anyen_clinic/chat/CameraScreen.dart';
import 'package:intl/intl.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anyen_clinic/chat/websocket_service.dart';
import 'package:anyen_clinic/storage.dart';
import 'package:anyen_clinic/utils/jwt_utils.dart';
import 'package:anyen_clinic/chat/models/message.dart';
import 'package:anyen_clinic/chat/services/chat_service.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, this.conversationId});
  final String? conversationId;
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  //image
  final List<XFile> sentImages = [];
  XFile? image;

  //record
  final audioRecorder = AudioRecorder();
  bool isRecording = false;
  bool isPlaying = false;
  String? recordedFilePath;
  String? currentAudioPath;
  Duration recordDuration = Duration.zero;
  final AudioPlayer audioPlayer = AudioPlayer();
  Timer? recordTimer;
  Duration currentPosition = Duration.zero;
  final Map<String, Duration> audioDurations = {};

  final TextEditingController controller = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  bool isOnline = true;
  bool isConnecting = false;
  bool isLoadingMessages = false;
  final ScrollController scrollController = ScrollController();
  late WebSocketService webSocketService;
  late ChatService chatService;
  final signaling = SignalingService();

  String conversationId = "";
  String currentRoom = "";
  String? currentUserId;

  String timeJoined = "";
  bool isJoined = false;

  @override
  void initState() {
    super.initState();
    webSocketService = ref.read(webSocketServiceProvider);
    chatService = ChatService();
    if (widget.conversationId != null) {
      conversationId = widget.conversationId!;
      initializeChat();
    }
  }

  Future<void> loadMessages() async {
    if (isLoadingMessages) return;

    setState(() {
      isLoadingMessages = true;
    });

    try {
      final responseJoin = await makeRequest(
          url: '$apiUrl/chat/join-conversation',
          method: 'PATCH',
          body: {"conversation_id": conversationId});
      if (responseJoin.statusCode == 200) {
        final jsonJoin = jsonDecode(responseJoin.body);
        print("joining conversation");
        if (jsonJoin['err'] == 0) {
          final response = await makeRequest(
            url: '$apiUrl/chat/conversation/$conversationId/messages',
            method: 'GET',
          );

          if (response.statusCode == 200) {
            final jsonResponse = jsonDecode(response.body);

            final data = jsonResponse['data'];

            if (jsonResponse['success'] == true) {
              setState(() {
                messages.clear();

                final List<Map<String, dynamic>> messagesData =
                    List<Map<String, dynamic>>.from(data);

                if (messagesData.isEmpty) {
                  messages = [
                    {
                      "id": "",
                      "conversation_id": "",
                      "sender": "",
                      "receiver": "",
                      "content": "",
                      "isRead": false,
                      "message_type": "",
                      "createdAt": "",
                      "isMe": false,
                    }
                  ];
                } else {
                  final String firstMessageTimeString = data.first['createdAt'];
                  final DateTime firstMessageTime =
                      DateTime.parse(firstMessageTimeString);

                  timeJoined =
                      DateFormat('dd/MM/yyyy, HH:mm').format(firstMessageTime);
                  messages = messagesData.map((message) {
                    return {
                      ...message,
                      'isMe': message['sender'] == currentUserId,
                    };
                  }).toList();
                }
              });

              scrollToBottom();
            }
          } else {
            throw Exception('Failed to load messages: ${response.statusCode}');
          }
        } else {
          // Join conversation thất bại, show lỗi
          showErrorSnackBar('Join conversation failed: ${jsonJoin['mes']}');
        }
      } else {
        throw Exception(
            'Failed to join conversation: ${responseJoin.statusCode}');
      }
    } catch (e) {
      showErrorSnackBar('Failed: $e');
    } finally {
      setState(() {
        isLoadingMessages = false;
      });
    }
  }

  Future<void> initializeChat() async {
    setState(() {
      isConnecting = true;
    });

    try {
      // Get access token
      String? accessToken = await getAccessToken();

      // Get user ID
      currentUserId = await JwtUtils.getUserId();
      if (currentUserId == null) {
        showErrorSnackBar('Failed to get user information');
        return;
      }

      await loadMessages();

      // Setup WebSocket connection
      await setupWebSocket(accessToken!);
    } catch (e) {
      showErrorSnackBar('Error initializing chat: $e');
    } finally {
      setState(() {
        isConnecting = false;
      });
    }
  }

  Future<void> setupWebSocket(String accessToken) async {
    try {
      String token = accessToken.replaceFirst("Bearer ", "");

      await webSocketService.connect(
        token,
        onConnect: () async {
          setState(() {
            isOnline = true;
          });

          print('✅ WebSocket connected successfullyyyyy');
          webSocketService.subscribeToConversation(
            conversationId,
            ack: (response) {
              print('🏠 subscribeToConversation response: $response');
              if (response != null && response['error'] != null) {
                showErrorSnackBar('Error joining room: ${response['error']}');
              } else {
                showSuccessSnackBar('Joined room: $conversationId');
              }
            },
          );

          showSuccessSnackBar('Connected to chat server');
        },
        onError: (error) {
          print('❌ WebSocket connection error: $error');
          String errorMessage = 'Connection error';
          if (error is SocketException) {
            errorMessage =
                'Cannot connect to server. Please check if the server is running.';
          } else {
            errorMessage = error.toString();
          }
          showErrorSnackBar(errorMessage, showRetry: true);
        },
        onDisconnect: () {
          print('🔌 WebSocket disconnected');
          setState(() {
            isOnline = false;
          });
          showErrorSnackBar('Disconnected from chat server', showRetry: true);
        },
      );

      // Listen for incoming messages
      webSocketService.onChatMessage((data) {
        setState(() {
          if (data['sender'] != currentUserId) {
            print('📨 Received chat message: $data');
            messages.add({
              'content': data['message'],
              'isMe': false,
              'sender': data['sender'],
              'createdAt':
                  data['timestamp'] ?? DateTime.now().toIso8601String(),
            });
          }
        });
        scrollToBottom();
      });

      // receive call
      webSocketService.onReceiveCall((data) async {
        final String fromSocketId = data['from'];
        final Map<String, dynamic> signal = data['signal'];

        // Kiểm tra tránh nhận chính mình
        if (fromSocketId != currentUserId) {
          // showInfoSnackBar('📞 Có người đang gọi cho bạn');

          showIncomingCallPopup(context, signal);
        }
      });

      //answer a call
      // webSocketService.onCallAnswered((data) {
      //   print('✅ Call was answered');
      //   if (data['sender'] != currentUserId) {
      //     showInfoSnackBar('Call has been answered');
      //   }
      // });

      // Listen for user joined events
      webSocketService.onUserJoined((data) {
        print('👋 User joined: $data');
        if (data['sender'] != currentUserId) {
          showInfoSnackBar('A user joined the chat');
        }
      });

      // Listen for user left events
      webSocketService.onUserLeft((data) {
        print('👋 User left: $data');
        if (data['sender'] != currentUserId) {
          showInfoSnackBar('A user left the chat');
        }
      });

      // Listen for errors
      webSocketService.onError((error) {
        print('❌ WebSocket error: $error');
        showErrorSnackBar('Chat error: $error');
      });
    } catch (e) {
      print('❌ Error setting up WebSocket: $e');
      rethrow;
    }
  }

  void sendMessage() {
    if (controller.text.trim().isNotEmpty ||
        image != null ||
        recordedFilePath != null) {
      //isOnline này là của user còn lại
      // if (!isOnline) {
      //   showErrorSnackBar('Not connected to server chat');
      //   return;
      // }

      final timestamp = DateTime.now().toIso8601String();

      // Handle image sending
      if (image != null) {
        uploadImage(File(image!.path));
      }

      // Handle audio sending
      if (recordedFilePath != null) {
        uploadAudio(File(recordedFilePath!));
      }

      // Send text message
      if (controller.text.isNotEmpty) {
        final messageText = controller.text.trim();
        print('📤 Sending message: $messageText');

        webSocketService.sendMessage(conversationId, messageText);

        setState(() {
          messages.add({
            'content': messageText,
            'isMe': true,
            'createdAt': timestamp,
            'sender': currentUserId,
          });
        });
        controller.clear();
      }

      scrollToBottom();
    }
  }

  void scrollToBottom() {
    if (scrollController.hasClients) {
      Future.delayed(Duration(milliseconds: 10), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 30),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void showErrorSnackBar(String message, {bool showRetry = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: showRetry
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () {
                  initializeChat();
                },
              )
            : null,
      ),
    );
  }

  void showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void showInfoSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> openCamera(BuildContext context) async {
    final XFile? imageNew = await Navigator.push<XFile?>(
      context,
      MaterialPageRoute(builder: (context) => CameraScreen()),
    );

    if (imageNew != null) {
      setState(() {
        image = imageNew;
      });
    }
  }

  Future<void> startRecording(BuildContext context) async {
    final String uniqueId = Uuid().v4();
    final String path =
        "/data/user/0/com.example.anyen_clinic/cache/audio_$uniqueId.mp3";

    bool hasMicPermission = await audioRecorder.hasPermission();

    if (!hasMicPermission) {
      print("❌ No microphone permission");
      showErrorSnackBar("Microphone permission required");
      return;
    }

    await audioRecorder.start(const RecordConfig(), path: path);
    setState(() {
      isRecording = true;
      recordedFilePath = path;
      recordDuration = Duration.zero;
    });

    recordTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          recordDuration = Duration(seconds: recordDuration.inSeconds + 1);
        });
      }
    });

    showRecordingDialog(context);
  }

  Future<void> stopRecording() async {
    if (isRecording) {
      final path = await audioRecorder.stop();
      final duration = await getAudioDuration(path!);
      recordTimer?.cancel();
      setState(() {
        isRecording = false;
        recordedFilePath = path;
        recordDuration = duration;
      });
    }
  }

  Future<Duration> getAudioDuration(String path) async {
    if (audioDurations.containsKey(path)) {
      return audioDurations[path]!;
    }
    await audioPlayer.setSource(DeviceFileSource(path));
    Duration duration = await audioPlayer.getDuration() ?? Duration.zero;
    audioDurations[path] = duration;
    return duration;
  }

  void playAudio(String? path) async {
    final audioPlayer = AudioPlayer();
    await audioPlayer.play(DeviceFileSource(path!));
  }

  final Map<String, Duration> currentPositions = {};

  void togglePlayPause(String? path) async {
    if (path == null) return;

    if (isPlaying && path == currentAudioPath) {
      await audioPlayer.pause();
      setState(() {
        currentAudioPath = null;
        isPlaying = false;
      });
    } else {
      if (currentAudioPath != null) {
        await audioPlayer.stop();
      }
      currentAudioPath = path;
      currentPosition = Duration.zero;
      await audioPlayer.setSource(DeviceFileSource(path));
      await audioPlayer.play(DeviceFileSource(path));

      setState(() {
        isPlaying = true;
        currentPositions[path] = Duration.zero;
      });

      audioPlayer.onPositionChanged.listen((Duration position) {
        if (currentAudioPath == path && mounted) {
          setState(() {
            currentPositions[path] = position;
          });
        }
      });

      audioPlayer.onPlayerComplete.listen((_) {
        if (currentAudioPath == path && mounted) {
          setState(() {
            isPlaying = false;
            currentAudioPath = null;
            currentPositions[path] = Duration.zero;
          });
        }
      });
    }
  }

  Future<void> answerCall(Map<String, dynamic> signal) async {
    final response = await makeRequest(
      url:
          '$apiUrl/chat/conversation/get-conversation/?conversation_id=$conversationId',
      method: 'GET',
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final conversation = data['data'];

      late String? otherUserId;

      if (currentUserId == conversation['user1']) {
        otherUserId = conversation['user2'];
      } else {
        otherUserId = conversation['user1'];
      }

      if (otherUserId == null || otherUserId.isEmpty) {
        showInfoSnackBar('⏳ Chưa có ai tham gia cuộc trò chuyện này');
        return;
      }
      try {
        await signaling.init();
        await signaling.setRemoteDescription(signal);

        final answer = await signaling.createAnswer();
        webSocketService.answerCall(conversationId, answer);
      } catch (e) {
        print("❌ Error while creating answer: $e");
        showInfoSnackBar("❌ Không thể tạo answer: $e");
      }
    } else {
      print("❌ Lỗi khi lấy thông tin cuộc trò chuyện: ${response.statusCode}");
      showInfoSnackBar('❌ Không thể lấy thông tin cuộc trò chuyện');
    }
  }

  void showIncomingCallPopup(
      BuildContext context, Map<String, dynamic> signal) {
    showDialog(
      context: context,
      barrierDismissible: false, // Không cho đóng khi bấm ra ngoài
      builder: (BuildContext context) {
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
                "Cuộc gọi đến",
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
                      webSocketService.declineCall(conversationId);
                      showInfoSnackBar("🚫 Bạn đã từ chối cuộc gọi");
                      Navigator.pop(context);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.call, color: Colors.green, size: 40),
                    onPressed: () async {
                      await answerCall(signal);
                      Navigator.pop(context);
                      await Future.delayed(Duration(milliseconds: 100));
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CallScreen()),
                      );
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

  void removeRecordedAudio() {
    setState(() {
      recordedFilePath = null;
      recordDuration = Duration.zero;
      isPlaying = false;
    });
  }

  void showRecordingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("Recording"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mic, size: 50, color: Colors.red),
              SizedBox(height: 10),
              Text("Recording audio..."),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await stopRecording();
                Navigator.of(context).pop();
              },
              child: Text("Stop Recording"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    print('🧹 Disposing ChatScreen');

    webSocketService.unsubscribeFromConversation(conversationId);
    webSocketService.dispose();

    scrollController.dispose();
    audioRecorder.dispose();
    audioPlayer.dispose();
    recordTimer?.cancel();
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: CustomBackButton(),
        title: Transform.translate(
          offset: Offset(-10, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundImage: AssetImage('assets/images/doctor.png'),
              ),
              SizedBox(width: screenWidth * 0.02),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BS.CKI Macus Horizon',
                      softWrap: true,
                      maxLines: null,
                      overflow: TextOverflow.visible,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: EdgeInsets.only(right: 5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isConnecting
                                ? Colors.orange
                                : (isOnline ? Colors.green : Colors.grey),
                          ),
                        ),
                        Text(
                          isConnecting
                              ? 'Connecting...'
                              : (isOnline ? 'Online' : 'Offline'),
                          style: TextStyle(
                            fontSize: 13,
                            color: isConnecting
                                ? Colors.orange
                                : (isOnline ? Colors.green : Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.list, color: Colors.black),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: "Lịch sử thanh toán",
                child: Text("Payment History"),
              ),
              PopupMenuItem<String>(
                value: "Xem thông tin bác sĩ",
                child: Text("Doctor Information"),
              ),
            ],
            onSelected: (String value) {
              // Handle menu selections
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[500],
            height: 1.0,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          controller: scrollController,
          child: Column(
            children: [
              SizedBox(height: 10),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Câu hỏi",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
              SizedBox(height: 10),
              buildQuestionBubble(screenWidth),
              SizedBox(height: 10),
              Divider(height: 1),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Time: 22/02/2025, 14h50",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF40494F)),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "BS.CKI Macus Horizon has joined the conversation",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 15, color: Color(0xFF9AA5AC)),
              ),
              SizedBox(height: 10),
              ...messages.map((message) {
                if (message['content'].isEmpty) {
                  return SizedBox();
                }
                if (message['message_type'] == 'audio') {
                  return buildChatBubble(
                    "",
                    message['isMe'],
                    audioPath: message['content'],
                  );
                } else if (message['message_type'] == 'image') {
                  return buildChatBubble(
                    "",
                    message['isMe'],
                    imagePath: message['content'],
                  );
                } else {
                  return buildChatBubble(
                    message['content'],
                    message['isMe'],
                  );
                }
              }),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible) {
          if (isKeyboardVisible) {
            scrollToBottom();
          }
          return Padding(
            padding: EdgeInsets.only(
                bottom: isKeyboardVisible
                    ? MediaQuery.of(context).viewInsets.bottom
                    : 0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFD9D9D9), width: 1),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: buildMessageInput(),
            ),
          );
        },
      ),
    );
  }

  Widget buildChatBubble(String message, bool isMe,
      {String? imagePath, String? audioPath}) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isMe) ...[
          CircleAvatar(backgroundImage: AssetImage('assets/images/doctor.png')),
          SizedBox(width: 16),
        ],
        if (isMe) ...[
          Padding(
            padding: EdgeInsets.only(right: 8, left: 64),
            child: Text(
              "19:21",
              style: TextStyle(fontSize: 13, color: Color(0xFF9AA5AC)),
            ),
          ),
        ],
        Flexible(
          child: Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue.shade500 : Colors.grey.shade200,
              borderRadius: isMe
                  ? BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    )
                  : BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
            ),
            child: MessageContent(
              message: message,
              imagePath: imagePath,
              audioPath: audioPath,
              isMe: isMe,
              isPlaying: isPlaying,
              currentAudioPath: currentAudioPath,
              audioDurations: audioDurations,
              currentPositions: currentPositions,
              togglePlayPause: togglePlayPause,
            ),
          ),
        ),
        if (!isMe) ...[
          Padding(
            padding: EdgeInsets.only(right: 64, left: 8),
            child: Text(
              "19:21",
              style: TextStyle(fontSize: 13, color: Color(0xFF9AA5AC)),
            ),
          ),
        ],
      ],
    );
  }

  Widget buildMessageInput() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (image != null)
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Image.file(File(image!.path), height: 100),
                IconButton(
                  icon: Icon(Icons.cancel, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      image = null;
                    });
                  },
                ),
              ],
            ),
          ),
        if (recordedFilePath != null)
          AudioPreview(
            isPlaying: isPlaying,
            currentAudioPath: currentAudioPath,
            recordedFilePath: recordedFilePath,
            recordDuration: recordDuration,
            currentPositions: currentPositions,
            togglePlayPause: togglePlayPause,
            removeRecordedAudio: removeRecordedAudio,
          ),
        if (image == null)
          buildCameraButton(openCamera: openCamera, context: context),
        if (recordedFilePath == null)
          buildMicButton(startRecording: startRecording, context: context),
        if (recordedFilePath == null || image == null)
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFECF8FF),
                hintText: 'Type message...',
                hintStyle: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF9AA5AC),
                    fontWeight: FontWeight.w400),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
              ),
              onSubmitted: (value) {
                sendMessage();
              },
              onTap: () {
                scrollToBottom();
              },
            ),
          ),
        IconButton(
          icon: Icon(Icons.send_sharp, color: Colors.blue),
          onPressed: () => sendMessage(),
          iconSize: 24,
        ),
      ],
    );
  }

  final timestamp = DateTime.now().toIso8601String();
  Future<void> uploadImage(File imageFile) async {
    try {
      final response = await makeRequest(
        url: '$apiUrl/chat/conversation/send-images',
        method: 'POST',
        body: {"conversation_id": conversationId},
        file: imageFile,
        fileFieldName: 'message',
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          messages.add({
            "message_type": "image",
            "isMe": true,
            "content": image!.path,
            "createdAt": timestamp,
            "sender": currentUserId,
          });
          image = null;
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi! ${response.body}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
          SnackBar(content: Text("Đã xảy ra lỗi không mong muốn. $e")));
    }
  }

  Future<void> uploadAudio(File audioFile) async {
    try {
      final response = await makeRequest(
        url: '$apiUrl/chat/conversation/send-audios',
        method: 'POST',
        body: {"conversation_id": conversationId},
        file: audioFile,
        fileFieldName: 'message',
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          messages.add({
            "text": null,
            "isMe": true,
            "content": recordedFilePath,
            "message_type": "audio",
            "createdAt": timestamp,
            "sender": currentUserId,
          });
          recordedFilePath = null;
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi khi upload âm thanh!")));
      }
    } catch (e) {
      debugPrint("Lỗi khi upload audio: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Đã xảy ra lỗi không mong muốn.")));
    }
  }
}
