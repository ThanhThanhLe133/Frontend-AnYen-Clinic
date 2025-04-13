import 'package:flutter/material.dart';

import 'package:ayclinic_doctor_admin/widget/sectionTitle.dart';
import 'package:ayclinic_doctor_admin/widget/buttonReview_widget.dart';
import 'package:ayclinic_doctor_admin/widget/infoTitle_widget.dart';
import 'package:ayclinic_doctor_admin/dialog/option_dialog.dart';

class ListReviewDoctorScreen extends StatelessWidget {
  const ListReviewDoctorScreen({super.key});

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
          "Đánh giá",
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
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06,
          vertical: screenHeight * 0.01,
        ),
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
            Container(
              width: screenWidth * 0.9,
              padding: EdgeInsets.all(screenWidth * 0.02),
              margin: EdgeInsets.all(screenWidth * 0.02),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      0.1,
                    ), // Bóng đậm hơn một chút
                    blurRadius: 7, // Mở rộng bóng ra xung quanh
                    spreadRadius: 1, // Kéo dài bóng theo mọi hướng
                    offset: Offset(0, 0), // Không dịch chuyển, bóng tỏa đều
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  infoTitle(
                    title: 'Lượt tư vấn',
                    value: '100+',
                    icon: Icons.people,
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                  ),
                  Container(
                    width: 1,
                    height: screenHeight * 0.06,
                    color: Colors.black.withOpacity(0.25),
                  ),
                  infoTitle(
                    title: 'Kinh nghiệm',
                    value: '9 Năm',
                    icon: Icons.history,
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                  ),
                  Container(
                    width: 1,
                    height: screenHeight * 0.06,
                    color: Colors.black.withOpacity(0.25),
                  ),
                  infoTitle(
                    title: 'Hài lòng',
                    value: '100%',
                    icon: Icons.thumb_up,
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Tỷ lệ hài lòng: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.04,
                  ),
                ),
                Text(
                  '100%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.055,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  '/87 lượt đánh giá',
                  style: TextStyle(fontSize: screenWidth * 0.035),
                ),
              ],
            ),
            sectionTitle(
              title: 'Mức độ hài lòng',
              screenHeight: screenHeight,
              screenWidth: screenWidth,
            ),
            ratingWidget(
              screenWidth: screenWidth,
              label: "Rất hài lòng",
              percentage: 100,
            ),
            ratingWidget(
              screenWidth: screenWidth,
              label: "Hài lòng",
              percentage: 0,
            ),
            ratingWidget(
              screenWidth: screenWidth,
              label: "Bình thường",
              percentage: 0,
            ),
            ratingWidget(
              screenWidth: screenWidth,
              label: "Không hài lòng",
              percentage: 0,
            ),
            sectionTitle(
              title: 'Bình luận của khách hàng',
              screenHeight: screenHeight,
              screenWidth: screenWidth,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ButtonReview(
                  label: "Hữu ích",
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
                SizedBox(width: screenWidth * 0.05),
                ButtonReview(
                  label: "Mới nhất",
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
              ],
            ),
            ReviewList(
              screenHeight: screenHeight,
              screenWidth: screenWidth,
              reviews: reviews,
            ),
          ],
        ),
      ),
    );
  }
}

class ratingWidget extends StatelessWidget {
  const ratingWidget({
    super.key,
    required this.screenWidth,
    required this.label,
    required this.percentage,
  });

  final double screenWidth;
  final String label;
  final int percentage;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Padding(
        padding: EdgeInsets.only(bottom: screenWidth * 0.01),
        child: Row(
          children: [
            SizedBox(
              width: screenWidth * 0.3,
              child: Text(
                label,
                style: TextStyle(fontSize: screenWidth * 0.035),
              ),
            ),
            SizedBox(width: screenWidth * 0.1),
            SizedBox(
              width: screenWidth * 0.3,
              child: Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    color: Colors.blue,
                    backgroundColor: Colors.grey[300],
                  ),
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.05),
            SizedBox(
              width: screenWidth * 0.1,
              child: Text(
                '$percentage%',
                style: TextStyle(fontSize: screenWidth * 0.035),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final List<Map<String, dynamic>> reviews = [
  {
    "username": "User3",
    "date": "05/07/2024",
    "reviewText": "Bác sĩ rất tận tình và nhiệt huyết với bệnh nhân.",
    "emoji": "👍",
    "satisfactionText": "Tốt",
  },
  {
    "username": "User3",
    "date": "05/07/2024",
    "reviewText": "Bác sĩ rất tận tình và nhiệt huyết với bệnh nhân.",
    "emoji": "😊",
    "satisfactionText": "Tốt",
  },
  {
    "username": "User3",
    "date": "05/07/2024",
    "reviewText": "Bác sĩ rất tận tình và nhiệt huyết với bệnh nhân.",
    "emoji": "😍",
    "satisfactionText": "Tốt",
  },
];

class ReviewList extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;
  final List<Map<String, dynamic>> reviews;

  const ReviewList({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
    required this.reviews, // truyền từ cha xuống
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: screenHeight * 0.6,
      child: ListView.builder(
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          return ReviewCardDetail(
            username: review['username'],
            date: review['date'],
            reviewText: review['reviewText'],
            emoji: review['emoji'],
            satisfactionText: review['satisfactionText'],
            screenHeight: screenHeight,
            screenWidth: screenWidth,
          );
        },
      ),
    );
  }
}

class ReviewCardDetail extends StatelessWidget {
  final String username;
  final String date;
  final String reviewText;
  final String emoji;
  final String satisfactionText;
  final double screenWidth;
  final double screenHeight;
  const ReviewCardDetail({
    super.key,
    required this.username,
    required this.date,
    required this.reviewText,
    required this.emoji,
    required this.satisfactionText,
    required this.screenHeight,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth * 0.9,
      padding: EdgeInsets.all(screenWidth * 0.05),
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.01,
        vertical: screenWidth * 0.03,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(0xFF9AA5AC), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.person, color: Colors.white),
              ),
              SizedBox(width: screenWidth * 0.05),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.045,
                    ),
                  ),
                  Text(
                    date,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: screenWidth * 0.035,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.02),
          Row(
            children: [
              Text(emoji, style: TextStyle(fontSize: screenWidth * 0.04)),
              SizedBox(width: screenWidth * 0.01),
              Text(
                satisfactionText,
                style: TextStyle(
                  color: Colors.orange[800],
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.04,
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            reviewText,
            style: TextStyle(fontSize: screenWidth * 0.035),
            softWrap: true,
            maxLines: null,
          ),
          Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    showOptionDialog(
                      context,
                      "Ẩn đánh giá",
                      "Bạn chắc chắn muốn ẩn đánh giá này?",
                      "HUỶ",
                      "XÁC NHẬN",
                      () async {
                        // gọi API xoá

                        Navigator.pop(context);
                      },
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF40494F),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenWidth * 0.03,
                    ),
                    side: BorderSide(color: const Color(0xFFD9D9D9), width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    textStyle: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontFamily: 'Inter-Medium',
                      color: const Color(0xFFD9D9D9),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Text("Ẩn")],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
