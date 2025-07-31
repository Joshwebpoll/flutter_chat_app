import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player_app/global_socket/socket.dart';
import 'package:music_player_app/models/chat_preview_model.dart';
import 'package:music_player_app/models/user_model.dart';
import 'package:music_player_app/providers/auth_provider.dart';
import 'package:music_player_app/providers/home_providers.dart';
import 'package:music_player_app/providers/me_provider.dart';
import 'package:music_player_app/providers/socket_provider.dart';
import 'package:music_player_app/reuseable_dart/capitalize.dart';
import 'package:music_player_app/reuseable_dart/time_format.dart';
import 'package:music_player_app/services/auth_service.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController messageController = TextEditingController();
  final socket = SocketService();

  @override
  void initState() {
    super.initState();

    // Setup socket listeners after first frame

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final socket = ref.read(socketProvider);

    //   socket.removeListener('chatMessage'); // Prevent duplicates
    //   socket.listen('chatMessage', (data) {
    //     print(data);
    //     final myId = ref.read(meProvider).asData?.value;
    //     // ref
    //     //     .read(chatPreviewsProvider.notifier)
    //     //     .updateChatPreview(data, myId!.id);
    //   });
    // });
  }

  // Handle navigation to chat with proper result handling
  Future<void> _navigateToChat(UserModel user) async {
    final result = await Navigator.pushNamed(context, '/chat', arguments: user);

    print("🔙 Returned from chat, result: $result");

    // Re-setup socket listeners when returning from any navigation
    print("🔄 Re-setting up socket listeners after navigation");
    //ref.read(socketListenerProvider).setupSocketListeners();
    ref.read(chatPreviewsProvider.notifier).markAsRead(user.id);
    final service = Services();
    final token = await service.getToken();

    if (token != null) {
      SocketService().connect(token);
    }
  }

  @override
  void dispose() {
    // Clean up socket listeners
    ref.read(socketProvider).removeListener('chatMessage');
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    socket.listen('chatMessage', (data) async {
      print("${data} llslsll");
      final myId = await ref.read(meProvider.future);

      print("${myId.id} mmmem");
      //  if(myId != null){
      ref.read(chatPreviewsProvider.notifier).updateChatPreview(data, myId.id);
      //  }
    });
    ref.listen<AsyncValue<String>>(authProvider, (prev, next) {
      next.whenOrNull(
        data: (value) {
          if (value == "Logged out") {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(authProvider.notifier).reset(); //
              Navigator.pushNamed(context, '/');
              // Navigator.pushNamedAndRemoveUntil(
              //   context,
              //   '/login',
              //   (_) => false,
              // );
            });
          }
        },
        error: (e, _) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: $e")));
        },
      );
    });

    final allUsersAsync = ref.watch(allUsersProvider);
    final chatPreviewsAsync = ref.watch(chatPreviewsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "BuddyChat",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            IconButton(
              onPressed: () async {
                // Safely read the notifier BEFORE the await
                final authNotifier = ref.read(authProvider.notifier);

                await authNotifier.logOut();
              },
              icon: Icon(Icons.logout),
            ),
          ],
        ),
        // actions: [
        //   IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
        // ],
      ),
      body:
          (allUsersAsync.isLoading || chatPreviewsAsync.isLoading)
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Users list (horizontal)
                  Expanded(
                    flex: 1,
                    child: allUsersAsync.when(
                      data:
                          (allUsers) => ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.all(8),
                            physics: const BouncingScrollPhysics(),
                            itemCount: allUsers.length,
                            itemBuilder: (context, index) {
                              final user = allUsers[index];
                              return _buildUserAvatar(user);
                            },
                          ),
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error:
                          (error, stack) => Center(
                            child: Text('Error loading users: $error'),
                          ),
                    ),
                  ),

                  const Divider(),

                  // Chat previews list
                  Expanded(
                    flex: 4,
                    child: chatPreviewsAsync.when(
                      data:
                          (previews) =>
                              previews.isEmpty
                                  ? Center(
                                    child: Text(
                                      "No conversations yet",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  )
                                  : ListView.builder(
                                    itemCount: previews.length,
                                    itemBuilder: (context, index) {
                                      final preview = previews[index];
                                      return _buildChatPreview(preview);
                                    },
                                  ),
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error:
                          (error, stack) => Center(
                            child: Text('Error loading chats: $error'),
                          ),
                    ),
                  ),

                  // Login button (for testing)
                ],
              ),
    );
  }

  Widget _buildUserAvatar(UserModel user) {
    return GestureDetector(
      onTap: () => _navigateToChat(user),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.amber,
              foregroundImage:
                  user.imageUrl != null
                      ? NetworkImage(user.imageUrl!)
                      : const AssetImage('assets/images/avatar.png')
                          as ImageProvider,
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 60,
              child: Text(
                capitalize(user.name),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatPreview(ChatPreview preview) {
    return GestureDetector(
      onTap: () async {
        // Create UserModel from preview data
        final user = UserModel(
          id: preview.userId,
          name: preview.name,
          imageUrl: preview.imageUrl,
        );
        await _navigateToChat(user);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.amber,
              foregroundImage:
                  preview.imageUrl != null
                      ? NetworkImage(preview.imageUrl!)
                      : const AssetImage('assets/images/avatar.png')
                          as ImageProvider,
            ),

            const SizedBox(width: 12),

            // Message content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    capitalize(preview.name),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    preview.latestMessage,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),

            // Time and unread count
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatChatTime(preview.createdAt),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const SizedBox(height: 4),
                if (preview.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      preview.unreadCount > 99
                          ? '99+'
                          : preview.unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
