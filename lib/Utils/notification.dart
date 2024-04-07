import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> sendNotification(
    String fcmToken, String title, String body) async {
  const String serverUrl =
      'https://4a07-2409-4080-1218-9778-681f-9276-623c-4857.ngrok-free.app/send'; // Replace with your server URL

  final Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  final Map<String, dynamic> requestData = {
    'fcmToken': fcmToken,
    'title': title,
    'body': body,
  };

  final http.Response response = await http.post(
    Uri.parse(serverUrl),
    headers: headers,
    body: json.encode(requestData),
  );

  if (response.statusCode == 200) {
    print('Notification sent successfully');
  } else {
    print('Failed to send notification: ${response.body}');
  }
}
