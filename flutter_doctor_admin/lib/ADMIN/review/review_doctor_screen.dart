import 'package:ayclinic_doctor_admin/ADMIN/dashboard_admin/dashboard.dart';
import 'package:ayclinic_doctor_admin/widget/normalButton.dart';
import 'package:flutter/material.dart';

class ReviewDoctorScreen extends StatelessWidget {
  const ReviewDoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Color(0xFF9BA5AC)),
          iconSize: screenWidth * 0.08,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Đánh giá bác sĩ",
          style: TextStyle(
            color: Colors.blue,
            fontSize: screenWidth * 0.065,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(color: Color(0xFF9BA5AC), height: 1.0),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: screenWidth * 0.11,
                      backgroundImage: NetworkImage(
                        'https://i.imgur.com/Y6W5JhB.png',
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.05),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BS.CKI Macus Horizon',
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Tâm lý - Nội tổng quát',
                            softWrap: true,
                            maxLines: null,
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            'Bệnh viện ĐH Y Dược HCM Bệnh viện ĐH Y Dược HCM ',
                            softWrap: true,
                            maxLines: null,
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.01,
                  vertical: screenHeight * 0.02,
                ),
                child: Text(
                  '"Sẵn sàng lắng nghe, thấu hiểu và chia sẻ"',
                  softWrap: true,
                  maxLines: null,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.blue,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'Vui lòng dành ít phút cho chúng tôi biết cảm nhận của bạn sau cuộc tư vấn',
                softWrap: true,
                maxLines: null,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: Color(0xFF949FA6),
                  height: 1.2,
                ),
              ),
              SatisfactionWidget(screenWidth: screenWidth),
              SizedBox(height: screenHeight * 0.02),
              Text(
                "Chia sẻ thêm với mọi người cảm nhận của bạn",
                maxLines: null,
                textAlign: TextAlign.left,
                softWrap: true,
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  color: Color(0xFF40494F),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              TextField(
                style: TextStyle(fontSize: screenWidth * 0.04),
                maxLines: null,
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: Colors.blue, width: 1),
                  ),
                  hintText:
                      "Chia sẻ cảm nhận của bạn về buổi tư vấn cùng bác sĩ.\n",
                  hintStyle: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Color(0xFFD9D9D9),
                    fontWeight: FontWeight.w400,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenWidth * 0.03,
                    horizontal: screenWidth * 0.02,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.2),
              normalButton(
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                label: "Gửi đánh giá",
                nextScreen: DashboardAdmin(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SatisfactionWidget extends StatefulWidget {
  const SatisfactionWidget({super.key, required this.screenWidth});
  final double screenWidth;
  @override
  State<SatisfactionWidget> createState() => _SatisfactionWidgetState();
}

class _SatisfactionWidgetState extends State<SatisfactionWidget> {
  int selectedIndex = 0;
  final List<Map<String, dynamic>> options = [
    {"label": "Rất hài lòng", "emoji": "😍", "color": Colors.blue},
    {"label": "Hài lòng", "emoji": "😊", "color": Colors.blue},
    {"label": "Bình thường", "emoji": "😐", "color": Colors.blue},
    {"label": "Không hài lòng", "emoji": "☹️", "color": Colors.blue},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.screenWidth * 0.05,
        vertical: widget.screenWidth * 0.05,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(options.length, (index) {
          bool isSelected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
              },
              child: Container(
                height: widget.screenWidth * 0.2,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? options[index]['color'] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.5),
                              blurRadius: 5,
                            ),
                          ]
                          : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: widget.screenWidth * 0.1,
                      child: Text(
                        options[index]['label'],
                        style: TextStyle(
                          fontSize: widget.screenWidth * 0.03,
                          color:
                              isSelected
                                  ? Colors.white
                                  : const Color.fromARGB(221, 19, 4, 4),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: widget.screenWidth * 0.08,
                      child: Text(
                        options[index]['emoji'] ?? '❓',
                        style: TextStyle(fontSize: widget.screenWidth * 0.05),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
