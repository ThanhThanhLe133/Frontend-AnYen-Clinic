import 'package:flutter_webrtc/flutter_webrtc.dart';

class SignalingService {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  final Map<String, dynamic> configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ],
  };

  final Map<String, dynamic> constraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [],
  };

  // Tạo kết nối và stream video/audio
  Future<void> init() async {
    try {
      _peerConnection = await createPeerConnection(configuration);
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': true,
      });

      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });

      _peerConnection!.onTrack = (event) {
        if (event.streams.isNotEmpty) {
          _remoteStream = event.streams[0];
        }
      };
    } catch (e) {
      print('❌ Lỗi trong signaling.init(): $e');
    }
  }

  // Tạo offer
  Future<Map<String, dynamic>> createOffer() async {
    try {
      if (_peerConnection == null) {
        throw Exception("PeerConnection is null");
      }

      final offer = await _peerConnection!.createOffer(constraints);
      await _peerConnection!.setLocalDescription(offer);
      return offer.toMap();
    } catch (e, stack) {
      print('❌ Lỗi khi tạo offer: $e');
      print(stack);
      rethrow;
    }
  }

  // Tạo answer
  Future<Map<String, dynamic>> createAnswer() async {
    RTCSessionDescription answer =
        await _peerConnection!.createAnswer(constraints);
    await _peerConnection!.setLocalDescription(answer);
    return answer.toMap();
  }

  // Nhận tín hiệu từ người khác (offer hoặc answer)
  Future<void> setRemoteDescription(Map<String, dynamic> signal) async {
    RTCSessionDescription desc =
        RTCSessionDescription(signal['sdp'], signal['type']);
    await _peerConnection!.setRemoteDescription(desc);
  }

  // ICE Candidate (nếu dùng)
  void addCandidate(RTCIceCandidate candidate) {
    _peerConnection?.addCandidate(candidate);
  }

  MediaStream? getLocalStream() => _localStream;
  MediaStream? getRemoteStream() => _remoteStream;

  void dispose() {
    _localStream?.dispose();
    _remoteStream?.dispose();
    _peerConnection?.close();
    _peerConnection = null;
  }
}
