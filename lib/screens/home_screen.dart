import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  List<Chat> chats = [];
  bool isLoading = true;
  String? error;
  final chatService = ChatService();

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final loadedChats = await chatService.getAllChats();
      
      setState(() {
        chats = loadedChats;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _refreshChats() {
    _loadChats();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/logo.svg',
                height: 120,
                width: 120,
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshChats,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/logo.svg',
              height: 40,
              width: 40,
            ),
            const SizedBox(width: 12),
            const Text(
              'Anymo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: chats.isEmpty
          ? const Center(
              child: Text(
                  'No recorded conversations. Click the button below to start recording.'),
            )
          : RefreshIndicator(
              onRefresh: _loadChats,
              child: ListView.builder(
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
                              'Risk Level: ${chat.getRiskLabel()} (${chat.riskScore}/100)'),
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
