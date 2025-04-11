import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';
import '../widgets/chat_bubble.dart';

class ResultScreen extends StatefulWidget {
  final int chatId;

  const ResultScreen({super.key, required this.chatId});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  Chat? chat;

  @override
  void initState() {
    super.initState();
    chat = ChatService().getChatById(widget.chatId);
  }

  @override
  Widget build(BuildContext context) {
    if (chat == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('대화 결과'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('대화를 찾을 수 없습니다.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('대화 #${chat!.id}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: chat!.messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(message: chat!.messages[index]);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '분석 결과',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Row(
                              children: [
                                Container(
                                  width: constraints.maxWidth *
                                      chat!.riskScore /
                                      100,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: _getRiskColor(chat!.riskScore),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${chat!.riskScore}/100',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '위험도: ${chat!.riskLabel}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getRiskColor(chat!.riskScore),
                    fontSize: 16,
                  ),
                ),
                if (chat!.memo.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '메모: ${chat!.memo}',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRiskColor(int score) {
    if (score < 25) return Colors.green;
    if (score < 50) return Colors.yellow[700]!;
    if (score < 75) return Colors.orange;
    return Colors.red;
  }
}
