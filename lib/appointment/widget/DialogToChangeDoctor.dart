import 'package:anyen_clinic/appointment/changeDoctor_screen.dart';
import 'package:flutter/material.dart';

void showOptionDialogToChangeDoctor(BuildContext context, String title,
    String content, String cancel, String confirm) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                content,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                "Lưu ý: Phí chênh lệch có thể phát sinh nếu bạn thực hiện thay đổi",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.red),
              ),
              SizedBox(height: 10),
              Divider(height: 1),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        cancel,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  Container(width: 1, height: 50, color: Colors.grey[400]),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChangeDoctorScreen()),
                        );
                      },
                      child: Text(
                        confirm,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
