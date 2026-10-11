import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:get/get.dart';

class ApiClient extends GetxService {
  static const String baseUrl = 'http://192.168.0.214:4000/api/v1';
  
  late SharedPreferences _prefs;
  String? _deviceToken;
  String? _deviceId;
  
  Future<ApiClient> init() async {
    _prefs = await SharedPreferences.getInstance();
    _deviceToken = _prefs.getString('device_token');
    
    if (_deviceToken == null) {
      await _registerDevice();
    }
    return this;
  }

  Future<void> _registerDevice() async {
    String installId = _prefs.getString('install_id') ?? _generateInstallId();
    await _prefs.setString('install_id', installId);
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/devices/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'install_id': installId,
          'platform': defaultTargetPlatform.name,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _deviceToken = data['token'];
        _deviceId = data['device_id'].toString();
        await _prefs.setString('device_token', _deviceToken!);
      } else {
        debugPrint('Failed to register device: ${response.body}');
      }
    } catch (e) {
      debugPrint('Device register error: $e');
    }
  }
  
  String _generateInstallId() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    return base64UrlEncode(values);
  }

  Future<Map<String, dynamic>?> getConfig() async {
    final etag = _prefs.getString('config_etag');
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/config'),
        headers: {
          if (_deviceToken != null) 'Authorization': 'Bearer $_deviceToken',
          if (etag != null) 'If-None-Match': etag,
        },
      );
      
      if (response.statusCode == 304) {
        // Not modified, use cached
        final cached = _prefs.getString('config_data');
        if (cached != null) {
          return jsonDecode(cached);
        }
      }
      
      if (response.statusCode == 200) {
        final newEtag = response.headers['etag'];
        if (newEtag != null) {
          await _prefs.setString('config_etag', newEtag);
        }
        await _prefs.setString('config_data', response.body);
        return jsonDecode(response.body);
      }
      
    } catch (e) {
      debugPrint('Fetch config error: $e');
      final cached = _prefs.getString('config_data');
      if (cached != null) {
        return jsonDecode(cached);
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> startLiveSession({String? modeKey, String? levelCode}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/live/sessions'),
        headers: {
          'Content-Type': 'application/json',
          if (_deviceToken != null) 'Authorization': 'Bearer $_deviceToken',
        },
        body: jsonEncode({
          if (modeKey != null) 'mode_key': modeKey,
          if (levelCode != null) 'level_code': levelCode,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Start session failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('Start session error: $e');
    }
    return null;
  }

  Future<void> endLiveSession(String sessionId, int durationSec, String endReason) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/live/sessions/$sessionId/end'),
        headers: {
          'Content-Type': 'application/json',
          if (_deviceToken != null) 'Authorization': 'Bearer $_deviceToken',
        },
        body: jsonEncode({
          'duration_sec': durationSec,
          'end_reason': endReason,
        }),
      );
    } catch (e) {
      debugPrint('End session error: $e');
    }
  }

  Future<String?> sendLiveChatMessage({
    required String message,
    String? modeKey,
    String? sessionId,
    List<Map<String, String>>? history,
  }) async {
    try {
      if (_deviceToken == null) {
        await _registerDevice();
      }

      final response = await http.post(
        Uri.parse('$baseUrl/live/chat'),
        headers: {
          'Content-Type': 'application/json',
          if (_deviceToken != null) 'Authorization': 'Bearer $_deviceToken',
        },
        body: jsonEncode({
          'message': message,
          if (modeKey != null) 'mode_key': modeKey,
          if (sessionId != null) 'sessionId': sessionId,
          if (history != null) 'history': history,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'] as String?;
      } else {
        debugPrint('Live chat failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('Live chat error: $e');
    }
    return null;
  }
}

