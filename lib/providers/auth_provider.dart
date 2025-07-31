import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player_app/services/auth_service.dart';

final authServiceProvider = Provider<Services>((ref) => Services());
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<String>>((
  ref,
) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AsyncValue<String>> {
  final Ref ref;
  AuthNotifier(this.ref) : super(const AsyncValue.data(''));

  Future<void> checkLogin() async {
    try {
      final token = ref.read(authProvider.notifier).checkLogin();
      // print(token);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(authServiceProvider).login(email, password);
      final message = 'Login Successful';
      state = AsyncValue.data(message);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();
    try {
      final message = await ref.read(authServiceProvider).passwordReset(email);
      state = AsyncValue.data(message);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> verifyResetPassword(String emailCode) async {
    state = const AsyncValue.loading();
    try {
      final message = await ref
          .read(authServiceProvider)
          .verifyPasswordReset(emailCode);
      state = AsyncValue.data(message);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updatePassord(
    String password,
    String confirmpassword,
    String resetCode,
  ) async {
    state = const AsyncValue.loading();
    try {
      final message = await ref
          .read(authServiceProvider)
          .updateResentPassword(password, confirmpassword, resetCode);
      state = AsyncValue.data(message);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> verifyEmail(String emailCode) async {
    state = const AsyncValue.loading();
    try {
      final message = await ref
          .read(authServiceProvider)
          .verifyEmail(emailCode);
      state = AsyncValue.data(message);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> register(
    String email,
    String password,
    String firstname,
    selectedImage,
  ) async {
    print(email);
    state = const AsyncValue.loading();
    try {
      final message = await ref
          .read(authServiceProvider)
          .register(email, password, firstname, selectedImage);
      state = AsyncValue.data(message);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> logOut() async {
    try {
      state = const AsyncValue.loading();
      final authService = ref.read(
        authServiceProvider,
      ); // Store reference first
      await authService.deleteToken();
      state = AsyncValue.data('Logged out');
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void reset() {
    state = const AsyncValue.data(""); // ✅ Reset state after success
  }
}
