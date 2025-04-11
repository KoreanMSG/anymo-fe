class Chat {
  final int id;
  final bool startWithDoctor;
  final String text; // Messages separated by '@@'
  final int riskScore; // 1-100 scale (low risk to high risk)
  final String memo;
  final DateTime createdAt;

  Chat({
    required this.id,
    required this.startWithDoctor,
    required this.text,
    required this.riskScore,
    required this.memo,
    required this.createdAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      startWithDoctor: json['startWithDoctor'],
      text: json['text'],
      riskScore: json['riskScore'],
      memo: json['memo'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startWithDoctor': startWithDoctor,
      'text': text,
      'riskScore': riskScore,
      'memo': memo,
    };
  }

  String getRiskLabel() {
    if (riskScore >= 75) return "Very High Risk";
    if (riskScore >= 50) return "High Risk";
    if (riskScore >= 25) return "Medium Risk";
    return "Low Risk";
  }

  List<String> getMessages() {
    return text.split('@@');
  }

  List<Message> getFormattedMessages() {
    final messages = getMessages();
    return List.generate(messages.length, (index) {
      final isDoctor = startWithDoctor ? index.isEven : index.isOdd;
      return Message(
        text: messages[index],
        isDoctor: isDoctor,
      );
    });
  }
}

class Message {
  final String text;
  final bool isDoctor;

  Message({
    required this.text,
    required this.isDoctor,
  });
}
