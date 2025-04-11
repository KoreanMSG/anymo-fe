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
    this.memo = '',
    required this.createdAt,
  });

  List<ChatMessage> get messages {
    final messageTexts = text.split('@@');
    final result = <ChatMessage>[];

    for (int i = 0; i < messageTexts.length; i++) {
      final isDoctor = startWithDoctor ? i % 2 == 0 : i % 2 == 1;
      result.add(
        ChatMessage(
          isDoctor: isDoctor,
          message: messageTexts[i],
        ),
      );
    }

    return result;
  }

  String get riskLabel {
    if (riskScore < 25) return 'Low Risk';
    if (riskScore < 50) return 'Medium Risk';
    if (riskScore < 75) return 'High Risk';
    return 'Very High Risk';
  }
}

class ChatMessage {
  final bool isDoctor;
  final String message;

  ChatMessage({
    required this.isDoctor,
    required this.message,
  });
}
