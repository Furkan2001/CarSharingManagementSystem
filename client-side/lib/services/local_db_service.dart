import 'package:shared_preferences/shared_preferences.dart';
import '../utils/main_link.dart';

Future<void> saveLoginInfo(String userId, String apiKey) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', true);
  await prefs.setString('userId', userId);
  await prefs.setString('apiKey', apiKey);
}

Future<bool> isUserLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isLoggedIn') ?? false;
}

Future<String?> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userId');
}

Future<String?> getApiKey() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('apiKey');
}
