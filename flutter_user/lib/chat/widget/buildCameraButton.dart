import 'package:anyen_clinic/dialog/option_dialog.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Widget buildCameraButton({
  required BuildContext context,
  required Future<void> Function(BuildContext) openCamera,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.blue.withOpacity(0.6),
      shape: BoxShape.circle,
    ),
    child: IconButton(
      icon: Icon(Icons.camera_alt_sharp, color: Colors.white),
      iconSize: 20,
      onPressed: () async {
        PermissionStatus statusCamera = await Permission.camera.request();
        if (statusCamera.isGranted) {
          await openCamera(context);
        } else if (statusCamera.isPermanentlyDenied) {
          showOptionDialog(
            context,
            "Cần quyền truy cập Camera",
            "Vui lòng cấp quyền camera trong cài đặt để sử dụng tính năng này.",
            "HỦY",
            "CÀI ĐẶT",
            () => openAppSettings(),
          );
        } else {
          showOptionDialog(
            context,
            "An yên muốn truy cập camera",
            "Cho phép truy cập camera để chụp hình toa thuốc",
            "TỪ CHỐI",
            "OK",
            () async => await openCamera(context),
          );
        }
      },
    ),
  );
}
