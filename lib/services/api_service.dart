import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Mengambil Base URL untuk Express.js API
  static String get baseUrl {
    // Membaca URL dari file konfigurasi .env, default ke localhost jika kosong
    String url = dotenv.env['API_URL'] ?? 'http://localhost:3000/api';
    // Jika berjalan pada emulator Android, ganti localhost dengan 10.0.2.2 agar terhubung
    if (!kIsWeb && Platform.isAndroid) {
      url = url.replaceAll('localhost', '10.0.2.2');
      url = url.replaceAll('127.0.0.1', '10.0.2.2');
    }
    return url;
  }

  // Helper internal untuk mencetak log request ke terminal
  static void _logRequest(
    String method,
    Uri url,
    Map<String, String> headers,
    String? body,
  ) {
    if (kDebugMode) {
      print('========================================================');
      print('HTTP $method REQUEST: $url');
      print('HEADERS: $headers');
      if (body != null && body.isNotEmpty) {
        print('BODY: $body');
      }
      print('========================================================');
    }
  }

  // Helper internal untuk mencetak log response ke terminal
  static void _logResponse(Uri url, http.Response response) {
    if (kDebugMode) {
      print('========================================================');
      print('HTTP RESPONSE (${response.statusCode}) FROM: $url');
      print('RESPONSE BODY: ${response.body}');
      print('========================================================');
    }
  }

  // Mengirim request GET dengan logging terminal yang seragam
  static Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final combinedHeaders = {'Content-Type': 'application/json', ...?headers};
    _logRequest('GET', url, combinedHeaders, null);
    final response = await http.get(url, headers: combinedHeaders);
    _logResponse(url, response);
    return response;
  }

  // Mengirim request POST dengan logging terminal yang seragam
  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final combinedHeaders = {'Content-Type': 'application/json', ...?headers};
    final bodyString = jsonEncode(body);
    _logRequest('POST', url, combinedHeaders, bodyString);
    final response = await http.post(
      url,
      headers: combinedHeaders,
      body: bodyString,
    );
    _logResponse(url, response);
    return response;
  }
}
