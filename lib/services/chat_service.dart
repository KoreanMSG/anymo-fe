import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_model.dart';

class ChatService {
  final String baseUrl = 'https://anymo-be.onrender.com';
  
  // 모든 채팅 가져오기
  Future<List<Chat>> getAllChats() async {
    final response = await http.get(Uri.parse('$baseUrl/chats'));
    
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Chat.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load chats');
    }
  }
  
  // 특정 채팅 가져오기
  Future<Chat> getChat(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/chats/$id'));
    
    if (response.statusCode == 200) {
      return Chat.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Chat not found');
    } else {
      throw Exception('Failed to load chat');
    }
  }
  
  // 새 채팅 생성
  Future<Chat> createChat(Chat chat) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chats'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(chat.toJson()),
    );
    
    if (response.statusCode == 201) {
      return Chat.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create chat');
    }
  }
  
  // 채팅 업데이트
  Future<Chat> updateChat(int id, Chat chat) async {
    final response = await http.put(
      Uri.parse('$baseUrl/chats/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(chat.toJson()),
    );
    
    if (response.statusCode == 200) {
      return Chat.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Chat not found');
    } else {
      throw Exception('Failed to update chat');
    }
  }
  
  // 채팅 삭제
  Future<void> deleteChat(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/chats/$id'));
    
    if (response.statusCode != 200) {
      if (response.statusCode == 404) {
        throw Exception('Chat not found');
      } else {
        throw Exception('Failed to delete chat');
      }
    }
  }
}
