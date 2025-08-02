import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:music_player_app/global_socket/socket.dart';
import 'package:music_player_app/models/single_model.dart';
import 'package:music_player_app/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class Services {
  final baseUrl = 'https://buddy-chat-backend-ii8g.onrender.com/api/v1/auth';
  final storage = FlutterSecureStorage();

  Future<void> login(email, password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email, "password": password}),
      );
      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        print(data);
        final socketService = SocketService();

        // MUST call connect first
        socketService.connect(data['token']);
        await storage.write(key: "token", value: data['token']);
      } else {
        throw (data['message']);
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> passwordReset(String email) async {
    final res = await http.post(
      Uri.parse('$baseUrl/forgot_password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      //await _storage.write(key: 'token', value: data['token']);
      return data['message'];
    } else {
      final result = jsonDecode(res.body);

      throw (result['message'] ?? 'Login failed');
    }
  }

  Future<String> verifyPasswordReset(String emailCode) async {
    final res = await http.post(
      Uri.parse('$baseUrl/reset_password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"resetCode": emailCode}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      return data['message'];
    } else {
      final result = jsonDecode(res.body);

      throw (result['message'] ?? 'Something went wrong');
    }
  }

  Future<String> updateResentPassword(
    String password,
    String confirmpassword,
    String resetCode,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/password_reset'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "resetCode": resetCode,
        'password': password,
        'password_confirmation': password,
      }),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      //print(data['message']);
      //await _storage.write(key: 'token', value: data['token']);
      return data['message'];
    } else {
      final result = jsonDecode(res.body);

      throw (result['message'] ?? 'Login failed');
    }
  }

  Future<String> register(
    String email,
    String password,
    String firstname,

    File? selectedImage,
  ) async {
    final uri = Uri.parse('$baseUrl/register');
    final request = http.MultipartRequest('POST', uri);

    // Add form fields
    request.fields['name'] = firstname;
    request.fields['email'] = email;

    request.fields['password'] = password;

    // Add image file if provided
    if (selectedImage != null) {
      final fileStream = http.ByteStream(selectedImage.openRead());
      final fileLength = await selectedImage.length();

      final multipartFile = http.MultipartFile(
        'image', // Must match the field name expected by your Laravel backend
        fileStream,
        fileLength,
        filename: basename(selectedImage.path),
      );
      request.files.add(multipartFile);
    }

    try {
      final response = await request.send();
      final resBody = await response.stream.bytesToString();
      final data = jsonDecode(resBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(resBody);

        return data['message'];
      } else if (response.statusCode == 422) {
        final data = jsonDecode(resBody);
        throw (data['message'] ?? 'Validation failed');
      } else {
        final data = jsonDecode(resBody);
        throw (data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      print(e);
      throw ('Error: $e');
    }
  }

  Future<String> verifyEmail(String emailCode) async {
    final res = await http.post(
      Uri.parse('$baseUrl/emailVerification'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"verificationToken": emailCode}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['message'];
    } else {
      final data = jsonDecode(res.body);
      throw (data['message'] ?? 'Something went wrong');
    }
  }

  Future<String?> getToken() async {
    try {
      return await storage.read(key: 'token');
    } catch (e) {
      throw (e.toString());
    }
  }

  Future<void> deleteToken() async {
    await storage.delete(key: 'token');
  }

  Future<List<UserModel>> getUser() async {
    final token = await getToken();
    print("$token jsjsj");

    final res = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $token",
      },
    );
    final data = jsonDecode(res.body);

    if (res.statusCode == 200) {
      //return (data as List).map((data) => UserModel.fromJson(data)).toList();

      return (data['users'] as List)
          .map((data) => UserModel.fromJson(data))
          .toList();
    } else {
      throw (data['message']);
    }
  }

  Future<SingleModel> getMe() async {
    final token = await getToken();

    final res = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $token",
      },
    );
    final data = jsonDecode(res.body);

    if (res.statusCode == 200) {
      return SingleModel.fromJson(data);
      //return (data as List).map((data) => UserModel.fromJson(data)).toList();
    } else {
      throw (data['message']);
    }
  }

  Future<bool> deleteTokens() async {
    await storage.delete(key: 'token');
    return true;
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
