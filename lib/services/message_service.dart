import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:music_player_app/models/chat_preview_model.dart';
import 'package:music_player_app/models/message_model.dart';
import 'package:music_player_app/services/auth_service.dart';

class MessageService {
  final baseUrl = 'https://buddy-chat-backend-ii8g.onrender.com/api/v1/chat';
  final authService = Services();

  Future<List<Message>> previousMessage(user) async {
    final token = await authService.getToken();
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/get-previous/$user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': "Bearer $token",
        },
      );
      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return (data['messages'] as List).reversed
            .map((e) => Message.fromJson(e))
            .toList();
      } else {
        throw (data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ChatPreview>> chatPreviews() async {
    final token = await authService.getToken();
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/preview'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': "Bearer $token",
        },
      );
      final data = jsonDecode(res.body);
      // print(data);
      if (res.statusCode == 200) {
        return (data as List).map((e) => ChatPreview.fromJson(e)).toList();
      } else {
        throw (data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
}
