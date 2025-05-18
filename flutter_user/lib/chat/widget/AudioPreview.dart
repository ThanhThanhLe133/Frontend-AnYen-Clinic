import 'package:anyen_clinic/function.dart';
import 'package:flutter/material.dart';

class AudioPreview extends StatelessWidget {
  final bool isPlaying;
  final String? currentAudioPath;
  final String? recordedFilePath;
  final Duration recordDuration;
  final Map<String, Duration> currentPositions;
  final void Function(String? path) togglePlayPause;
  final VoidCallback removeRecordedAudio;

  const AudioPreview({
    super.key,
    required this.isPlaying,
    required this.currentAudioPath,
    required this.recordedFilePath,
    required this.recordDuration,
    required this.currentPositions,
    required this.togglePlayPause,
    required this.removeRecordedAudio,
  });

  @override
  Widget build(BuildContext context) {
    if (recordedFilePath == null) return SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            (isPlaying && currentAudioPath == recordedFilePath)
                ? Icons.pause
                : Icons.play_arrow,
            color: Colors.blue,
          ),
          onPressed: () => togglePlayPause(recordedFilePath),
        ),
        Text(
          "${formatDuration(currentPositions[recordedFilePath] ?? Duration.zero)} / ${formatDuration(recordDuration)}",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: Icon(Icons.cancel, color: Colors.red),
          onPressed: removeRecordedAudio,
        ),
      ],
    );
  }
}
