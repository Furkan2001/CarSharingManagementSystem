class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  AuthService._internal();

  int? _userId;
  String? _apiKey;

  int? get userId => _userId;
  String? get apiKey => _apiKey;

  void setCredentials(int userId, String apiKey) {
    _userId = userId;
    _apiKey = apiKey;
  }

  void clearCredentials() {
    _userId = null;
    _apiKey = null;
  }
}
