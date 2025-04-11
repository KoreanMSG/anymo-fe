import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';
import 'record_screen.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Chat> chats;

  @override
  void initState() {
    super.initState();
    chats = ChatService().getChats();
  }

  void _refreshChats() {
    setState(() {
      chats = ChatService().getChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Recognition List'),
      ),
      body: chats.isEmpty
          ? Center(
              child: Text(
                  'No recorded conversations. Click the button below to start recording.'),
            )
          : ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 3,
                  child: ListTile(
                    title: Text(
                      'Conversation #${chat.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Risk Level: ${chat.riskLabel} (${chat.riskScore}/100)'),
                        if (chat.memo.isNotEmpty) Text(chat.memo),
                        Text(
                          'Created: ${chat.createdAt.year}/${chat.createdAt.month}/${chat.createdAt.day}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultScreen(chatId: chat.id),
                        ),
                      ).then((_) => _refreshChats());
                    },
                    trailing: const Icon(Icons.arrow_forward_ios),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RecordScreen()),
          ).then((_) => _refreshChats());
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.mic, color: Colors.white),
      ),
    );
  }
}
