import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _tokenKey = 'mp_access_token';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<bool> hasToken() async {
    String? token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
