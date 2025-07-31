// home_state.dart
import 'package:music_player_app/models/chat_preview_model.dart';
import 'package:music_player_app/models/user_model.dart';

class HomeState {
  final List<UserModel> allUsers;
  final List<ChatPreview> previews;
  final bool isLoading;
  final String? error;

  HomeState({
    required this.allUsers,
    required this.previews,
    this.isLoading = true,
    this.error,
  });

  HomeState copyWith({
    List<UserModel>? allUsers,
    List<ChatPreview>? previews,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      allUsers: allUsers ?? this.allUsers,
      previews: previews ?? this.previews,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
