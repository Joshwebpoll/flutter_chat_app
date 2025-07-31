import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player_app/global_socket/socket.dart';
import 'package:music_player_app/models/chat_preview_model.dart';
import 'package:music_player_app/models/user_model.dart';
import 'package:music_player_app/providers/chat_preview_provider.dart';
import 'package:music_player_app/services/auth_service.dart';
import 'package:music_player_app/services/message_service.dart';

// Service providers
final authServiceProvider = Provider((ref) => Services());
final messageServiceProvider = Provider((ref) => MessageService());
//final socketProvider = Provider((ref) => SocketService());

// State providers
final allUsersProvider =
    StateNotifierProvider<UsersNotifier, AsyncValue<List<UserModel>>>((ref) {
      return UsersNotifier(ref.read(authServiceProvider));
    });

final chatPreviewsProvider =
    StateNotifierProvider<ChatPreviewsNotifier, AsyncValue<List<ChatPreview>>>((
      ref,
    ) {
      return ChatPreviewsNotifier(ref.read(messageServiceProvider));
    });

// final socketListenerProvider = Provider<SocketService>((ref) {
//   return SocketService(ref);
// });

// Users state notifier
class UsersNotifier extends StateNotifier<AsyncValue<List<UserModel>>> {
  final Services _authService;

  UsersNotifier(this._authService) : super(const AsyncValue.loading()) {
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    state = const AsyncValue.loading();
    try {
      final users = await _authService.getUser();

      state = AsyncValue.data(users);
    } catch (e, stackTrace) {
      print("❌ Error fetching users: $e");
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
