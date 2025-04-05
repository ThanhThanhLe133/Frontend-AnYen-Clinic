import 'package:anyen_clinic/payment/PaymentOptionWidget.dart';
import 'package:anyen_clinic/settings/account_screen.dart';
import 'package:anyen_clinic/widget/CustomBackButton.dart';
import 'package:anyen_clinic/widget/DoctorCard.dart';
import 'package:anyen_clinic/widget/consultationBottomBar.dart';
import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late List<DateTime> dates;
  late int selectedDateIndex;
  late int selectedTimeIndex;
  late String selectedHour = "9:00";
  DateTime initialDate = DateTime.now();
  final List<String> times = [
    "9:00",
    "10:00",
    "11:00",
    "14:00",
    "15:00",
    "16:00"
  ];

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_loadMoreDates);
    _generateInitialDates();
    selectedDateIndex = 0;
    selectedTimeIndex = times.indexOf(selectedHour);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _generateInitialDates() {
    dates = List.generate(7, (index) => initialDate.add(Duration(days: index)));
  }

  void _loadMoreDates() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      setState(() {
        DateTime lastDate = dates.last;
        for (int i = 1; i <= 7; i++) {
          dates.add(lastDate.add(Duration(days: i)));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isSelected = true;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: CustomBackButton(),
        title: Text(
          "Thanh toán",
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
          child: Container(
            color: Color(0xFF9BA5AC),
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.question_mark,
                    size: screenWidth * 0.05,
                    color: Colors.blue,
                  ),
                  Text(
                    "Câu hỏi sẽ được gửi đến",
                    style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF40494F)),
                  ),
                ],
              ),
              SizedBox(height: 8),
              DoctorCard(
                doctorName: "BS.CKI Macus Horizon",
                specialty: "Tâm lý - Nội tổng quát",
                imageUrl: "https://i.imgur.com/Y6W5JhB.png",
              ),
              SizedBox(
                height: screenWidth * 0.03,
              ),
              Container(
                width: screenWidth * 0.9,
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.02,
                    vertical: screenWidth * 0.02),
                margin: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.1), // Bóng đậm hơn một chút
                      blurRadius: 7, // Mở rộng bóng ra xung quanh
                      spreadRadius: 1, // Kéo dài bóng theo mọi hướng
                      offset: Offset(0, 0), // Không dịch chuyển, bóng tỏa đều
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hình thức thanh toán",
                      style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF40494F)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        PaymentOptionWidget(
                            text: "Momo",
                            isMoMo: true,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() => isSelected = true);
                            },
                            screenWidth: screenWidth),
                        PaymentOptionWidget(
                            text: "Chuyển khoản ngân hàng",
                            isMoMo: false,
                            isSelected: !isSelected,
                            onTap: () {
                              setState(() => isSelected = true);
                            },
                            screenWidth: screenWidth),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
              Container(
                width: screenWidth * 0.9,
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenWidth * 0.02),
                margin: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.1), // Bóng đậm hơn một chút
                      blurRadius: 7, // Mở rộng bóng ra xung quanh
                      spreadRadius: 1, // Kéo dài bóng theo mọi hướng
                      offset: Offset(0, 0), // Không dịch chuyển, bóng tỏa đều
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hình thức tư vấn",
                      style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF40494F)),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          child: _buildOption(
                              Icons.chat_rounded, "Online", isSelected, () {
                            setState(() => isSelected = true);
                          }, screenWidth),
                        ),
                        SizedBox(
                          child: _buildOption(Icons.people_alt_rounded,
                              "Trực tiếp", !isSelected, () {
                            setState(() => isSelected = false);
                          }, screenWidth),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
              Container(
                width: screenWidth * 0.9,
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenWidth * 0.02),
                margin: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.1), // Bóng đậm hơn một chút
                      blurRadius: 7, // Mở rộng bóng ra xung quanh
                      spreadRadius: 1, // Kéo dài bóng theo mọi hướng
                      offset: Offset(0, 0), // Không dịch chuyển, bóng tỏa đều
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Đặt lịch tư vấn",
                      style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF40494F)),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Scrollbar(
                      controller: _scrollController,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: _scrollController,
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Row(
                          children: List.generate(dates.length, (index) {
                            DateTime date = dates[index];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedDateIndex = index;
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.02),
                                padding: EdgeInsets.symmetric(
                                    vertical: screenWidth * 0.01,
                                    horizontal: screenWidth * 0.02),
                                decoration: BoxDecoration(
                                  color: selectedDateIndex == index
                                      ? Colors.blue[50]
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      date.weekday == 1
                                          ? "CN"
                                          : "T${date.weekday}",
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.03,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: screenWidth * 0.02),
                                    Text(
                                      "${date.day}/${date.month}", // Ngày/Tháng
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.035,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Divider(height: 1),
                    SizedBox(height: 20),
                    Center(
                      child: Wrap(
                        spacing: 5,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: List.generate(times.length, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedTimeIndex = index;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: screenWidth * 0.02,
                                  horizontal: screenWidth * 0.04),
                              decoration: BoxDecoration(
                                color: selectedTimeIndex == index
                                    ? Colors.blue[50]
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                times[index],
                                style: TextStyle(fontSize: screenWidth * 0.04),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
              QuestionField(screenWidth: screenWidth),
              Container(
                width: screenWidth * 0.9,
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenWidth * 0.02),
                margin: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.1), // Bóng đậm hơn một chút
                      blurRadius: 7, // Mở rộng bóng ra xung quanh
                      spreadRadius: 1, // Kéo dài bóng theo mọi hướng
                      offset: Offset(0, 0), // Không dịch chuyển, bóng tỏa đều
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Chi tiết thanh toán",
                      style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF40494F)),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "1 lượt tư vấn",
                          style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: Color(0xFFDB5B8B)),
                        ),
                        Text("99.000 đ",
                            style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ConsultationBottomBar(
        screenHeight: screenHeight,
        screenWidth: screenWidth,
        content: "Tổng tiền",
        totalMoney: "99.000 đ",
        nameButton: "THANH TOÁN",
        nextScreen: AccountScreen(),
      ),
    );
  }
}

class QuestionField extends StatelessWidget {
  const QuestionField({
    super.key,
    required this.screenWidth,
  });

  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth * 0.9,
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04, vertical: screenWidth * 0.02),
      margin: EdgeInsets.all(screenWidth * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Bóng đậm hơn một chút
            blurRadius: 7, // Mở rộng bóng ra xung quanh
            spreadRadius: 1, // Kéo dài bóng theo mọi hướng
            offset: Offset(0, 0), // Không dịch chuyển, bóng tỏa đều
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Liên hệ tư vấn",
            style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
                color: Color(0xFF40494F)),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            style: TextStyle(fontSize: screenWidth * 0.04),
            maxLines: null,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Colors.blue, width: 1),
              ),
              hintText: "Nhập câu hỏi và triệu chứng bạn muốn tư vấn.\n",
              hintStyle: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: Color(0xFFD9D9D9),
                  fontWeight: FontWeight.w400),
              contentPadding: EdgeInsets.symmetric(
                  vertical: screenWidth * 0.03, horizontal: screenWidth * 0.02),
            ),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}

Widget _buildOption(IconData icon, String text, bool isSelected,
    VoidCallback onTap, double screenWidth) {
  return GestureDetector(
    onTap: onTap,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(
          scale: screenWidth / 500,
          child: Radio(
            value: true,
            groupValue: isSelected,
            onChanged: (_) => onTap(),
            activeColor: Colors.blue,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        Icon(
          icon,
          color: Colors.blue,
          size: screenWidth * 0.04,
        ),
        SizedBox(width: screenWidth * 0.01),
        Text(text,
            maxLines: null,
            softWrap: true,
            style: TextStyle(
              fontSize: screenWidth * 0.04,
            )),
      ],
    ),
  );
}
