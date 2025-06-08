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

  // Khởi tạo PeerConnection, lấy stream local và add track
  Future<void> init() async {
    try {
      _peerConnection = await createPeerConnection(configuration);

      // Lấy media stream (audio + video)
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': true,
      });

      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });

      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          _remoteStream = event.streams[0];
        }
      };

      // Lắng nghe ICE candidate để gửi qua signaling server
      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        if (onSendIceCandidate != null) {
          final candidateData = {
            'candidate': {
              'candidate': candidate.candidate,
              'sdpMid': candidate.sdpMid,
              'sdpMLineIndex': candidate.sdpMLineIndex,
            },
          };
          onSendIceCandidate!(candidateData);
        }
      };
    } catch (e) {
      print('❌ Lỗi trong signaling.init(): $e');
    }
  }

  void Function(Map<String, dynamic>)? onSendIceCandidate;
  Future<void> addCandidate(Map<String, dynamic> candidateMap) async {
    final candidate = RTCIceCandidate(
      candidateMap['candidate'],
      candidateMap['sdpMid'],
      candidateMap['sdpMLineIndex'],
    );
    await _peerConnection!.addCandidate(candidate);
  }

  // Tạo offer SDP
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

  // Tạo answer SDP (đáp lại offer)
  Future<Map<String, dynamic>> createAnswer() async {
    try {
      if (_peerConnection == null) {
        throw Exception("PeerConnection is null");
      }

      final answer = await _peerConnection!.createAnswer(constraints);
      await _peerConnection!.setLocalDescription(answer);
      return answer.toMap();
    } catch (e, stack) {
      print('❌ Lỗi khi tạo answer: $e');
      print(stack);
      rethrow;
    }
  }

  // Đặt remote description (offer hoặc answer nhận được từ đối phương)
  Future<void> setRemoteDescription(Map<String, dynamic> session) async {
    try {
      if (_peerConnection == null) {
        throw Exception("PeerConnection is null");
      }

      final desc = RTCSessionDescription(session['sdp'], session['type']);
      await _peerConnection!.setRemoteDescription(desc);
    } catch (e) {
      print('❌ Lỗi khi set remote description: $e');
      rethrow;
    }
  }

  // Lấy stream video/audio local để hiển thị trên UI (video preview)
  MediaStream? get localStream => _localStream;

  // Lấy stream video/audio remote để hiển thị trên UI (video đối phương)
  MediaStream? get remoteStream => _remoteStream;

  void toggleMicrophone(bool enabled) {
    if (_localStream == null) return;

    for (var track in _localStream!.getAudioTracks()) {
      track.enabled = enabled;
    }
  }

  // Bật/tắt camera (video)
  void toggleCamera(bool enabled) {
    if (_localStream == null) return;

    for (var track in _localStream!.getVideoTracks()) {
      track.enabled = enabled;
    }
  }

  // Đóng kết nối và giải phóng tài nguyên
  Future<void> close() async {
    await _peerConnection?.close();
    await _localStream?.dispose();
    await _remoteStream?.dispose();
    _peerConnection = null;
    _localStream = null;
    _remoteStream = null;
  }
}
