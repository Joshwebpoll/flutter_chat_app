import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player_app/models/message_model.dart';
import 'package:music_player_app/services/message_service.dart';

final messageServiceProvider = Provider<MessageService>(
  (ref) => MessageService(),
);
final messageProvider =
    StateNotifierProvider<ChatScreenNotifier, AsyncValue<List<Message>>>((ref) {
      return ChatScreenNotifier(ref);
    });

class ChatScreenNotifier extends StateNotifier<AsyncValue<List<Message>>> {
  Ref ref;
  ChatScreenNotifier(this.ref) : super(const AsyncLoading());
  Future<void> loadMessages(userid) async {
    final message = await ref
        .read(messageServiceProvider)
        .previousMessage(userid);
    state = AsyncData(message);
    // setState(() {
    //   messages = list;
    //   isLoading = false;
    // });
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _scrollToBottom();
    // });
  }

  void addMessage(Map<String, dynamic> message) {
    final messages = Message.fromJson(message);
    state = state.whenData((messagesx) => [...messagesx, messages]);
  }

  void sendMessage(Message message) {
    state = state.whenData((messagesx) => [...messagesx, message]);
  }
}
