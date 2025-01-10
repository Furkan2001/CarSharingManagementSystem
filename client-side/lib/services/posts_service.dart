import 'dart:convert';
import 'package:http/http.dart' as http;

class PostsService {
  static const String _baseUrl = 'http://10.0.2.2:3000/api';
  static const String _apiKey = 'api12324';
  static const String _userID = '1';

  // Common headers for all requests
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'x-api-key': _apiKey,
        'user_id': _userID, // Adding user_id header
      };

  // Fetch all journeys
  static Future<List<dynamic>> getAllJourneys() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/Journeys/all'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load journeys');
    }
  }

  // Fetch a specific journey by ID
  static Future<Map<String, dynamic>> getJourneyById(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/Journeys/other/$id/$_userID'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Journey not found');
    }
  }

  // Fetch a specific journey by ID
  static Future<Map<String, dynamic>> getMyJourneyById(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/Journeys/mine/$id/$_userID'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Journey not found');
    }
  }

  // Fetch user's journeys
  static Future<List<dynamic>> getUsersJourneys() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/Journeys/mine/$_userID'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load journeys');
    }
  }

  // Create a new journey
  static Future<bool> createJourney(Map<String, dynamic> journey) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/Journeys'),
      headers: _headers,
      body: jsonEncode(journey),
    );

    return response.statusCode == 201;
  }

  // Update an existing journey by ID
  static Future<bool> updateJourney(
      int id, Map<String, dynamic> updatedJourney) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/Journeys/$id'),
      headers: _headers,
      body: jsonEncode(updatedJourney),
    );

    return response.statusCode == 204;
  }

  // Delete a journey by ID
  static Future<bool> deleteJourney(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/Journeys/$id'),
      headers: _headers,
    );

    return response.statusCode == 200;
  }
}
