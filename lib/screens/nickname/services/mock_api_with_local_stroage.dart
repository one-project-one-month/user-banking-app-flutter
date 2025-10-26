import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage{
  static const _keyFavorites = 'favorite_accounts';

  static Future<void> saveNickName(String nickname, String accNo) async{
    final prefs = await SharedPreferences.getInstance();
    final existingNicknames = prefs.getStringList(_keyFavorites) ?? [] ;

    final newData = jsonEncode({
      'nickname' : nickname,
      'accountNo' : accNo,
    });

    existingNicknames.add(newData);
    await prefs.setStringList(_keyFavorites, existingNicknames);
  }

  static Future<List<Map<String, String>>> loadAllNickname() async{
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_keyFavorites) ?? [];

    return data.map((e) {
      final decoded = jsonDecode(e);
      return {
        'nickname': decoded['nickname'] as String,
        'accountNo': decoded['accountNo'] as String,
      };
    }).toList();
  }
}