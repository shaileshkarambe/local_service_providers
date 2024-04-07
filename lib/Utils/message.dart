import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';

class Message {
  String _accessToken = '';
  final String _serviceAccountPath =
      'D:\\Project\\local_service_providers\\lib\\Screens\\local-service-providers-app-firebase-adminsdk-ibvz1-39e9448fdc.json';
  final List<String> _scopes = [
    'https://www.googleapis.com/auth/firebase.messaging',
    'https://www.googleapis.com/auth/cloud-platform'
  ]; // Update with your required scopes

  Future<void> sendMessageToDevice(
      String registrationToken, String title, String message) async {
    if (_accessToken.isEmpty) {
      await _refreshAccessToken();
    }

    final url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/local-service-providers-app/messages:send');
    final headers = {
      'Authorization': 'Bearer $_accessToken',
      'Content-Type': 'application/json',
    };

    final payload = {
      'message': {
        'token': registrationToken,
        'notification': {
          'title': title,
          'body': message,
        },
        'data': {
          'key': 'value',
        },
      },
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        print('Message sent successfully!');
      } else {
        print('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to send message: $e');
    }
  }

  Future<void> _refreshAccessToken() async {
    try {
      final keyJson = File(_serviceAccountPath).readAsStringSync();
      final key = json.decode(keyJson);
      final jwtClient = ServiceAccountCredentials.fromJson(key);
      final client = await clientViaServiceAccount(jwtClient, _scopes);
      final accessCredentials = client.credentials;

      _accessToken = accessCredentials.accessToken.data;
    } catch (e) {
      print('Failed to refresh access token: $e');
    }
  }
}
