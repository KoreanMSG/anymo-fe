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
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadChat();
  }

  Future<void> _loadChat() async {
    try {
      final chatService = ChatService();
      final loadedChat = await chatService.getChat(widget.chatId);
      setState(() {
        chat = loadedChat;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadChat,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (chat == null) {
      return const Scaffold(
        body: Center(child: Text('Chat not found')),
      );
    }

    final messages = chat!.getFormattedMessages();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation Details'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Risk Level: ${chat!.getRiskLabel()} (${chat!.riskScore}/100)',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (chat!.memo.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Memo: ${chat!.memo}'),
                ],
                const SizedBox(height: 8),
                Text(
                  'Created: ${chat!.createdAt.year}/${chat!.createdAt.month}/${chat!.createdAt.day}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(message: messages[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
