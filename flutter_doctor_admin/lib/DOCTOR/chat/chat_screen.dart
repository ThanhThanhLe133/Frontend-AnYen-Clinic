import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:ayclinic_doctor_admin/DOCTOR/chat/CameraScreen.dart';
import 'package:ayclinic_doctor_admin/widget/widget_chat/AudioPreview.dart';
import 'package:ayclinic_doctor_admin/widget/widget_chat/buildCameraButton.dart';
import 'package:ayclinic_doctor_admin/widget/widget_chat/buildMessageContent.dart';
import 'package:ayclinic_doctor_admin/widget/widget_chat/buildMicButton.dart';
import 'package:ayclinic_doctor_admin/widget/widget_chat/buildQuestionBubble.dart';
import 'package:ayclinic_doctor_admin/dialog/option_dialog.dart';
import 'package:ayclinic_doctor_admin/widget/CustomBackButton.dart';
import 'package:ayclinic_doctor_admin/widget/buildButton.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.appointment_id});
  final String? appointment_id;
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
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
  final List<Map<String, dynamic>> messages = [
    {'text': 'Chào em', 'isMe': true},
    {'text': 'Dạ em chào bác sĩ', 'isMe': false},
    {'text': 'Chào em', 'isMe': true},
  ];
  bool isOnline = true;
  final ScrollController scrollController = ScrollController();
  void sendMessage() {
    if (controller.text.trim().isNotEmpty ||
        image != null ||
        recordedFilePath != null) {
      setState(() {
        if (controller.text.isNotEmpty) {
          messages.add({'text': controller.text.trim(), 'isMe': true});
        }
        if (image != null) {
          messages.add({
            "text": null,
            "isMe": true,
            "imagePath": image!.path,
          });

          image = null; // Xóa ảnh sau khi gửi
        }
        if (recordedFilePath != null) {
          messages.add({
            "text": null,
            "isMe": true,
            "audioPath": recordedFilePath,
          });
          print('FILE PATH $recordedFilePath');
          recordedFilePath = null;
        }

        controller.clear();
      });

      scrollToBottom();
    }
  }

  void scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent, // Cuộn đến cuối
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut, // Hiệu ứng cuộn mượt mà
      );
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

  @override
  void dispose() {
    scrollController.dispose();
    audioRecorder.dispose();
    super.dispose();
  }

  //xử lý nút tham gia
  bool isJoined = false;
  String currentTime = "";

  void joinAction() {
    setState(() {
      isJoined = true;
      currentTime = DateFormat('dd/MM/yyyy, HH:mm').format(DateTime.now());
    });
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
                            color: isOnline ? Colors.green : Colors.grey,
                          ),
                        ),
                        Text(
                          isOnline ? 'Đang online' : 'Đang offline',
                          style: TextStyle(
                            fontSize: 13,
                            color: isOnline ? Colors.green : Colors.grey,
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
              onPressed: () {
                // TODO: xử lý gọi điện
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
                    "Thời gian: $currentTime",
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
                  return buildChatBubble(
                    message['text'] ?? "",
                    message['isMe'] ?? false,
                    imagePath: message["imagePath"] as String?,
                    audioPath: message["audioPath"] as String?,
                  );
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
              getAudioDuration: getAudioDuration,
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
        if (recordedFilePath != null) // Hiển thị file ghi âm
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
}
