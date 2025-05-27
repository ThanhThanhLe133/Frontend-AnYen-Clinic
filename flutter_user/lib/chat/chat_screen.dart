import 'dart:async';
import 'dart:io';
import 'package:anyen_clinic/chat/widget/AudioPreview.dart';
import 'package:anyen_clinic/chat/widget/buildCameraButton.dart';
import 'package:anyen_clinic/chat/widget/buildMessageContent.dart';
import 'package:anyen_clinic/chat/widget/buildMicButton.dart';
import 'package:anyen_clinic/chat/widget/buildQuestionBubble.dart';
import 'package:anyen_clinic/widget/CustomBackButton.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:anyen_clinic/chat/CameraScreen.dart';
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
  const ChatScreen({super.key, required this.conversationId});
  final String conversationId;
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
  final List<Map<String, dynamic>> messages = [];
  bool isOnline = false;
  bool isConnecting = false;
  bool isLoadingMessages = false;
  final ScrollController scrollController = ScrollController();
  late WebSocketService webSocketService;
  late ChatService chatService;
  String? currentRoom;
  String? currentUserId;

  String getConversationId() {
    return widget.conversationId;
  }

  @override
  void initState() {
    super.initState();
    webSocketService = ref.read(webSocketServiceProvider);
    chatService = ChatService();
    _initializeChat();
  }

  Future<void> _loadMessages() async {
    if (isLoadingMessages) return;

    setState(() {
      isLoadingMessages = true;
    });

    try {
      final List<Message> apiMessages =
          await chatService.getMessages(widget.conversationId);

      setState(() {
        messages.clear();
        messages.addAll(apiMessages
            .map((msg) => {
                  'text': msg.content,
                  'isMe': msg.sender.id == currentUserId,
                  'timestamp': msg.createdAt.toIso8601String(),
                  'sender': msg.sender.id,
                  'senderName': msg.sender.name,
                  'senderAvatar': msg.sender.avatar,
                })
            .toList());
      });

      _scrollToBottom();
    } catch (e) {
      _showErrorSnackBar('Failed to load messages: $e');
    } finally {
      setState(() {
        isLoadingMessages = false;
      });
    }
  }

  Future<void> _initializeChat() async {
    setState(() {
      isConnecting = true;
    });

    try {
      // Get access token
      final accessToken = await getAccessToken();
      if (accessToken == null) {
        _showErrorSnackBar('Please login to continue');
        return;
      }

      // Get user ID
      currentUserId = await JwtUtils.getUserId();
      if (currentUserId == null) {
        _showErrorSnackBar('Failed to get user information');
        return;
      }

      // Load messages from API
      await _loadMessages();

      // Setup WebSocket connection
      await _setupWebSocket(accessToken);
    } catch (e) {
      _showErrorSnackBar('Error initializing chat: $e');
    } finally {
      setState(() {
        isConnecting = false;
      });
    }
  }

  Future<void> _setupWebSocket(String accessToken) async {
    try {
      // Connect to WebSocket with your token
      await webSocketService.connect(
        accessToken,
        onConnect: () {
          print('✅ WebSocket connected successfully');
          setState(() {
            isOnline = true;
          });
          _showSuccessSnackBar('Connected to chat server');
          // Join the room after successful connection
          _joinRoom(getConversationId());
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
          _showErrorSnackBar(errorMessage, showRetry: true);
        },
        onDisconnect: () {
          print('🔌 WebSocket disconnected');
          setState(() {
            isOnline = false;
          });
          _showErrorSnackBar('Disconnected from chat server', showRetry: true);
        },
      );

      // Listen for incoming messages
      webSocketService.onChatMessage((data) {
        print('📨 Received chat message: $data');
        setState(() {
          if (data['sender'] != currentUserId) {
            messages.add({
              'text': data['message'],
              'isMe': false,
              'timestamp':
                  data['timestamp'] ?? DateTime.now().toIso8601String(),
              'sender': data['sender'],
            });
          }
        });
        _scrollToBottom();
      });

      // Listen for user joined events
      webSocketService.onUserJoined((data) {
        print('👋 User joined: $data');
        if (data['userId'] != currentUserId) {
          _showInfoSnackBar('A user joined the chat');
        }
      });

      // Listen for user left events
      webSocketService.onUserLeft((data) {
        print('👋 User left: $data');
        if (data['userId'] != currentUserId) {
          _showInfoSnackBar('A user left the chat');
        }
      });

      // Listen for errors
      webSocketService.onError((error) {
        print('❌ WebSocket error: $error');
        _showErrorSnackBar('Chat error: $error');
      });
    } catch (e) {
      print('❌ Error setting up WebSocket: $e');
      throw e;
    }
  }

  void _joinRoom(String roomId) {
    if (!isOnline) {
      _showErrorSnackBar('Not connected to server joined room');
      return;
    }

    currentRoom = roomId;
    print('🏠 Joining room: $roomId');

    webSocketService.subscribeToConversation(
      roomId,
      ack: (response) {
        print('🏠 Subscribe response: $response');
        if (response != null && response['error'] != null) {
          _showErrorSnackBar('Error joining room: ${response['error']}');
        } else {
          _showSuccessSnackBar('Joined room: $roomId');
        }
      },
    );
  }

  void sendMessage() {
    if (controller.text.trim().isNotEmpty ||
        image != null ||
        recordedFilePath != null) {
      if (!isOnline) {
        _showErrorSnackBar('Not connected to server chat');
        return;
      }

      if (currentRoom == null) {
        _showErrorSnackBar('Please join a room first');
        return;
      }

      final timestamp = DateTime.now().toIso8601String();

      // Send text message
      if (controller.text.isNotEmpty) {
        final messageText = controller.text.trim();
        print('📤 Sending message: $messageText');

        webSocketService.sendMessage(currentRoom!, messageText);

        setState(() {
          messages.add({
            'text': messageText,
            'isMe': true,
            'timestamp': timestamp,
            'sender': currentUserId,
          });
        });
        controller.clear();
      }

      // Handle image sending
      if (image != null) {
        print('📤 Sending image: ${image!.path}');
        setState(() {
          messages.add({
            "text": null,
            "isMe": true,
            "imagePath": image!.path,
            "timestamp": timestamp,
            "sender": currentUserId,
          });
          image = null;
        });
      }

      // Handle audio sending
      if (recordedFilePath != null) {
        print('📤 Sending audio: $recordedFilePath');
        setState(() {
          messages.add({
            "text": null,
            "isMe": true,
            "audioPath": recordedFilePath,
            "timestamp": timestamp,
            "sender": currentUserId,
          });
          recordedFilePath = null;
        });
      }

      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      Future.delayed(Duration(milliseconds: 100), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _showErrorSnackBar(String message, {bool showRetry = false}) {
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
                  _initializeChat();
                },
              )
            : null,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
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
      _showErrorSnackBar("Microphone permission required");
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

    // Clean up WebSocket
    if (currentRoom != null) {
      webSocketService.unsubscribeFromConversation(currentRoom!);
    }
    webSocketService.dispose();

    // Clean up controllers and timers
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
                  "Question",
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
                return buildChatBubble(
                  message['text'] ?? "",
                  message['isMe'] ?? false,
                  imagePath: message["imagePath"] as String?,
                  audioPath: message["audioPath"] as String?,
                );
              }),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible) {
          if (isKeyboardVisible) {
            _scrollToBottom();
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
          CircleAvatar(
            backgroundImage: NetworkImage(messages.firstWhere(
              (m) => m['text'] == message,
              orElse: () => {'senderAvatar': 'assets/images/doctor.png'},
            )['senderAvatar']),
          ),
          SizedBox(width: 16),
        ],
        if (isMe) ...[
          Padding(
            padding: EdgeInsets.only(right: 8, left: 64),
            child: Text(
              DateTime.parse(messages.firstWhere(
                (m) => m['text'] == message,
                orElse: () => {'timestamp': DateTime.now().toIso8601String()},
              )['timestamp'])
                  .toString()
                  .substring(11, 16),
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
              getAudioDuration: getAudioDuration,
            ),
          ),
        ),
        if (!isMe) ...[
          Padding(
            padding: EdgeInsets.only(right: 64, left: 8),
            child: Text(
              DateTime.parse(messages.firstWhere(
                (m) => m['text'] == message,
                orElse: () => {'timestamp': DateTime.now().toIso8601String()},
              )['timestamp'])
                  .toString()
                  .substring(11, 16),
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
                _scrollToBottom();
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
}
