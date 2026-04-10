import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _tokenKey = 'mp_access_token';
  static const _maxAmountKey = 'mp_max_amount';

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

  Future<void> saveMaxAmount(double? amount) async {
    final prefs = await SharedPreferences.getInstance();
    if (amount == null) {
      await prefs.remove(_maxAmountKey);
    } else {
      await prefs.setDouble(_maxAmountKey, amount);
    }
  }

  Future<double?> getMaxAmount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_maxAmountKey);
  }
}
