import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
      final isNetwork =
          imagePath!.startsWith('http') || imagePath!.startsWith('https');
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: isNetwork
            ? Image.network(
                imagePath!,
                width: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint("Lỗi khi load ảnh mạng: $error");
                  return Icon(Icons.broken_image, size: 50);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    width: 150,
                    height: 150,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
              )
            : Image.file(
                File(imagePath!),
                width: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint("Lỗi khi load ảnh: $error");
                  return Icon(Icons.broken_image, size: 50);
                },
              ),
      );
    } else if (audioPath != null && audioPath!.isNotEmpty) {
      final isNetworkAudio =
          audioPath!.startsWith('http') || audioPath!.startsWith('https');
      return FutureBuilder<Duration>(
        future: !isNetworkAudio
            ? Future.value(audioDurations[audioPath])
            : getAudioDuration(audioPath!, isNetworkAudio),
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
                "${formatDuration(currentPositions[audioPath!] ?? Duration.zero)} ",
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

Future<Duration> getAudioDuration(String path, bool isNetwork) async {
  final player = AudioPlayer();

  try {
    if (isNetwork) {
      await player.setSourceUrl(path);
    } else {
      await player.setSourceDeviceFile(path);
    }

    final duration = await player.onDurationChanged.first;

    await player.dispose();
    return duration;
  } catch (e) {
    await player.dispose();
    return Duration.zero;
  }
}
