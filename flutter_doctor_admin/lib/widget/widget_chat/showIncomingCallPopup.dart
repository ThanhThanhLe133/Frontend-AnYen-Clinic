import 'package:ayclinic_doctor_admin/DOCTOR/chat/CallScreen.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

void showIncomingCallPopup(BuildContext context) {
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
                      MaterialPageRoute(
                          builder: (context) => CallScreen(
                                roomId: "",
                              )),
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
