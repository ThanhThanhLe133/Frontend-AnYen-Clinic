import 'dart:convert';

import 'package:ayclinic_doctor_admin/ADMIN/Provider/FilterOptionProvider.dart';
import 'package:ayclinic_doctor_admin/ADMIN/message/widget/MessageCard.dart';
import 'package:ayclinic_doctor_admin/ADMIN/widget/BottomFilterBar_message.dart';
import 'package:ayclinic_doctor_admin/function.dart';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ListMessageScreen extends ConsumerStatefulWidget {
  const ListMessageScreen({super.key});
  @override
  ConsumerState<ListMessageScreen> createState() =>
      _ListMessageScreenScreenState();
}

class _ListMessageScreenScreenState extends ConsumerState<ListMessageScreen> {
  List<Map<String, dynamic>> conversations = [];
  Set<Map<String, dynamic>> patientSet = {};
  Set<Map<String, dynamic>> doctorSet = {};

  Future<void> fetchMessages() async {
    final response = await makeRequest(
      url: '$apiUrl/chat/conversations',
      method: 'GET',
    );

    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tải dữ liệu.")),
      );
      Navigator.pop(context);
    } else {
      final data = jsonDecode(response.body);

      setState(() {
        conversations =
            List<Map<String, dynamic>>.from(data['data']).map((conversation) {
          final patient = conversation['patient'];
          final doctor = conversation['doctor'];

          if (patient != null) {
            bool existsPatient =
                patientSet.any((p) => p['id'] == patient['patient_id']);
            if (!existsPatient) {
              patientSet.add({
                'id': patient['patient_id'],
                'name': patient['fullname'],
              });
            }
          }

          if (doctor != null) {
            bool existsDoctor =
                doctorSet.any((d) => d['id'] == doctor['doctor_id']);
            if (!existsDoctor) {
              doctorSet.add({
                'id': doctor['doctor_id'],
                'name': doctor['name'],
              });
            }
          }
          return {
            ...conversation,
            'patient_id': patient?['patient_id'],
            'doctor_id': doctor?['doctor_id'],
            'name': patient?['fullname'] ?? doctor?['name'],
            'avatar_url': patient?['avatar_url'] ??
                doctor?['avatar_url'] ??
                'assets/images/user.png',
          };
        }).toList();
      });
    }
  }

  List<Map<String, dynamic>> getFilteredSortedConversations() {
    final isNewest = ref.watch(isNewestProvider) ?? true;
    final selectedDate = ref.watch(dateTimeProvider);
    final selectedDoctorId = ref.watch(selectedDoctorProvider);
    final selectedPatientId = ref.watch(selectedPatientProvider);

    List<Map<String, dynamic>> filtered = conversations.where((c) {
      if (selectedDate != null) {
        final conversationDate = DateTime.parse(c['updatedAt']).toLocal();

        if (conversationDate.year != selectedDate.year ||
            conversationDate.month != selectedDate.month ||
            conversationDate.day != selectedDate.day) {
          return false;
        }
      }

      if (selectedDoctorId != 'all' &&
          c['doctor_id'].toString() != selectedDoctorId) {
        return false;
      }

      if (selectedPatientId != 'all' &&
          c['patient_id'].toString() != selectedPatientId) {
        return false;
      }

      return true;
    }).toList();

    // Sắp xếp theo ngày hẹn
    filtered.sort((a, b) {
      DateTime dateA = DateTime.parse(a['updatedAt']).toLocal();
      DateTime dateB = DateTime.parse(b['updatedAt']).toLocal();
      return isNewest ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
    });

    return filtered;
  }

  @override
  void initState() {
    super.initState();
    fetchMessages();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(isNewestProvider.notifier).reset();
      ref.read(dateTimeProvider.notifier).clear();
      ref.read(isReviewProvider.notifier).reset();
      ref.read(selectedPatientProvider.notifier).state = "all";
      ref.read(selectedDoctorProvider.notifier).state = "all";
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final filteredConversations = getFilteredSortedConversations();
    return Scaffold(
      backgroundColor: Colors.white,
      body: (filteredConversations.isEmpty)
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 50.0, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "Chưa có cuộc trò chuyện nào",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: filteredConversations.length,
              itemBuilder: (context, index) {
                return MessageCard(
                  patientId: filteredConversations[index]['patient_id'] ?? "",
                  doctorId: filteredConversations[index]['doctor_id'] ?? "",
                  name: filteredConversations[index]['name'],
                  avatarUrl: filteredConversations[index]['avatar_url'],
                  date: getFormattedDate(
                      filteredConversations[index]['createdAt']),
                  time: getFormattedTime(
                      filteredConversations[index]['createdAt']),
                  conversationId: filteredConversations[index]['id'],
                  isPatient:
                      filteredConversations[index]['patient_id'] != null &&
                          filteredConversations[index]['patient_id']
                              .toString()
                              .isNotEmpty,
                  unreadMessages:
                      filteredConversations[index]['unreadMessages'] ?? 0,
                  onPopBack: () {
                    fetchMessages();
                  },
                );
              },
            ),
      bottomNavigationBar: BottomFilterBarMessage(
        screenWidth: screenWidth,
        doctorSet: doctorSet,
        patientSet: patientSet,
      ),
    );
  }
}
