import 'package:flutter/material.dart';
import 'package:ayclinic_doctor_admin/widget/PatientCardInList.dart';
import 'package:flutter/material.dart';

class PatientListScreen extends StatelessWidget {
  static const List<Map<String, String>> patients = [
    {
      'name': 'User1',
      'gender': 'Nữ',
      'dob': '13/3/2005',
      'medicalHistory': 'Không có',
      'allergies': 'Paracetamol',
      'healthDate': '04/02/25',
      'age': '20t',
      'height': '158',
      'weight': '60',
      'imageUrl':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ-ayGPkPFi0XIagaJYMqOLcG25FwFZTEn4KQ&s',
      'reviewCount': '5', // Số lượt đánh giá
      'visitCount': '10', // Số lượt khám
    },
    // Bạn có thể thêm các bệnh nhân khác ở đây
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Color(0xFF9BA5AC)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Danh sách bệnh nhân",
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(color: Color(0xFF9BA5AC), height: 1.0),
        ),
      ),
      body: ListView.builder(
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final patient = patients[index];
          return PatientCardInList(
            screenWidth: MediaQuery.of(context).size.width,
            screenHeight: MediaQuery.of(context).size.height,
            name: patient['name']!,
            gender: patient['gender']!,
            dob: patient['dob']!,
            medicalHistory: patient['medicalHistory']!,
            allergies: patient['allergies']!,
            healthDate: patient['healthDate']!,
            age: patient['age']!,
            height: patient['height']!,
            weight: patient['weight']!,
            imageUrl: patient['imageUrl']!,
            reviewCount: patient['reviewCount']!, // Truyền số lượt đánh giá
            visitCount: patient['visitCount']!, // Truyền số lượt khám
          );
        },
      ),
    );
  }
}
