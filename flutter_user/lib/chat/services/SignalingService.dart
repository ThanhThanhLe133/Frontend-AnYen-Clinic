import 'package:flutter_webrtc/flutter_webrtc.dart';

class SignalingService {
  bool isNegotiated = false;
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;

  final Map<String, dynamic> configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {'urls': 'stun:stun2.l.google.com:19302'},
      {'urls': 'stun:stun3.l.google.com:19302'},
      {'urls': 'stun:stun4.l.google.com:19302'},
    ],
  };

  final Map<String, dynamic> constraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [],
  };

  Function(MediaStream)? onAddRemoteStream;

  // Khởi tạo PeerConnection, lấy stream local và add track
  Future<void> init({MediaStream? local}) async {
    try {
      peerConnection = await createPeerConnection(configuration);
      peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
        print('🚀 Connection state changed to: $state');
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnecting) {
          print('✅ Peer is attempting to connect');
        }
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
            state ==
                RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
            state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
          print('❌ Connection failed or closed');
        }
      };

      peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
        print('🚀 ICE Connection state changed: $state');
      };

      // Nếu chưa truyền stream từ ngoài vào thì tự khởi tại đây
      localStream = local ??
          await navigator.mediaDevices
              .getUserMedia({'audio': true, 'video': true});

      // Thêm track từ local stream vào peer
      for (var track in localStream!.getTracks()) {
        peerConnection!.addTrack(track, localStream!);
      }
      // onLocalStream?.call(localStream!); // Nếu bạn muốn thông báo UI

      // Lắng nghe khi phía remote gửi track
      peerConnection!.onTrack = (RTCTrackEvent event) {
        if (event.track.kind == 'video') {
          print('✅ Đã nhận được video track từ phía gửi');
        }
        if (event.streams.isNotEmpty) {
          remoteStream = event.streams[0];
          onAddRemoteStream?.call(remoteStream!);
          print(
              '✅ Remote stream có ${remoteStream!.getVideoTracks().length} video track');
        }
        if (remoteStream != null) {
          int videoTrackCount = remoteStream!.getVideoTracks().length;
          print('➥ Stream từ phía gửi có $videoTrackCount video track');
        }
      };
      // Lắng nghe ICE candidate để gửi qua signaling
      peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        print('🚀 ICE Candidate được tạo: ${candidate.toMap()}');
        onSendIceCandidate?.call(candidate);
      };
    } catch (e) {
      print('❌ Lỗi trong signaling.init(): $e');
    }
  }

  void Function(RTCIceCandidate)? onSendIceCandidate;

  Future<void> addCandidate(Map<String, dynamic> candidateMap) async {
    final candidate = RTCIceCandidate(
      candidateMap['candidate'],
      candidateMap['sdpMid'],
      candidateMap['sdpMLineIndex'],
    );
    await peerConnection!.addCandidate(candidate);
  }

  // Tạo offer SDP
  Future<Map<String, dynamic>> createOffer() async {
    if (isNegotiated) {
      print('⚠ Đã đàm phán, không gửi thêm offer');
      return {};
    }
    try {
      RTCSessionDescription offer = await peerConnection!.createOffer();
      await peerConnection!.setLocalDescription(offer);
      return offer.toMap();
    } catch (e) {
      print('❌ Lỗi khi tạo offer: $e');
      rethrow;
    }
  }

  // Tạo answer SDP (đáp lại offer)
  Future<Map<String, dynamic>> createAnswer() async {
    try {
      if (isNegotiated) {
        print("⚠️ Negotiation in progress, skipping createAnswer");
        return {};
      }
      isNegotiated = true;

      RTCSessionDescription answer = await peerConnection!.createAnswer();
      await peerConnection!.setLocalDescription(answer);

      isNegotiated = false;
      return answer.toMap();
    } catch (e) {
      isNegotiated = false;
      print("❌ Error creating answer: $e");
      rethrow;
    }
  }

  bool _remoteDescSet = false;
  // Đặt remote description (offer hoặc answer nhận được từ đối phương)
  Future<void> setRemoteDescription(Map<String, dynamic> session) async {
    final desc = RTCSessionDescription(session['sdp'], session['type']);
    await peerConnection!.setRemoteDescription(desc);
    _remoteDescSet = true;
    print("✅ Đã đặt Remote Description.");
  }

  MediaStream? get getLocalStream => localStream;
  set setLocalStream(MediaStream? stream) {
    localStream = stream;
  }

  MediaStream? get getRemoteStream => remoteStream;
  set setRemoteStream(MediaStream? stream) {
    remoteStream = stream;
  }

  void toggleMicrophone(bool enabled) {
    if (localStream == null) return;

    for (var track in localStream!.getAudioTracks()) {
      track.enabled = enabled;
    }
  }

  // Bật/tắt camera (video)
  void toggleCamera(bool enabled) {
    if (localStream == null) return;

    for (var track in localStream!.getVideoTracks()) {
      track.enabled = enabled;
    }
  }

  // Đóng kết nối và giải phóng tài nguyên
  Future<void> close() async {
    await peerConnection?.close();
    await localStream?.dispose();
    await remoteStream?.dispose();
    peerConnection = null;
    localStream = null;
    remoteStream = null;
  }
}
