import 'package:anyen_clinic/dialog/option_dialog.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Widget buildMicButton({
  required BuildContext context,
  required Future<void> Function(BuildContext) startRecording,
}) {
  return IconButton(
    icon: Icon(Icons.mic, color: Colors.blue.withOpacity(0.6)),
    iconSize: 20,
    onPressed: () async {
      PermissionStatus statusMicro = await Permission.microphone.request();
      if (statusMicro.isGranted) {
        await startRecording(context);
      } else if (statusMicro.isPermanentlyDenied) {
        showOptionDialog(
          context,
          "Cần quyền truy cập Microphone",
          "Vui lòng cấp quyền Microphone trong cài đặt để sử dụng tính năng này.",
          "HỦY",
          "CÀI ĐẶT",
          () => openAppSettings(),
        );
      } else {
        showOptionDialog(
          context,
          "An yên muốn truy cập Microphone",
          "Cho phép truy cập Microphone để ghi âm",
          "TỪ CHỐI",
          "OK",
          () async => await startRecording(context),
        );
      }
    },
  );
}
