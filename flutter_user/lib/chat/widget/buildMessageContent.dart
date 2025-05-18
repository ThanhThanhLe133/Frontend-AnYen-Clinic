import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

class MessageContent extends StatelessWidget {
  final String message;
  final String? imagePath;
  final String? audioPath;
  final bool isMe;
  final bool isPlaying;
  final String? currentAudioPath;
  final Map<String, Duration> audioDurations;
  final Map<String, Duration> currentPositions;
  final Function(String?) togglePlayPause;
  final Future<Duration> Function(String) getAudioDuration;

  const MessageContent({
    super.key,
    required this.message,
    required this.imagePath,
    required this.audioPath,
    required this.isMe,
    required this.isPlaying,
    required this.currentAudioPath,
    required this.audioDurations,
    required this.currentPositions,
    required this.togglePlayPause,
    required this.getAudioDuration,
  });

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    if (message.isNotEmpty) {
      return Text(
        message,
        style: TextStyle(
          color: isMe ? Colors.white : Colors.black,
          fontSize: 14,
        ),
      );
    } else if (imagePath != null && imagePath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(imagePath!),
          width: 150,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint("Lỗi khi load ảnh: $error");
            return Icon(Icons.broken_image, size: 50);
          },
        ),
      );
    } else if (audioPath != null) {
      return FutureBuilder<Duration>(
        future: audioDurations.containsKey(audioPath)
            ? Future.value(audioDurations[audioPath])
            : getAudioDuration(audioPath!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            audioDurations[audioPath!] = snapshot.data!;
          }

          Duration audioDuration = audioDurations[audioPath!] ?? Duration.zero;

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => togglePlayPause(audioPath),
                child: Icon(
                  (isPlaying && currentAudioPath == audioPath)
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 8),
              Text(
                "${formatDuration(currentPositions[audioPath!] ?? Duration.zero)} / ${formatDuration(audioDuration)}",
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ],
          );
        },
      );
    }
    return SizedBox.shrink();
  }
}
