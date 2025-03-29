import 'package:flutter/material.dart';

class ExpandingAvatar extends StatefulWidget {
  final String imagePath;
  const ExpandingAvatar({super.key, required this.imagePath});

  @override
  _ExpandingAvatarState createState() => _ExpandingAvatarState();
}

class _ExpandingAvatarState extends State<ExpandingAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 160 * _animation.value,
                height: 160 * _animation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue[100],
                ),
              ),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),
              ),
              CircleAvatar(
                radius: 55,
                backgroundImage: AssetImage(widget.imagePath),
              ),
            ],
          );
        },
      ),
    );
  }
}
