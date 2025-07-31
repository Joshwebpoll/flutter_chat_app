import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player_app/global_socket/socket.dart';
import 'package:music_player_app/models/chat_preview_model.dart';
import 'package:music_player_app/models/user_model.dart';
import 'package:music_player_app/services/message_service.dart';

class ChatPreviewsNotifier
    extends StateNotifier<AsyncValue<List<ChatPreview>>> {
  final MessageService _messageService;
  final socket = SocketService();

  ChatPreviewsNotifier(this._messageService)
    : super(const AsyncValue.loading()) {
    fetchPreviews();
  }

  Future<void> fetchPreviews() async {
    state = const AsyncValue.loading();
    try {
      final previews = await _messageService.chatPreviews();
      state = AsyncValue.data(previews);
      // socketPreview();
    } catch (e, stackTrace) {
      print("❌ Error fetching previews: $e");
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // void socketPreview() {
  //   socket.listen('chatMessage', (data) async {
  //     print("${data} llslsll");
  //     //final myId = await ref.read(meProvider.future);

  //     //print("${myId.id} mmmem");
  //     //  if(myId != null){
  //     updateChatPreview(data, '687a12b2716dd55c7b55d249');
  //     //  }
  //   });
  // }

  void updateChatPreview(Map<String, dynamic> msg, String userId) {
    print('$msg $userId mmjjjww');
    state = state.whenData((previews) {
      final isSender = msg['sender'] == userId;

      final otherUserId =
          (isSender ? msg['receiver'] : msg['sender']) as String;

      final index = previews.indexWhere((p) => p.userId == otherUserId);

      List<ChatPreview> updatedPreviews;

      if (index != -1) {
        final existing = previews[index];
        final updated = existing.copyWith(
          latestMessage: msg['message'],
          createdAt: DateTime.now(),
          unreadCount: isSender ? 0 : existing.unreadCount + 1,
        );
        updatedPreviews = [
          updated,
          ...previews.where((p) => p.userId != otherUserId),
        ];
      } else {
        final newPreview = ChatPreview(
          userId: otherUserId,
          name:
              isSender
                  ? (msg['receiverName'] ?? 'Unknown')
                  : msg['senderUser']?['name'] ?? 'Unknown',
          latestMessage: msg['message'],
          imageUrl:
              isSender
                  ? (msg['receiverImageUrl'] ?? '')
                  : msg['senderUser']?['imageUrl'] ?? '',
          createdAt: DateTime.now(),
          unreadCount: isSender ? 0 : 1,
        );

        updatedPreviews = [newPreview, ...previews];
      }

      return updatedPreviews;
    });
  }

  void markAsRead(String userId) {
    state.whenData((previews) {
      final updatedPreviews =
          previews.map((preview) {
            if (preview.userId == userId) {
              return preview.copyWith(unreadCount: 0);
            }
            return preview;
          }).toList();

      state = AsyncValue.data(updatedPreviews);
    });
  }
}
