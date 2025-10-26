import 'dart:convert';

import 'package:banking_app/core/api/api_config.dart';
import 'package:banking_app/screens/auth/service/auth_service.dart';
import 'package:http/http.dart' as http;

class ApiClient{
  static Future<Map<String, String>> _getHeader() async{
    final token =await AuthService.getToken();
    return{
      'Content-Type' : 'application/json',
      if(token != null)'Authorization' : 'Bearer $token'
    };
  }

  static Future<http.Response> get(String endpoint) async{
    final headers = await _getHeader();
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    return http.get(url, headers: headers);
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async{
    final headers = await _getHeader();
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    return http.post(url,headers: headers, body: jsonEncode(body));
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> body) async{
    final headers = await _getHeader();
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    return http.put(url,headers: headers, body: jsonEncode(body));
  }

  static Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeader();
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    return http.delete(url, headers: headers);
  }
}