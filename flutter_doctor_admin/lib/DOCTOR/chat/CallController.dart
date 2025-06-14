import 'package:ayclinic_doctor_admin/DOCTOR/chat/SignalingService.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallController {
  final SignalingService signaling = SignalingService();

  List<RTCIceCandidate> candidateBuffer = [];

  bool remoteDescSet = false;

  CallController();

  Future<void> init(void Function(RTCIceCandidate) onSendIce,
      void Function(MediaStream) onAddRemote) async {
    await signaling.init();

    signaling.onSendIceCandidate = (RTCIceCandidate candidate) {
      if (remoteDescSet) {
        onSendIce(candidate);
      } else {
        candidateBuffer.add(candidate);
      }
    };
    signaling.onAddRemoteStream = (MediaStream stream) {
      onAddRemote(stream);
    };
  }

  Future<Map<String, dynamic>> createOffer() async {
    final offer = await signaling.createOffer();
    return offer;
  }

  Future<void> handleRemoteAnswer(Map<String, dynamic> answer) async {
    await signaling.setRemoteDescription(answer);
    remoteDescSet = true;

    for (var candidate in candidateBuffer) {
      // webSocketService.sendIceCandidate(candidate.toMap());
    }
    candidateBuffer.clear();
  }

  Future<Map<String, dynamic>> createAnswer(Map<String, dynamic> offer) async {
    await signaling.setRemoteDescription(offer);
    remoteDescSet = true;

    final answer = await signaling.createAnswer();
    return answer;
  }

  Future<void> handleRemoteIce(Map<String, dynamic> candidate) async {
    if (remoteDescSet) {
      await signaling.addCandidate(candidate);
    } else {
      candidateBuffer.add(RTCIceCandidate(
        candidate['candidate'],
        candidate['sdpMid'],
        candidate['sdpMLineIndex'],
      ));
    }
  }

  Future<void> closeCall() async {
    await signaling.close();
  }
}
