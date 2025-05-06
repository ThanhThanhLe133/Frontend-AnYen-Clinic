import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:ayclinic_doctor_admin/DOCTOR/chat/CallScreen.dart';
import 'package:ayclinic_doctor_admin/DOCTOR/chat/CameraScreen.dart';
import 'package:ayclinic_doctor_admin/dialog/option_dialog.dart';
import 'package:ayclinic_doctor_admin/widget/CustomBackButton.dart';
import 'package:ayclinic_doctor_admin/widget/buildButton.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //image
  final List<XFile> _sentImages = [];
  XFile? _image;

  //record
  final _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordedFilePath;
  String? _currentAudioPath;
  Duration _recordDuration = Duration.zero;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _recordTimer;
  Duration _currentPosition = Duration.zero;
  final Map<String, Duration> _audioDurations = {};

  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'text': 'Chào em', 'isMe': true},
    {'text': 'Dạ em chào bác sĩ', 'isMe': false},
    {'text': 'Chào em', 'isMe': true},
  ];
  bool isOnline = true;
  final ScrollController _scrollController = ScrollController();
  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty ||
        _image != null ||
        _recordedFilePath != null) {
      setState(() {
        if (_controller.text.isNotEmpty) {
          _messages.add({'text': _controller.text.trim(), 'isMe': true});
        }
        if (_image != null) {
          _messages.add({
            "text": null,
            "isMe": true,
            "imagePath": _image!.path,
          });

          _image = null; // Xóa ảnh sau khi gửi
        }
        if (_recordedFilePath != null) {
          _messages.add({
            "text": null,
            "isMe": true,
            "audioPath": _recordedFilePath,
          });
          print("FILE PATH $_recordedFilePath");
          _recordedFilePath = null;
        }

        _controller.clear();
      });

      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent, // Cuộn đến cuối
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut, // Hiệu ứng cuộn mượt mà
      );
    });
  }

  Future<void> _openCamera(BuildContext context) async {
    final XFile? image = await Navigator.push<XFile?>(
      context,
      MaterialPageRoute(builder: (context) => CameraScreen()),
    );

    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  Future<void> _startRecording(BuildContext context) async {
    final String uniqueId = Uuid().v4(); // Tạo ID ngẫu nhiên
    final String path =
        "/data/user/0/com.example.anyen_clinic/cache/audio_$uniqueId.mp3";

    bool hasMicPermission = await _audioRecorder.hasPermission();

    if (!hasMicPermission) {
      debugPrint("❌ Không có quyền ghi âm, không thể bắt đầu ghi");
      return;
    }
    await _audioRecorder.start(const RecordConfig(), path: path);
    setState(() {
      _isRecording = true;
      _recordedFilePath = path;
      _recordDuration = Duration.zero;
    });
    _recordTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _recordDuration = Duration(seconds: _recordDuration.inSeconds + 1);
      });
    });

    _showRecordingDialog(context);
  }

  Future<void> _stopRecording() async {
    if (_isRecording) {
      final path = await _audioRecorder.stop();
      final duration = await _getAudioDuration(path!);
      _recordTimer?.cancel();
      setState(() {
        _isRecording = false;
        _recordedFilePath = path;
        _recordDuration = duration;
      });
    }
  }

  Future<Duration> _getAudioDuration(String path) async {
    if (_audioDurations.containsKey(path)) {
      return _audioDurations[path]!;
    }
    await _audioPlayer.setSource(DeviceFileSource(path));
    Duration duration = await _audioPlayer.getDuration() ?? Duration.zero;
    _audioDurations[path] = duration;
    return duration;
  }

  void _playAudio(String? path) async {
    final audioPlayer = AudioPlayer();
    await audioPlayer.play(DeviceFileSource(path!));
  }

  final Map<String, Duration> _currentPositions = {};
  void _togglePlayPause(String? path) async {
    if (path == null) return;

    if (_isPlaying && path == _currentAudioPath) {
      await _audioPlayer.pause();
      setState(() {
        _currentAudioPath = null;
        _isPlaying = false;
      });
    } else {
      if (_currentAudioPath != null) {
        await _audioPlayer.stop();
      }
      _currentAudioPath = path;
      _currentPosition = Duration.zero; // Reset thời gian khi phát file mới
      await _audioPlayer.setSource(DeviceFileSource(path));

      await _audioPlayer.play(DeviceFileSource(path));

      setState(() {
        _isPlaying = true;
        _currentPositions[path] = Duration.zero;
      });

      // Lắng nghe thời gian phát
      _audioPlayer.onPositionChanged.listen((Duration position) {
        if (_currentAudioPath == path) {
          setState(() {
            _currentPositions[path] = position;
          });
        }
      });
      _audioPlayer.onPlayerComplete.listen((_) {
        if (_currentAudioPath == path) {
          setState(() {
            _isPlaying = false;
            _currentAudioPath = null;
            _currentPositions[path] = Duration.zero;
          });
        }
      });
    }
  }

  void _removeRecordedAudio() {
    setState(() {
      _recordedFilePath = null;
      _recordDuration = Duration.zero;
      _isPlaying = false;
    });
  }

  void _showRecordingDialog(BuildContext context) {
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
                await _stopRecording();
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: Text("Dừng ghi âm"),
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _audioRecorder.dispose();
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
            itemBuilder:
                (BuildContext context) => [
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
          controller: _scrollController,
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
              _buildQuestionBubble(screenWidth),
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
                ..._messages.map((message) {
                  return _buildChatBubble(
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
      bottomNavigationBar:
          isJoined
              ? KeyboardVisibilityBuilder(
                builder: (context, isKeyboardVisible) {
                  if (isKeyboardVisible) {
                    _scrollToBottom();
                  }
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom:
                          isKeyboardVisible
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
                      child: _buildMessageInput(),
                    ),
                  );
                },
              )
              : null,
    );
  }

  Widget _buildQuestionBubble(double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(left: 64),
      child: Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'abcxyzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz',
          style: TextStyle(fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildChatBubble(
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
              borderRadius:
                  isMe
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
            child: buildMessageContent(message, imagePath, audioPath, isMe),
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

  Widget buildMessageContent(
    String message,
    String? imagePath,
    String? audioPath,
    bool isMe,
  ) {
    if (message.isNotEmpty) {
      return Text(
        message,
        style: TextStyle(
          color: isMe ? Colors.white : Colors.black,
          fontSize: 14,
        ),
      );
    } else if (imagePath != null && imagePath.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(imagePath),
          width: 150,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint("Lỗi khi load ảnh: $error");
            return Icon(Icons.broken_image, size: 50);
          },
        ),
      );
    } else if (audioPath != null) {
      return FutureBuilder<Duration>(
        future:
            _audioDurations.containsKey(audioPath)
                ? Future.value(_audioDurations[audioPath])
                : _getAudioDuration(audioPath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            _audioDurations[audioPath] = snapshot.data!; // Lưu duration lại
          }

          Duration audioDuration = _audioDurations[audioPath] ?? Duration.zero;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => _togglePlayPause(audioPath),
                child: Container(
                  padding: EdgeInsets.zero,
                  margin: EdgeInsets.zero,
                  child: Icon(
                    (_isPlaying && _currentAudioPath == audioPath)
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                "${_formatDuration(_currentPositions[audioPath] ?? Duration.zero)} / ${_formatDuration(audioDuration)}",
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ],
          );
        },
      );
    }
    return SizedBox.shrink();
  }

  Widget _buildMessageInput() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_image != null)
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Image.file(File(_image!.path), height: 100),
                IconButton(
                  icon: Icon(Icons.cancel, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _image = null; // Xóa ảnh chưa gửi
                    });
                  },
                ),
              ],
            ),
          ),
        if (_recordedFilePath != null) // Hiển thị file ghi âm
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  (_isPlaying && _currentAudioPath == _recordedFilePath)
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.blue,
                ),
                onPressed: () => _togglePlayPause(_recordedFilePath),
              ),
              Text(
                (_isRecording)
                    ? _formatDuration(
                      _recordDuration,
                    ) // Hiển thị thời gian ghi âm
                    : "${_formatDuration(_currentPositions[_recordedFilePath] ?? Duration.zero)} / ${_formatDuration(_recordDuration)}",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.cancel, color: Colors.red),
                onPressed: _removeRecordedAudio,
              ),
            ],
          ),
        Container(
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.6), // Màu nền
            shape: BoxShape.circle, // Hình tròn
          ),
          child: IconButton(
            icon: Icon(Icons.camera_alt_sharp, color: Colors.white), // Màu icon
            onPressed: () async {
              PermissionStatus statusCamera = await Permission.camera.request();
              if (statusCamera.isGranted) {
                await _openCamera(context);
              } else if (statusCamera.isPermanentlyDenied) {
                showOptionDialog(
                  context,
                  "Cần quyền truy cập Camera",
                  "Vui lòng cấp quyền camera trong cài đặt để sử dụng tính năng này.",
                  "HỦY",
                  "CÀI ĐẶT",
                  () {
                    openAppSettings();
                  },
                );
              } else {
                showOptionDialog(
                  context,
                  "An yên muốn truy cập camera",
                  "Cho phép truy cập camera để chụp hình toa thuốc",
                  "TỪ CHỐI",
                  "OK",
                  () async {
                    await _openCamera(context);
                  },
                );
              }
            },
            iconSize: 20, // Điều chỉnh kích thước icon
          ),
        ),
        IconButton(
          icon: Icon(Icons.mic, color: Colors.blue.withOpacity(0.6)),
          onPressed: () async {
            PermissionStatus statusMicro =
                await Permission.microphone.request();
            if (statusMicro.isGranted) {
              await _startRecording(context);
            } else if (statusMicro.isPermanentlyDenied) {
              showOptionDialog(
                context,
                "Cần quyền truy cập Microphone",
                "Vui lòng cấp quyền Microphone trong cài đặt để sử dụng tính năng này.",
                "HỦY",
                "CÀI ĐẶT",
                () {
                  openAppSettings();
                },
              );
            } else {
              showOptionDialog(
                context,
                "An yên muốn truy cập Microphone",
                "Cho phép truy cập Microphone để ghi âm",
                "TỪ CHỐI",
                "OK",
                () async {
                  await _startRecording(context);
                },
              );
            }
          },
          iconSize: 20,
        ),
        SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _controller,
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
              _sendMessage();
            },
            onTap: () {
              _scrollToBottom();
            },
          ),
        ),
        SizedBox(width: 8),
        IconButton(
          icon: Icon(Icons.send_sharp, color: Colors.blue), // Màu icon
          onPressed: () => _sendMessage(),
          iconSize: 24,
        ),
      ],
    );
  }

  void _showIncomingCallPopup() {
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
                      Navigator.pop(context);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.call, color: Colors.green, size: 40),
                    onPressed: () {
                      Navigator.pop(context);
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
}
