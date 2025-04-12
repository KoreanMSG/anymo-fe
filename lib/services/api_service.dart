import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  final String _baseUrl =
      'https://api.example.com'; // Replace with your actual API URL

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  /// Analyze the conversation text and return risk score
  /// Text is already converted from speech to text before being sent
  Future<Map<String, dynamic>> analyzeConversation(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': text,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // If server returns error, return mock data for now
        return _getMockAnalysisResult(text);
      }
    } catch (e) {
      // If API call fails, return mock data for development
      return _getMockAnalysisResult(text);
    }
  }

  /// Process conversation text through backend to get formatted chat with @@ markers
  Future<Map<String, dynamic>> processChat(String text) async {
    try {
      final response = await http.post(
        Uri.parse('https://anymo-be.onrender.com/processChat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': text,
          'createdAt': DateTime.now().toIso8601String(),
          'memo': '',
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // If server returns error, use mock data with @@ markers
        return {
          'text': _addMarkersToMockText(text),
          'startWithDoctor': true,
          'createdAt': DateTime.now().toIso8601String(),
          'memo': '',
        };
      }
    } catch (e) {
      // If API call fails, use mock data with @@ markers
      return {
        'text': _addMarkersToMockText(text),
        'startWithDoctor': true,
        'createdAt': DateTime.now().toIso8601String(),
        'memo': '',
      };
    }
  }

  // Helper method to add @@ markers to mock text
  String _addMarkersToMockText(String text) {
    // Simple implementation to split by sentences and add markers
    final sentences = text.split(RegExp(r'(?<=[.!?])\s+'));
    if (sentences.isEmpty) return text;

    return sentences.join(' @@ ');
  }

  // This is a mock function that simulates API response
  // Will be replaced with actual API call in production
  Map<String, dynamic> _getMockAnalysisResult(String text) {
    // Count number of messages to determine risk score for mock data
    final messageCount = text.split('@@').length;
    final riskScore = (messageCount * 10) % 100; // Mock calculation

    return {
      'riskScore': riskScore > 0 ? riskScore : 30,
      'result': riskScore > 50 ? 'high_risk' : 'low_risk',
      'memo':
          'Analysis complete. Suicide risk level: ${riskScore > 50 ? 'High' : 'Low'}',
    };
  }
}
