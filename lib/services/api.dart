import 'dart:convert';
import 'package:http/http.dart' as http;

class AnLuaApi {
  /// 服务器上的 AnLuaX API
  static const base = 'http://154.201.69.224/anluax';
  String? token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Future<Map<String, dynamic>> post(String path, Map body) async {
    final r = await http.post(Uri.parse('$base$path'), headers: _headers, body: jsonEncode(body));
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> get(String path) async {
    final r = await http.get(Uri.parse('$base$path'), headers: _headers);
    return jsonDecode(r.body) as Map<String, dynamic>;
  }
}
