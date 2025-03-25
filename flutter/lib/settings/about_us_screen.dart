import 'package:flutter/material.dart';
// import 'package:an_yen_clinic/gen/assets.gen.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.width;

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
          "Về chúng tôi",
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
      body: Expanded(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: screenHeight * 0.05,
              ),
              //logo
              SizedBox(
                width: screenWidth * 0.5,
                height: screenHeight * 0.5,
                child: Image.asset(
                  "assets/images/logo.png",
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(
                height: screenHeight * 0.02,
              ),

              Text(
                'An Yên',
                style: TextStyle(
                  fontSize: screenWidth * 0.08,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter-Medium',
                  color: Color(0xFF1CB6E5),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.1,
                    vertical: screenWidth * 0.05),
                child: Text(
                  'Chúng tôi cung cấp các dịch vụ tham vấn và trị liệu tâm lý chuyên sâu, giúp bạn vượt qua căng thẳng, lo âu, trầm cảm và những khó khăn trong cuộc sống',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Color(0xFFDE8C88),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              ContactRow(
                  screenWidth: screenWidth,
                  text: " 123 Lê Duẩn, Bến Nghé, Q1, Tp. Hcm",
                  icon: Icons.location_on,
                  color: Colors.red),
              SizedBox(height: screenHeight * 0.05),
              ContactRow(
                  screenWidth: screenWidth,
                  text: " cskh@anyen.com",
                  icon: Icons.mail,
                  color: Colors.blue),
              SizedBox(height: screenHeight * 0.05),
              ContactRow(
                  screenWidth: screenWidth,
                  text: " 012 345 6789",
                  icon: Icons.phone,
                  color: Colors.green),
              Spacer(),
              Container(
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.only(bottom: screenHeight * 0.03),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocialButton(
                      radius: screenWidth * 0.15,
                      imagePath: "assets/images/facebook.png",
                      onPressed: () {},
                    ),
                    SizedBox(height: 10),
                    SocialButton(
                      radius: screenWidth * 0.15,
                      imagePath: "assets/images/zalo.png",
                      onPressed: () {},
                    ),
                    SocialButton(
                      radius: screenWidth * 0.15,
                      imagePath: "assets/images/call_button.png",
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContactRow extends StatelessWidget {
  const ContactRow({
    super.key,
    required this.screenWidth,
    required this.text,
    required this.icon,
    required this.color,
  });

  final double screenWidth;
  final String text;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
      child: Row(
        children: [
          Icon(icon, color: color, size: screenWidth * 0.07),
          // SizedBox(width: screenWidth * 0.01),
          Flexible(
            child: Text(
              text,
              softWrap: true,
              maxLines: null,
              style:
                  TextStyle(fontSize: screenWidth * 0.04, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}

class SocialButton extends StatelessWidget {
  final double radius;
  final String imagePath;
  final VoidCallback onPressed;

  const SocialButton({
    super.key,
    required this.radius,
    required this.imagePath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: radius,
        height: radius,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
