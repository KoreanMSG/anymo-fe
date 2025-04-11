import '../models/chat_model.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();

  factory ChatService() {
    return _instance;
  }

  ChatService._internal();

  final List<Chat> _chats = [
    Chat(
      id: 1,
      startWithDoctor: true,
      text:
          '안녕하세요, 오늘은 어떠세요?@@요즘 잠을 잘 못자고 있어요.@@언제부터 그런 증상이 있었나요?@@2주 전부터요. 매일 밤 잠들기가 힘들어요.',
      riskScore: 30,
      memo: '환자 번호: #1234',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Chat(
      id: 2,
      startWithDoctor: true,
      text:
          '오늘 기분이 어떠신가요?@@별로 좋지 않아요. 모든 것이 의미없게 느껴져요.@@언제부터 그런 기분이 들었나요?@@한 달 정도 됐어요. 아무것도 하고 싶지 않아요.',
      riskScore: 75,
      memo: '환자 번호: #2345',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Chat(
      id: 3,
      startWithDoctor: false,
      text:
          '선생님, 요즘 너무 불안해요.@@언제부터 그런 증상이 있었나요?@@지난주부터요. 가슴이 두근거리고 쉽게 놀라요.@@다른 신체적인 증상도 있나요?',
      riskScore: 45,
      memo: '환자 번호: #3456',
      createdAt: DateTime.now(),
    ),
  ];

  List<Chat> getChats() {
    return List.from(_chats);
  }

  Chat? getChatById(int id) {
    try {
      return _chats.firstWhere((chat) => chat.id == id);
    } catch (e) {
      return null;
    }
  }

  void addChat(Chat chat) {
    _chats.add(chat);
  }

  int getNextId() {
    return _chats.isEmpty
        ? 1
        : _chats.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
  }
}
