//import 'package:anyen_clinic/doctor/listReview_doctor_screen.dart';
// import 'package:anyen_clinic/doctor/widget/reviewCard_widget.dart';
//import 'package:anyen_clinic/payment/payment_screen.dart';
// import 'package:anyen_clinic/widget/consultationBottomBar.dart';
// import 'package:anyen_clinic/widget/sectionTitle.dart' show sectionTitle;

import 'package:flutter/material.dart';

import 'package:ayclinic_doctor_admin/widget/DoctorCardInList.dart';
import 'package:ayclinic_doctor_admin/ADMIN/widget/menu_admin.dart';
import 'listReview_doctor_screen.dart';
import 'package:ayclinic_doctor_admin/widget/reviewCard_widget.dart';
import 'package:ayclinic_doctor_admin/widget/consultationBottomBar.dart';
import 'package:ayclinic_doctor_admin/widget/sectionTitle.dart'
    show sectionTitle;

class DoctorDetailScreen extends StatelessWidget {
  const DoctorDetailScreen({super.key});

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
          "Thông tin bác sĩ",
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
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: screenWidth * 0.18,
              backgroundImage: NetworkImage('https://i.imgur.com/Y6W5JhB.png'),
            ),
            SizedBox(height: screenHeight * 0.02),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'BS.CKI Macus Horizon',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Chuyên khoa: Tâm lý - Nội tổng quát',
                  textAlign: TextAlign.center,
                  softWrap: true,
                  maxLines: null,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'Bệnh viện ĐH Y Dược HCM',
                  textAlign: TextAlign.center,
                  softWrap: true,
                  maxLines: null,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  softWrap: true,
                  maxLines: null,
                  '"Sẵn sàng lắng nghe, thấu hiểu và chia sẻ"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.blue,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
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
                  _infoTile(
                    'Lượt tư vấn',
                    '100+',
                    Icons.people,
                    screenHeight,
                    screenWidth,
                  ),
                  Container(
                    width: 1,
                    height: screenHeight * 0.06,
                    color: Colors.black.withOpacity(0.25),
                  ),
                  _infoTile(
                    'Kinh nghiệm',
                    '9 Năm',
                    Icons.history,
                    screenHeight,
                    screenWidth,
                  ),
                  Container(
                    width: 1,
                    height: screenHeight * 0.06,
                    color: Colors.black.withOpacity(0.25),
                  ),
                  _infoTile(
                    'Hài lòng',
                    '100%',
                    Icons.thumb_up,
                    screenHeight,
                    screenWidth,
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                sectionTitle(
                  title: 'Đánh giá của khách hàng',
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: screenHeight * 0.02,
                    bottom: screenHeight * 0.01,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListReviewDoctorScreen(),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Xem thêm',
                          style: TextStyle(
                            color: Color(0xFF119CF0),
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ReviewList(screenHeight: screenHeight, screenWidth: screenWidth),
            sectionTitle(
              title: 'Thông tin chi tiết',
              screenHeight: screenHeight,
              screenWidth: screenWidth,
            ),
            _descriptionText(
              'Với nhiều năm kinh nghiệm khám và tư vấn các bệnh lý tâm thần, nội khoa, tôi luôn cố gắng lắng nghe, giúp đỡ bệnh nhân giải tỏa những lo lắng.',
              screenHeight,
              screenWidth,
            ),
            sectionTitle(
              title: 'Quá trình công tác',
              screenHeight: screenHeight,
              screenWidth: screenWidth,
            ),
            _descriptionText(
              '2015-2022: Phòng khám chuyên khoa tâm thần kinh, bác sĩ nội - tâm thần',
              screenHeight,
              screenWidth,
            ),
            sectionTitle(
              title: 'Quá trình học tập',
              screenHeight: screenHeight,
              screenWidth: screenWidth,
            ),
            _descriptionText(
              '2009-2015: Y khoa ĐH Y Dược TPHCM\n2022-2024: CKI Tâm thần, ĐH Y Khoa Phạm Ngọc Thạch',
              screenHeight,
              screenWidth,
            ),
            sectionTitle(
              title: 'Chứng chỉ hành nghề',
              screenHeight: screenHeight,
              screenWidth: screenWidth,
            ),
            _descriptionText(
              '001234 - Nội tổng quát - 17/8/2018, Sở Y tế TPHCM',
              screenHeight,
              screenWidth,
            ),
            SizedBox(height: screenHeight * 0.03),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(
    String title,
    String value,
    IconData icon,
    double screenHeight,
    double screenWidth,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            color: Color(0xFF40494F),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: screenWidth * 0.05, color: Colors.blue),
            SizedBox(width: screenWidth * 0.02),
            Text(
              value,
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ReviewList extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;
  const ReviewList({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();
    return Scrollbar(
      thumbVisibility: false,
      controller: scrollController,
      child: Container(
        height: screenHeight * 0.22,
        width: screenWidth * 0.9,
        constraints: BoxConstraints(
          minHeight: screenHeight * 0.1,
          maxHeight: screenHeight * 0.25,
        ),
        child: ListView(
          controller: scrollController,
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          children: [
            ReviewCard(
              username: "User1",
              date: "07/07/2024",
              reviewText:
                  "Bs tư vấn thân thiện, dễ hiểu và rất có tâm Bs tư vấn thân thiện, dễ hiểu và rất có tâmBs tư vấn thân thiện, dễ hiểu và rất có tâmBs tư vấn thân thiện, dễ hiểu và rất có tâm....",
              emoji: "😍",
              satisfactionText: "Rất hài lòng",
              screenHeight: screenHeight,
              screenWidth: screenWidth,
            ),
            ReviewCard(
              username: "User2",
              date: "06/07/2024",
              reviewText: "Bác sĩ giải thích chi tiết, giúp tôi an tâm hơn.",
              emoji: "😊",
              satisfactionText: "Hài lòng",
              screenHeight: screenHeight,
              screenWidth: screenWidth,
            ),
            ReviewCard(
              username: "User3",
              date: "05/07/2024",
              reviewText: "Bác sĩ rất tận tình và nhiệt huyết với bệnh nhân.",
              emoji: "👍",
              satisfactionText: "Tốt",
              screenHeight: screenHeight,
              screenWidth: screenWidth,
            ),
          ],
        ),
      ),
    );
  }
}

Widget _descriptionText(String text, double screenHeight, double screenWidth) {
  return Padding(
    padding: EdgeInsets.only(bottom: screenHeight * 0.01),
    child: Text(
      text,
      style: TextStyle(fontSize: screenWidth * 0.04, color: Color(0xFF40494F)),
    ),
  );
}
