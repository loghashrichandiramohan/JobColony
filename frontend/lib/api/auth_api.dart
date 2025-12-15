import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class AuthApi {
  static Future<bool> register(String email, String password) async {
    final uri = Uri.parse('$backendBase/auth/register');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }

  static Future<bool> login(String email, String password) async {
    final uri = Uri.parse('$backendBase/auth/login');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return res.statusCode == 200;
  }
}
