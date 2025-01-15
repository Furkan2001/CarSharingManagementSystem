import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class MessageService {
  static const String _baseUrl = 'http://10.0.2.2:3000/api';
  static final String _apiKey = AuthService().apiKey ?? " ";
  static final int _userID = AuthService().userId ?? -1;

  // Common headers for all requests
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'x-api-key': _apiKey,
        'user_id': _userID.toString(),
      };

  // Send a message
  static Future<bool> sendMessage(
      int senderId, int receiverId, String content) async {
    final messageDto = {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/Messages/send'),
      headers: _headers,
      body: jsonEncode(messageDto),
    );

    return response.statusCode == 200;
  }

  // Get unread messages for a user
  static Future<List<dynamic>> getUnreadMessages(int userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/Messages/unread/$userId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load unread messages');
    }
  }

  // Mark a message as read
  static Future<bool> markMessageAsRead(int messageId) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/Messages/mark-as-read/$messageId'),
      headers: _headers,
    );

    return response.statusCode == 200;
  }

  // Get message history between two users
  static Future<List<dynamic>> getMessageHistory(
      int userId1, int userId2) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/Messages/history/$userId1/$userId2'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load message history');
    }
  }

  // Delete a specific message
  static Future<bool> deleteMessage(int messageId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/Messages/$messageId'),
      headers: _headers,
    );

    return response.statusCode == 200;
  }

  // Delete all read messages
  // static Future<bool> deleteReadMessages() async {
  //   final response = await http.delete(
  //     Uri.parse('$_baseUrl/Messages/delete-read'),
  //     headers: _headers,
  //   );

  //   return response.statusCode == 200;
  // }

  static Future<List<dynamic>> getEndMessagesForAPerson(int userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/Messages/endmessages/$userId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('No messages found');
    } else {
      throw Exception('Failed to load messages');
    }
  }
}
