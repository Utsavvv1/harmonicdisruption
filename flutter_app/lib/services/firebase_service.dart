import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config_service.dart';

class FirebaseService {
  static const String firebaseUrl =
      'https://raptors-5cf52-default-rtdb.asia-southeast1.firebasedatabase.app';

  static Future<String> _getUserId() async =>
      await ConfigService.getOrCreateUserId();

  static Future<void> setFocusState(bool isWorking) async {
    final userId = await _getUserId();
    final url = Uri.parse('$firebaseUrl/users/$userId/settings/focusMode.json');
    try {
      final res = await http.put(url, body: jsonEncode(isWorking));
      if (res.statusCode == 200) {
        print('[Firebase] focusMode = $isWorking');
      } else {
        print('❌ Failed to update focusMode: ${res.body}');
      }
    } catch (e) {
      print('Firebase Error: $e');
    }
  }

  static Future<void> sendDistractionEvent(
    String appName,
    String reason,
  ) async {
    final userId = await _getUserId();
    final url = Uri.parse('$firebaseUrl/users/$userId/distractions.json');
    final event = {
      'app': appName,
      'reason': reason,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };
    try {
      final res = await http.post(url, body: jsonEncode(event));
      if (res.statusCode == 200) {
        print('📨 Distraction event sent: $appName');
      } else {
        print('❌ Failed to send distraction event: ${res.body}');
      }
    } catch (e) {
      print('Firebase Error: $e');
    }
  }

  static Future<bool> getFocusMode() async {
    final userId = await _getUserId();
    final url = Uri.parse('$firebaseUrl/users/$userId/settings/focusMode.json');
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        return res.body == 'true';
      } else {
        print('❌ Failed to read focusMode: ${res.body}');
        return false;
      }
    } catch (e) {
      print('Firebase Error (read): $e');
      return false;
    }
  }
}
