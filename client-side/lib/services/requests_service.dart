import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../utils/main_link.dart';

class RequestsService {
  static final String link = MainLink().url;
  static final String _baseUrl = 'http://$link:3000/api/requests';
  static final String _apiKey = AuthService().apiKey ?? " ";
  static final int _userID = AuthService().userId ?? -1;

  static final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'x-api-key': _apiKey,
    'user_id': _userID.toString(),
  };

  // Fetch a single request by ID
  static Future<Map<String, dynamic>?> getRequestById(int id) async {
    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/$id'), headers: _headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      print('Failed to load request: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error fetching request: $e');
      return null;
    }
  }

  // Fetch all requests related to a specific user
  static Future<List<dynamic>?> getMyRequests(int userId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/mine/$userId'),
          headers: _headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      print('Failed to load journeys: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error fetching journeys: $e');
      return null;
    }
  }

  // Create a new request
  static Future<bool> createRequest(Map<String, dynamic> requestData) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers,
        body: jsonEncode(requestData),
      );
      print(jsonEncode(requestData));
      return response.statusCode == 201; // HTTP 201 Created
    } catch (e) {
      print('Error creating request: $e');
      return false;
    }
  }

  // Update an existing request
  static Future<bool> updateRequest(
      int id, Map<String, dynamic> requestData) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: _headers,
        body: jsonEncode(requestData),
      );
      return response.statusCode == 204; // HTTP 204 No Content
    } catch (e) {
      print('Error updating request: $e');
      return false;
    }
  }
}
