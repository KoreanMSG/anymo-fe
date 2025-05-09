import 'package:flutter/material.dart';
import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/chat_model.dart';
import '../services/chat_service.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  bool _isListening = false;
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  bool _startWithDoctor = true;
  final stt.SpeechToText _speech = stt.SpeechToText();
  String _currentText = '';
  List<String> _recordedTexts = [];
  bool _isInitialized = false;
  final chatService = ChatService();

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _isInitialized = await _speech.initialize(
      onStatus: (status) {
        print('Speech recognition status: $status');
        if (status == 'done' || status == 'notListening') {
          if (_isListening) {
            // Restart listening after a short pause
            Future.delayed(const Duration(milliseconds: 1000), () {
              if (_isListening) {
                _startListening();
              }
            });
          }
        }
      },
      onError: (errorNotification) =>
          print('Speech recognition error: $errorNotification'),
    );
    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    _speech.stop();
    super.dispose();
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;

      if (_isListening) {
        // Start speech recognition and timer
        _elapsed = Duration.zero;
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _elapsed = Duration(seconds: timer.tick);
          });
        });
        _startListening();
      } else {
        // Stop speech recognition and timer
        _timer?.cancel();
        _timer = null;
        _speech.stop();
        _processSpeechData();
      }
    });
  }

  void _startListening() async {
    if (!_isInitialized) return;

    await _speech.listen(
      onResult: (result) {
        setState(() {
          if (result.finalResult) {
            if (result.recognizedWords.isNotEmpty) {
              _recordedTexts.add(result.recognizedWords);
            }
            _currentText = '';
          } else {
            _currentText = result.recognizedWords;
          }
        });
      },
      localeId: 'en-US', // Korean language
      listenMode: stt.ListenMode.confirmation,
      pauseFor: const Duration(seconds: 3),
    );
  }

  Future<void> _processSpeechData() async {
    // Show loading indicator
    setState(() {
      _currentText = 'Analyzing...';
    });

    // Combine all recorded texts
    final fullText = _recordedTexts.join(' ');

    // If empty, create a mock text
    final textToAnalyze = fullText.isEmpty
        ? 'Hello, welcome to the consultation. Hello, I have been under a lot of stress lately. What has been causing you stress? It keeps building up with work and family issues.'
        : fullText;

    // First send to processChat API to format with @@ markers
    final apiService = ApiService();
    final processedChat = await apiService.processChat(textToAnalyze);

    // Then send to analysis API using the processed text
    final formattedText = processedChat['text'];
    final startWithDoctorValue =
        processedChat['startWithDoctor'] ?? _startWithDoctor;

    final result = await apiService.analyzeConversation(formattedText);

    // Create a new chat with the analysis result
    final newChat = Chat(
      id: 0, // Will be set by the server
      startWithDoctor: startWithDoctorValue,
      text: formattedText,
      riskScore: result['riskScore'],
      memo: result['memo'] ??
          'Patient Number: #${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );

    try {
      final createdChat = await chatService.createChat(newChat);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(chatId: createdChat.id),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving chat: $e')),
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Recognition'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    size: 80,
                    color: _isListening ? Colors.red : Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _isListening ? 'Listening...' : 'Start Recognition',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_isListening)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        _formatDuration(_elapsed),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (_currentText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Text(
                    _currentText,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Start with: '),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Doctor'),
                  selected: _startWithDoctor,
                  onSelected: (selected) {
                    if (!_isListening) {
                      setState(() {
                        _startWithDoctor = true;
                      });
                    }
                  },
                ),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text('Patient'),
                  selected: !_startWithDoctor,
                  onSelected: (selected) {
                    if (!_isListening) {
                      setState(() {
                        _startWithDoctor = false;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isInitialized ? _toggleListening : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isListening ? Colors.red : Colors.blue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                _isListening ? 'Stop Recording' : 'Start Recording',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            if (!_isInitialized)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  'Initializing voice recognition...',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
