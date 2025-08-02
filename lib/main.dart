import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player_app/app_theme/app_themes.dart';
import 'package:music_player_app/global_socket/socket.dart';

import 'package:music_player_app/models/user_model.dart';
import 'package:music_player_app/screens/chat_screen.dart';
import 'package:music_player_app/screens/email_verification_screen.dart';
import 'package:music_player_app/screens/login_screen.dart';
import 'package:music_player_app/screens/me.dart';
import 'package:music_player_app/screens/onboarding_screen.dart';
import 'package:music_player_app/screens/profile.dart';
import 'package:music_player_app/screens/reset_password_otp_screen.dart';
import 'package:music_player_app/screens/reset_password_screen.dart';
import 'package:music_player_app/screens/signup_screen.dart';
import 'package:music_player_app/services/auth_service.dart';
import 'screens/player_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final service = Services();
  final token = await service.getToken();
  final isLoggedIn = await service.isLoggedIn();

  if (token != null) {
    SocketService().connect(token);
  }

  runApp(ProviderScope(child: MyApp(initialRoute: isLoggedIn ? '/home' : "/")));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BuddyChat',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: initialRoute,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/home':
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case '/chat':
            final user = settings.arguments as UserModel;
            return MaterialPageRoute(builder: (_) => ChatScreen(user: user));
          // case '/profile':
          //   final user = settings.arguments as UserModel;
          //   return MaterialPageRoute(builder: (_) => ProfileScreen(user: user));
          case '/onboarding':
            return MaterialPageRoute(builder: (_) => OnboardingScreen());

          case '/profile':
            return MaterialPageRoute(builder: (_) => Profile());
          case '/me':
            return MaterialPageRoute(builder: (_) => Me());

          case '/verify':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => EmailOtpScreen(email: args['email']),
            );
          case '/signup':
            return MaterialPageRoute(builder: (_) => const SignupScreen());
          case '/password_otp':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => ResetPasswordOtpScreen(email: args['email']),
            );
          case '/reset':
            return MaterialPageRoute(
              builder: (_) => const ResetPasswordScreen(),
            );
          default:
            return MaterialPageRoute(
              builder:
                  (_) => const Scaffold(
                    body: Center(child: Text('404 Not Found')),
                  ),
            );
        }
      },
    );
  }
}
