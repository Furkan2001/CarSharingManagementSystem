import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class PostsService {
  static const String _baseUrl = 'http://10.0.2.2:3000/api';
  static final String _apiKey = AuthService().apiKey ?? " ";
  static final int _userID = AuthService().userId ?? -1;

  // Common headers for all requests
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'x-api-key': _apiKey,
        'user_id': _userID.toString(),
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

  // Fetch a specific journey by ID (diğer kullanıcıların ilanı)
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

  // Fetch a specific journey by ID (kendi ilanımız)
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

  // Fetch user's journeys (kullanıcıya ait bütün ilanlar)
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

    print(response.body);
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

  // -------------------------------------------------------
  // Yeni eklenen: Filtreleme metodu (POST -> /Journeys/filter)
  // -------------------------------------------------------
  // JourneyFilterModel'e göre POST body oluşturup istek atar.
  // public class JourneyFilterModel
  // {
  //    public DateTime? StartTime { get; set; }
  //    public DateTime? EndTime { get; set; }
  //    public string? StartDistrict { get; set; }
  //    public string? DestinationDistrict { get; set; }
  //    public int? HasVehicle { get; set; }
  // }
  // -------------------------------------------------------
  static Future<List<dynamic>> filterJourneys({
    DateTime? startTime,
    DateTime? endTime,
    int? hasVehicle,
  }) async {
    final url = Uri.parse('$_baseUrl/Journeys/filter');

    // JourneyFilterModel ile eşleşen key-value yapısı
    final body = {
      "startTime": startTime?.toIso8601String(), // DateTime -> ISO 8601 format
      "endTime": endTime?.toIso8601String(),
      "startDistrict": "", // Bu ikisi her zaman boş gönderilecek
      "destinationDistrict": "",
      "hasVehicle": hasVehicle, // 0 veya 1
    };

    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode(body),
    );

    // Sunucudan 200 döndüğünü varsayıyoruz (başarılı)
    if (response.statusCode == 200) {
      // Dönen response.body bir JSON array ise decode edip List olarak döndürürüz
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to filter journeys');
    }
  }
}
