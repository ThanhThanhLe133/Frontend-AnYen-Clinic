import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:ayclinic_doctor_admin/DOCTOR/chat/CallScreen.dart';
import 'package:ayclinic_doctor_admin/DOCTOR/chat/signalingService.dart';
import 'package:ayclinic_doctor_admin/widget/chat_widget/models/message.dart';
import 'package:ayclinic_doctor_admin/DOCTOR/chat/CameraScreen.dart';
import 'package:ayclinic_doctor_admin/widget/chat_widget/services/chat_service.dart';
import 'package:ayclinic_doctor_admin/widget/chat_widget/websocket_service.dart';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:ayclinic_doctor_admin/utils/jwt_utils.dart';
import 'package:ayclinic_doctor_admin/widget/widget_chat/AudioPreview.dart';
import 'package:ayclinic_doctor_admin/widget/widget_chat/buildCameraButton.dart';
import 'package:ayclinic_doctor_admin/widget/widget_chat/buildMessageContent.dart';
import 'package:ayclinic_doctor_admin/widget/widget_chat/buildMicButton.dart';
import 'package:ayclinic_doctor_admin/widget/widget_chat/buildQuestionBubble.dart';
import 'package:ayclinic_doctor_admin/dialog/option_dialog.dart';
import 'package:ayclinic_doctor_admin/widget/CustomBackButton.dart';
import 'package:ayclinic_doctor_admin/widget/buildButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:ayclinic_doctor_admin/widget/chat_widget/models/message.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, this.appointmentId, this.conversationId});
  final String? appointmentId;
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
  WebSocketService webSocketService = WebSocketService();
  late ChatService chatService;
  String? currentUserId;
  String conversationId = "";
  final signaling = SignalingService();

  //xử lý nút tham gia (nếu chưa có conversationId)
  bool isJoined = false;
  String timeJoined = "";
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
      isJoined = true;
    });

    try {
      // Get access token
      String? accessToken = await getAccessToken();

      // Get user ID
      currentUserId = await jwtUtils.getUserId();
      if (currentUserId == null) {
        showErrorSnackBar('Failed to get user information');
        return;
      }

      // Load messages from API
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
        onConnect: () {
          print('✅ WebSocket connected successfully');

          setState(() {
            isOnline = true;
          });
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("WebSocket3")));
          print('🔌 WebSocket disconnected');
          setState(() {
            isOnline = false;
          });
          showErrorSnackBar('Disconnected from chat server', showRetry: true);
        },
      );

      // Listen for incoming messages
      webSocketService.onChatMessage((data) {
        print('📨 Received chat message: $data');
        setState(() {
          if (data['sender'] != currentUserId) {
            messages.add({
              'content': data['message'],
              'isMe': false,
              'createdAt':
                  data['timestamp'] ?? DateTime.now().toIso8601String(),
              'sender': data['sender'],
            });
          }
        });
        scrollToBottom();
      });

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

      // receive call
      // webSocketService.onReceiveCall((data) {
      //   print('📞 Incoming call from $data');
      //   if (data['sender'] != currentUserId) {
      //     showInfoSnackBar('Someone is calling you');
      //   }
      // });

      // answer a call
      webSocketService.onCallAnswered((data) {
        print('✅ Call was answered');
        if (data['sender'] != currentUserId) {
          showInfoSnackBar('Cuộc gọi đã được kết nối thành công!');
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CallScreen(roomId: conversationId)),
          );
        }
      });

      // answer a call
      webSocketService.onCallDeclined((data) {
        print('✅ Call was declined');
        if (data['sender'] != currentUserId) {
          showInfoSnackBar('📴 Người nhận đã từ chối cuộc gọi');
        }
      });

      // Listen for errors
      webSocketService.onError((error) {
        print('❌ WebSocket error: $error');
        // showErrorSnackBar('Chat error: $error');
        showErrorSnackBar(error, showRetry: true);
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
      // if (!isOnline) {
      //   showErrorSnackBar('Not connected to server chat');
      //   return;
      // }
      final timestamp = DateTime.now().toIso8601String();
      // Handle image sending
      if (image != null) {
        print('📤 Sending image: ${image!.path}');
        uploadImage(File(image!.path));
      }

      // Handle audio sending
      if (recordedFilePath != null) {
        print('📤 Sending audio: $recordedFilePath');
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

  Future<void> createCall() async {
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

      // Kiểm tra nếu chưa có người còn lại tham gia
      if (otherUserId == null || otherUserId.isEmpty) {
        showInfoSnackBar('⏳ Chưa có ai tham gia cuộc trò chuyện này');
        return;
      }

      await signaling.init();

      final offerSignal = await signaling.createOffer();

      webSocketService.callUser(conversationId, offerSignal);
    } else {
      print("❌ Lỗi khi lấy thông tin cuộc trò chuyện: ${response.statusCode}");
      showInfoSnackBar('❌ Không thể lấy thông tin cuộc trò chuyện');
    }
  }

  void scrollToBottom() {
    Future.delayed(Duration(milliseconds: 10), () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 30),
        curve: Curves.easeOut,
      );
    });
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
    final String uniqueId = Uuid().v4(); // Tạo ID ngẫu nhiên
    final String path =
        "/data/user/0/com.example.anyen_clinic/cache/audio_$uniqueId.mp3";

    bool hasMicPermission = await audioRecorder.hasPermission();

    if (!hasMicPermission) {
      debugPrint("❌ Không có quyền ghi âm, không thể bắt đầu ghi");
      return;
    }
    await audioRecorder.start(const RecordConfig(), path: path);
    setState(() {
      isRecording = true;
      recordedFilePath = path;
      recordDuration = Duration.zero;
    });
    recordTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        recordDuration = Duration(seconds: recordDuration.inSeconds + 1);
      });
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

  void removeRecordedAudio() {
    setState(() {
      recordedFilePath = null;
      recordDuration = Duration.zero;
      isPlaying = false;
    });
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
      currentPosition = Duration.zero; // Reset thời gian khi phát file mới
      await audioPlayer.setSource(DeviceFileSource(path));

      await audioPlayer.play(DeviceFileSource(path));

      setState(() {
        isPlaying = true;
        currentPositions[path] = Duration.zero;
      });

      // Lắng nghe thời gian phát
      audioPlayer.onPositionChanged.listen((Duration position) {
        if (currentAudioPath == path) {
          setState(() {
            currentPositions[path] = position;
          });
        }
      });
      audioPlayer.onPlayerComplete.listen((_) {
        if (currentAudioPath == path) {
          setState(() {
            isPlaying = false;
            currentAudioPath = null;
            currentPositions[path] = Duration.zero;
          });
        }
      });
    }
  }

  void showRecordingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Ngăn người dùng thoát bằng cách bấm ngoài
      builder: (context) {
        return AlertDialog(
          title: Text("Đang ghi âm"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mic, size: 50, color: Colors.red),
              SizedBox(height: 10),
              Text("Đang ghi âm..."),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await stopRecording();
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: Text("Dừng ghi âm"),
            ),
          ],
        );
      },
    );
  }

  Future<void> joinAction() async {
    final response = await makeRequest(
        url: '$apiUrl/chat/create-conversation',
        method: 'POST',
        body: {"appointment_id": widget.appointmentId});
    final responseData = jsonDecode(response.body);
    if (response.statusCode != 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(responseData['mes'])));
    } else {
      setState(() {
        conversationId = responseData['data']['id'];
        isJoined = true;
        timeJoined = DateFormat('dd/MM/yyyy, HH:mm')
            .format(DateTime.parse(responseData['data']['createdAt']));
      });
      initializeChat();
    }
  }

  @override
  void dispose() {
    print('🧹 Disposing ChatScreen');

    webSocketService.unsubscribeFromConversation(conversationId);
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundImage: AssetImage('assets/images/user.png'),
              ),
              SizedBox(width: screenWidth * 0.02),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User1',
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
                            color: isConnecting ? Colors.green : Colors.grey,
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
          if (isJoined)
            IconButton(
              icon: Icon(Icons.call, size: 18, color: Colors.blue),
              onPressed: () async {
                print("📞 Calling...");
                await createCall();
              },
            ),
          if (isJoined)
            IconButton(
              icon: Icon(Icons.videocam, size: 18, color: Colors.blue),
              onPressed: () {
                // TODO: xử lý video call
              },
            ),
          PopupMenuButton<String>(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            icon: Icon(Icons.list, color: Colors.black),
            elevation: 4,
            color: Colors.white,
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: "Xem thông tin bệnh nhân",
                child: Text("Xem thông tin bệnh nhân"),
              ),
              PopupMenuItem<String>(
                value: "Kết thúc tư vấn",
                child: Text("Kết thúc tư vấn"),
              ),
              PopupMenuItem<String>(
                value: "Yêu cầu xem kết quả trắc nghiệm",
                child: Text("Yêu cầu xem kết quả trắc nghiệm"),
              ),
            ],
            onSelected: (String value) {
              switch (value) {
                case "Xem thông tin bệnh nhân":
                  // showPatientInfoDialog(context);
                  break;
                case "Kết thúc tư vấn":
                  showOptionDialog(
                    context,
                    "Xác nhận kết thúc",
                    "Bạn muốn xác nhận kết thúc ca tư vấn này?",
                    "HUỶ",
                    "ĐỒNG Ý",
                    null,
                  );
                  break;
                case "Yêu cầu xem kết quả trắc nghiệm":
                  showOptionDialog(
                    context,
                    "Yêu cầu xem KQ trắc nghiệm",
                    "Bạn có chắc chắn muốn yêu cầu xem kết quả trắc nghiệm tâm lý của bệnh nhân này?",
                    "HUỶ",
                    "ĐỒNG Ý",
                    null,
                  );
                  break;
                default:
                  break;
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(color: Colors.grey[500], height: 1.0),
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
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 10),
              buildQuestionBubble(screenWidth),
              SizedBox(height: 10),
              if (!isJoined) ...[
                CustomButton(
                  text: "THAM GIA",
                  isPrimary: true,
                  screenWidth: screenWidth,
                  onPressed: joinAction,
                ),
              ],
              if (isJoined) ...[
                Divider(height: 1),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Thời gian: $timeJoined",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF40494F),
                    ),
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: isJoined
          ? KeyboardVisibilityBuilder(
              builder: (context, isKeyboardVisible) {
                if (isKeyboardVisible) {
                  scrollToBottom();
                }
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: isKeyboardVisible
                        ? MediaQuery.of(context).viewInsets.bottom
                        : 0,
                  ), // Đẩy lên khi bàn phím mở
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Color(0xFFD9D9D9), width: 1),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                    child: buildMessageInput(),
                  ),
                );
              },
            )
          : null,
    );
  }

  Widget buildChatBubble(
    String message,
    bool isMe, {
    String? imagePath,
    String? audioPath,
  }) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isMe) ...[
          CircleAvatar(backgroundImage: AssetImage('assets/images/user.png')),
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

//tạo ô nhập
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
