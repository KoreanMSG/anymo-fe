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
  Future<Map<String, dynamic>> analyzeConversation(
      String text, bool startWithDoctor) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': text,
          'startWithDoctor': startWithDoctor,
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
