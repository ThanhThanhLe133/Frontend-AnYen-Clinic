class Message {
  final String id;
  final String conversationId;
  final Sender sender;
  final String? receiver;
  final String content;
  final bool isRead;
  final DateTime createdAt;
  final SenderUser senderUser;

  Message({
    required this.id,
    required this.conversationId,
    required this.sender,
    this.receiver,
    required this.content,
    required this.isRead,
    required this.createdAt,
    required this.senderUser,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      conversationId: json['conversation_id'],
      sender: Sender.fromJson(json['sender']),
      receiver: json['receiver'],
      content: json['content'],
      isRead: json['isRead'],
      createdAt: DateTime.parse(json['createdAt']),
      senderUser: SenderUser.fromJson(json['senderUser']),
    );
  }
}

class Sender {
  final String id;
  final String name;
  final String avatar;
  final String type;

  Sender({
    required this.id,
    required this.name,
    required this.avatar,
    required this.type,
  });

  factory Sender.fromJson(Map<String, dynamic> json) {
    return Sender(
      id: json['id'],
      name: json['name'],
      avatar: json['avatar'],
      type: json['type'],
    );
  }
}

class SenderUser {
  final String id;
  final Patient? patient;
  final Doctor? doctor;

  SenderUser({
    required this.id,
    this.patient,
    this.doctor,
  });

  factory SenderUser.fromJson(Map<String, dynamic> json) {
    return SenderUser(
      id: json['id'],
      patient:
          json['patient'] != null ? Patient.fromJson(json['patient']) : null,
      doctor: json['doctor'] != null ? Doctor.fromJson(json['doctor']) : null,
    );
  }
}

class Patient {
  final String fullname;
  final String avatarUrl;

  Patient({
    required this.fullname,
    required this.avatarUrl,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      fullname: json['fullname'],
      avatarUrl: json['avatar_url'],
    );
  }
}

class Doctor {
  final String fullname;
  final String avatarUrl;

  Doctor({
    required this.fullname,
    required this.avatarUrl,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      fullname: json['fullname'],
      avatarUrl: json['avatar_url'],
    );
  }
}
