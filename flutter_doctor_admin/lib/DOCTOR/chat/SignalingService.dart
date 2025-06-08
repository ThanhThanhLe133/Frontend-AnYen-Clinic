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

  void Function(RTCIceCandidate)? onSendIceCandidate;
  void Function(RTCSessionDescription)? onSendOffer;
  void Function(RTCSessionDescription)? onSendAnswer;
  void Function(MediaStream)? onAddRemoteStream;

  // Khởi tạo kết nối và stream
  Future<void> init() async {
    try {
      _peerConnection = await createPeerConnection(configuration);

      // Lấy local stream (audio + video)
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': true,
      });

      // Add local tracks vào peer connection
      for (var track in _localStream!.getTracks()) {
        _peerConnection!.addTrack(track, _localStream!);
      }

      // Khi nhận được track từ remote peer
      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          _remoteStream = event.streams[0];
          onAddRemoteStream?.call(_remoteStream!);
        }
      };

      // Lắng nghe ICE candidate
      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        if (onSendIceCandidate != null) {
          onSendIceCandidate!(candidate);
        }
      };
    } catch (e) {
      print('❌ Lỗi trong signaling.init(): $e');
    }
  }

  Future<void> handleRemoteOffer(RTCSessionDescription offer) async {
    await _peerConnection!.setRemoteDescription(offer);
    final answer = await _peerConnection!.createAnswer(constraints);
    await _peerConnection!.setLocalDescription(answer);
    onSendAnswer?.call(answer);
  }

  Future<void> handleRemoteAnswer(RTCSessionDescription answer) async {
    await _peerConnection!.setRemoteDescription(answer);
  }

  Future<void> addCandidate(Map<String, dynamic> candidateMap) async {
    final candidate = RTCIceCandidate(
      candidateMap['candidate'],
      candidateMap['sdpMid'],
      candidateMap['sdpMLineIndex'],
    );
    await _peerConnection!.addCandidate(candidate);
  }

  Future<Map<String, dynamic>> createOffer() async {
    final offer = await _peerConnection!.createOffer(constraints);
    await _peerConnection!.setLocalDescription(offer);
    onSendOffer?.call(offer);
    return offer.toMap();
  }

  Future<Map<String, dynamic>> createAnswer() async {
    final answer = await _peerConnection!.createAnswer(constraints);
    await _peerConnection!.setLocalDescription(answer);
    return answer.toMap();
  }

  Future<void> setRemoteDescription(Map<String, dynamic> session) async {
    final desc = RTCSessionDescription(session['sdp'], session['type']);
    await _peerConnection!.setRemoteDescription(desc);
  }

  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;

  void toggleMicrophone(bool enabled) {
    _localStream?.getAudioTracks().forEach((track) => track.enabled = enabled);
  }

  void toggleCamera(bool enabled) {
    _localStream?.getVideoTracks().forEach((track) => track.enabled = enabled);
  }

  Future<void> close() async {
    await _peerConnection?.close();
    await _localStream?.dispose();
    await _remoteStream?.dispose();
    _peerConnection = null;
    _localStream = null;
    _remoteStream = null;
  }
}
