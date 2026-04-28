import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);
  @override
  String toString() => message;
}

class ApiClient {
  static final ApiClient _instance = ApiClient._();
  factory ApiClient() => _instance;
  ApiClient._();

  static const _tokenKey = 'loopz_jwt_token';

  String? _token;
  String? get token => _token;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
  }

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) headers['Authorization'] = 'Bearer $_token';
    return headers;
  }

  Future<Map<String, dynamic>> get(String url) async {
    final res = await http
        .get(Uri.parse(url), headers: _headers)
        .timeout(const Duration(seconds: 30));
    return _handle(res);
  }

  Future<Map<String, dynamic>> post(String url, [Map<String, dynamic>? body]) async {
    final res = await http
        .post(
          Uri.parse(url),
          headers: _headers,
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(const Duration(seconds: 30));
    return _handle(res);
  }

  Future<Map<String, dynamic>> put(String url, [Map<String, dynamic>? body]) async {
    final res = await http
        .put(
          Uri.parse(url),
          headers: _headers,
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(const Duration(seconds: 30));
    return _handle(res);
  }

  Future<Map<String, dynamic>> delete(String url) async {
    final res = await http
        .delete(Uri.parse(url), headers: _headers)
        .timeout(const Duration(seconds: 30));
    return _handle(res);
  }

  /// Upload a video file as multipart/form-data
  Future<Map<String, dynamic>> uploadVideo(
    String url,
    File file, {
    Map<String, String>? fields,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse(url));
    if (_token != null) request.headers['Authorization'] = 'Bearer $_token';
    if (fields != null) request.fields.addAll(fields);

    final ext = file.path.split('.').last.toLowerCase();
    final mimeSubtype = ext == 'mov' ? 'quicktime' : ext;
    request.files.add(await http.MultipartFile.fromPath(
      'video',
      file.path,
      contentType: MediaType('video', mimeSubtype),
    ));

    final streamed = await request.send().timeout(const Duration(minutes: 5));
    final res = await http.Response.fromStream(streamed);
    return _handle(res);
  }

  Map<String, dynamic> _handle(http.Response res) {
    Map<String, dynamic> body;
    try {
      body = res.body.isEmpty ? {} : jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      body = {'message': res.body};
    }
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body;
    }
    throw ApiException(
      body['message']?.toString() ?? 'Request failed (${res.statusCode})',
      res.statusCode,
    );
  }
}
