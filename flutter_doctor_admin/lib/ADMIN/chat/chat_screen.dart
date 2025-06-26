import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:ayclinic_doctor_admin/DOCTOR/chat/CameraScreen.dart';
import 'package:ayclinic_doctor_admin/DOCTOR/chat/SignalingService.dart';
import 'package:ayclinic_doctor_admin/dialog/snackBar.dart';
import 'package:ayclinic_doctor_admin/function.dart';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:ayclinic_doctor_admin/utils/jwt_utils.dart';

import 'package:ayclinic_doctor_admin/widget/chat_widget/services/chat_service.dart';
import 'package:ayclinic_doctor_admin/widget/chat_widget/websocket_service.dart';
import 'package:ayclinic_doctor_admin/widget/widget_chat/AudioPreview.dart';
import 'package:ayclinic_doctor_admin/widget/widget_chat/buildCameraButton.dart';
import 'package:ayclinic_doctor_admin/widget/widget_chat/buildMessageContent.dart';
import 'package:ayclinic_doctor_admin/widget/widget_chat/buildMicButton.dart';

import 'package:ayclinic_doctor_admin/widget/CustomBackButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen(
      {super.key,
      required this.conversationId,
      required this.name,
      required this.avatarUrl});
  final String conversationId;
  final String name;
  final String avatarUrl;
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
  bool isCompleted = false;

  @override
  void initState() {
    super.initState();
    chatService = ChatService();
    setUp();
  }

  void setUp() async {
    conversationId = widget.conversationId;
    initializeChat();
  }

  Future<void> initializeChat() async {
    setState(() {
      isConnecting = true;
    });

    try {
      currentUserId = await jwtUtils.getUserId();
      if (currentUserId == null) {
        showErrorSnackBar('Failed to get user information', context);
        return;
      }

      await loadMessages();

      if (!isCompleted) await setupWebSocket();
    } catch (e) {
      showErrorSnackBar('Error initializing chat: $e', context);
    } finally {
      setState(() {
        isConnecting = false;
      });
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
                  timeJoined =
                      DateFormat('dd/MM/yyyy, HH:mm').format(DateTime.now());
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
          showErrorSnackBar(
              'Join conversation failed: ${jsonJoin['mes']}', context);
        }
      } else {
        throw Exception(
            'Failed to join conversation: ${responseJoin.statusCode}');
      }
    } catch (e) {
      showErrorSnackBar('Failed: $e', context);
    } finally {
      setState(() {
        isLoadingMessages = false;
      });
    }
  }

  Future<void> setupWebSocket() async {
    webSocketService = await getWebSocketService(conversationId, context);
    webSocketService.setupWebSocket(currentUserId!, context, signaling);
    try {
      webSocketService.onChatMessage((data) {
        setState(() {
          if (data['sender'] != currentUserId) {
            print('📨 Received chat message: $data');
            messages.add({
              'content': data['message'],
              'isMe': false,
              'sender': data['sender'],
              'message_type': data['type'],
              'createdAt':
                  data['timestamp'] ?? DateTime.now().toIso8601String(),
            });
          }
        });
        scrollToBottom();
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
      final timestamp = DateTime.now().toIso8601String();

      if (image != null) {
        uploadImage(File(image!.path));
      }

      if (recordedFilePath != null) {
        uploadAudio(File(recordedFilePath!));
      }

      if (controller.text.isNotEmpty) {
        final messageText = controller.text.trim();
        print('📤 Sending message: $messageText');

        webSocketService.sendMessage(conversationId, messageText, "text");

        setState(() {
          messages.add({
            'content': messageText,
            'isMe': true,
            'createdAt': timestamp,
            'sender': currentUserId,
            'type': "text"
          });
        });
        controller.clear();
      }

      scrollToBottom();
    }
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
      showErrorSnackBar("Microphone permission required", context);
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
                backgroundImage: NetworkImage(widget.avatarUrl),
              ),
              SizedBox(width: screenWidth * 0.02),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
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
                  "Thời gian: $timeJoined",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF40494F)),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Tham gia cuộc trò chuyện",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 15, color: Color(0xFF9AA5AC)),
              ),
              SizedBox(height: 10),
              ...messages.map((message) {
                if (message['content'].isEmpty) {
                  return SizedBox();
                }
                if (message['message_type'] == 'audio') {
                  return buildChatBubble("", message['isMe'],
                      audioPath: message['content'],
                      time: formatTime(message['createdAt']));
                } else if (message['message_type'] == 'image') {
                  return buildChatBubble("", message['isMe'],
                      imagePath: message['content'],
                      time: formatTime(message['createdAt']));
                } else {
                  return buildChatBubble(message['content'], message['isMe'],
                      time: formatTime(message['createdAt']));
                }
              }),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: !isCompleted
          ? KeyboardVisibilityBuilder(
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
            )
          : null,
    );
  }

  Widget buildChatBubble(String message, bool isMe,
      {String? imagePath, String? audioPath, String? time}) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isMe) ...[
          CircleAvatar(backgroundImage: NetworkImage(widget.avatarUrl)),
          SizedBox(width: 16),
        ],
        if (isMe) ...[
          Padding(
            padding: EdgeInsets.only(right: 8, left: 64),
            child: Text(
              time ?? "",
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
              time ?? "",
              style: TextStyle(fontSize: 13, color: Color(0xFF9AA5AC)),
            ),
          ),
        ],
      ],
    );
  }

  Widget buildMessageInput() {
    return Row(
      mainAxisSize: MainAxisSize.max,
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
                      image = null; // Xóa ảnh chưa gửi
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
        buildCameraButton(openCamera: openCamera, context: context),
        buildMicButton(startRecording: startRecording, context: context),
        SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Color(0xFFECF8FF),
              hintText: 'Gõ nội dung...',
              hintStyle: TextStyle(
                fontSize: 16,
                color: Color(0xFF9AA5AC),
                fontWeight: FontWeight.w400,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(24),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
        SizedBox(width: 8),
        IconButton(
          icon: Icon(Icons.send_sharp, color: Colors.blue), // Màu icon
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
        final data = jsonDecode(response.body);
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
        webSocketService.sendMessage(conversationId, data['image'], "image");
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
        final data = jsonDecode(response.body);
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
        webSocketService.sendMessage(conversationId, data['audio'], "audio");
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
