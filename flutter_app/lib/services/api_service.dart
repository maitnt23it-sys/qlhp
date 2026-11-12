import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/giang_vien.dart';

class AuthException implements Exception {
  @override
  String toString() => 'Phien dang nhap het han';
}

class ApiService {
  // Web / iOS simulator: localhost | Android emulator: 10.0.2.2
  // May that that: thay bang IP LAN cua may chay backend, vd http://192.168.1.10:5000/api
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  static Future<String?> getToken() async =>
      (await SharedPreferences.getInstance()).getString('token');

  static Future<Map<String, String>> _headers() async => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken() ?? ''}',
      };

  static dynamic _handle(http.Response r) {
    if (r.statusCode == 401) throw AuthException();
    final body = r.body.isEmpty ? null : jsonDecode(r.body);
    if (r.statusCode >= 200 && r.statusCode < 300) return body;
    throw Exception(body is Map ? body['message'] : 'Loi ${r.statusCode}');
  }

  static Future<void> login(String user, String pass) async {
    final r = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': user, 'password': pass}),
    );
    if (r.statusCode == 401) throw Exception('Sai tai khoan hoac mat khau');
    final data = _handle(r);
    await (await SharedPreferences.getInstance()).setString('token', data['token']);
  }
  static Future<void> logout() async =>
      (await SharedPreferences.getInstance()).remove('token');
  static Future<List<GiangVien>> getAll({String q = ''}) async {
    final r = await http.get(
      Uri.parse('$baseUrl/giangvien').replace(queryParameters: {'q': q}),
      headers: await _headers(),
    );
    return (_handle(r) as List).map((e) => GiangVien.fromJson(e)).toList();
  }
  static Future<void> create(GiangVien g) async {
    final r = await http.post(Uri.parse('$baseUrl/giangvien'),
        headers: await _headers(), body: jsonEncode(g.toJson()));
    _handle(r);
  }
  static Future<void> update(String id, GiangVien g) async {
    final r = await http.put(Uri.parse('$baseUrl/giangvien/$id'),
        headers: await _headers(), body: jsonEncode(g.toJson()));
    _handle(r);
  }
  static Future<void> delete(String id) async {
    final r = await http.delete(Uri.parse('$baseUrl/giangvien/$id'),
        headers: await _headers());
    _handle(r);
  }
}
