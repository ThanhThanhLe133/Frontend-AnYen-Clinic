import 'dart:io';
import 'package:ayclinic_doctor_admin/dialog/option_dialog.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool _isRearCamera = true;
  bool _flashOn = true;
  XFile? _capturedImage;
  final ImagePicker _picker = ImagePicker();
  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    cameras = await availableCameras();
    if (cameras == null || cameras!.isEmpty) {
      return;
    }
    _startCamera(_isRearCamera ? cameras!.first : cameras!.last);
  }

  void _startCamera(CameraDescription camera) {
    _cameraController = CameraController(camera, ResolutionPreset.medium);
    _cameraController!.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  void _switchCamera() {
    setState(() {
      _isRearCamera = !_isRearCamera;
    });
    _startCamera(_isRearCamera ? cameras!.first : cameras!.last);
  }

  void _toggleFlash() {
    setState(() {
      _flashOn = !_flashOn;
      _cameraController?.setFlashMode(
        _flashOn ? FlashMode.torch : FlashMode.off,
      );
    });
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile image = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = image;
      });
    } catch (e) {
      print("Lỗi chụp ảnh: $e");
    }
  }

  Future<void> takeImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _capturedImage = image;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    PermissionStatus status = await Permission.storage.request();

    if (status.isGranted) {
      takeImage();
    } else if (status.isPermanentlyDenied) {
      showOptionDialog(
        context,
        "Cần quyền truy cập Camera",
        "Vui lòng cấp quyền truy cập thư viện trong cài đặt để sử dụng tính năng này.",
        "HỦY",
        "CÀI ĐẶT",
        () {
          openAppSettings();
        },
      );
    } else {
      showOptionDialog(
        context,
        "Cho phép truy cập thư viện ảnh",
        "Ứng dụng cần quyền truy cập để chọn ảnh.",
        "TỪ CHỐI",
        "OK",
        () async {
          takeImage();
        },
      );
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_capturedImage != null) {
                Navigator.pop(context, _capturedImage!);
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Bạn chưa chọn ảnh!")));
              }
            },
            child: Text(
              "Xong",
              style: TextStyle(color: Colors.blue, fontSize: 18),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Khung preview camera
          Expanded(
            flex: 8,
            child:
                _capturedImage != null
                    ? Image.file(File(_capturedImage!.path), fit: BoxFit.cover)
                    : (_cameraController == null ||
                        !_cameraController!.value.isInitialized)
                    ? Center(child: CircularProgressIndicator())
                    : CameraPreview(_cameraController!),
          ),

          // Thanh điều khiển
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Nút chụp
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.image, size: 35),
                        onPressed: () {
                          _pickImageFromGallery();
                        },
                      ),
                      SizedBox(width: 20),
                      GestureDetector(
                        onTap: _capturePhoto,
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue,
                        ),
                      ),
                      SizedBox(width: 20),
                      IconButton(
                        icon: Icon(Icons.cameraswitch, size: 35),
                        onPressed: _switchCamera,
                      ),
                      IconButton(
                        icon: Icon(
                          _flashOn ? Icons.flash_on : Icons.flash_off,
                          size: 35,
                        ),
                        onPressed: _toggleFlash,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
