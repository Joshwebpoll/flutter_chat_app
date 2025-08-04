import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player_app/global_socket/socket_testing.dart';
import 'package:music_player_app/providers/chat_provider.dart';
import 'package:music_player_app/providers/home_providers.dart';
import 'package:music_player_app/providers/me_provider.dart';
import 'package:music_player_app/reuseable_dart/capitalize.dart';
import 'package:music_player_app/reuseable_dart/time_format.dart';
import 'package:music_player_app/services/auth_service.dart';
import '../models/user_model.dart';
import '../models/message_model.dart';
import '../services/message_service.dart';
import '../global_socket/socket.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends ConsumerStatefulWidget {
  final UserModel user;
  const ChatScreen({super.key, required this.user});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final MessageService _msgSvc = MessageService();
  final socket = SocketService();
  final TextEditingController messageController = TextEditingController();
  String? userId;
  final service = Services();
  List<Message> messages = [];
  String? myUser;
  bool isLoading = true;
  double _keyboardHeight = 0;
  late IO.Socket sockets;

  @override
  void initState() {
    super.initState();
    // _loadMessages();
    _markRead();
    _loadUserId();
    // socket.listen('chatMessage', _onNewMessage);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatPreviewsProvider.notifier).markAsRead(widget.user.id);
    });

    Future.microtask(() async {
      await ref.read(messageProvider.notifier).loadMessages((widget.user.id));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    });
  }

  void _markRead() {
    socket.sendMessage('mark-read', {'from': widget.user.id});
    // ref.read(chatPreviewsProvider.notifier).markAsRead(widget.user.id);
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void sendMessage() async {
    final text = messageController.text.trim();

    final userId = ref.watch(meProvider).asData?.value.id;
    if (text.isEmpty || userId == null) return;

    final message = {"to": widget.user.id, 'message': text};

    // ✅ Create local copy
    final newMsg = Message(
      id: UniqueKey().toString(),
      sender: userId,
      receiver: widget.user.id,
      message: text,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final prev = {
      "id": UniqueKey().toString(),
      "sender": userId,
      "receiver": widget.user.id,
      "imageUrl": widget.user.imageUrl,
      "message": text,
      "createdAt": DateTime.now(),
      "updatedAt": DateTime.now(),
    };
    final myId = await ref.read(meProvider.future);
    ref.read(messageProvider.notifier).sendMessage(newMsg);
    ref.read(chatPreviewsProvider.notifier).updateChatPreview(prev, myId.id);

    socket.sendMessage('chatMessage', message);
    messageController.clear();
    _scrollToBottom();
  }

  Future<void> _loadUserId() async {
    final user = await ref.read(meProvider.future); // Get the SingleModel
    userId = user.id;
  }

  @override
  Widget build(BuildContext context) {
    final messageState = ref.watch(messageProvider);

    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    if (viewInsets != _keyboardHeight && viewInsets > 0) {
      _keyboardHeight = viewInsets;
      // Keyboard just opened
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }

    ref.listen<AsyncValue<List<Message>>>(messageProvider, (prev, next) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    });
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(45),
        child: AppBar(
          leadingWidth: 30,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 20),
            onPressed: () => Navigator.pop(context, 'read'),
          ),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage:
                    widget.user.imageUrl != null
                        ? NetworkImage(widget.user.imageUrl!)
                        : AssetImage('assets/images/avatar.png'),
              ),
              const SizedBox(width: 5),

              Text(
                capitalize(widget.user.name),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messageState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Error: $e")),
              data:
                  (messages) => ListView.builder(
                    scrollDirection: Axis.vertical,
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),

                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      final m = messages[i];

                      return Column(
                        children: [
                          Align(
                            alignment:
                                m.receiver == widget.user.id
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width *
                                    0.7, // ⬅️ limit width
                              ),
                              decoration: BoxDecoration(
                                color:
                                    m.receiver == widget.user.id
                                        ? Color(0xFf22c55e)
                                        : Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    m.sender == userId
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.message,
                                    style: TextStyle(
                                      color:
                                          m.receiver == widget.user.id
                                              ? Colors.white
                                              : Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    formatTime(m.createdAt),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color:
                                          m.receiver == widget.user.id
                                              ? Colors.white
                                              : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
            ),
          ),
          // Expanded(
          //   child:
          //       isLoading
          //           ? Center(
          //             child: SizedBox(
          //               height: 20,
          //               width: 20,
          //               child: CircularProgressIndicator(),
          //             ),
          //           )
          //           : ListView.builder(
          //             scrollDirection: Axis.vertical,
          //             controller: _scrollController,
          //             padding: const EdgeInsets.all(8),

          //             itemCount: messages.length,
          //             itemBuilder: (context, i) {
          //               final m = messages[i];

          //               return Column(
          //                 children: [
          //                   Align(
          //                     alignment:
          //                         m.receiver == widget.user.id
          //                             ? Alignment.centerRight
          //                             : Alignment.centerLeft,
          //                     child: Container(
          //                       padding: const EdgeInsets.symmetric(
          //                         horizontal: 12,
          //                         vertical: 8,
          //                       ),
          //                       margin: const EdgeInsets.symmetric(vertical: 4),
          //                       constraints: BoxConstraints(
          //                         maxWidth:
          //                             MediaQuery.of(context).size.width *
          //                             0.7, // ⬅️ limit width
          //                       ),
          //                       decoration: BoxDecoration(
          //                         color:
          //                             m.receiver == widget.user.id
          //                                 ? Color(0xFf22c55e)
          //                                 : Colors.grey[300],
          //                         borderRadius: BorderRadius.circular(12),
          //                       ),
          //                       child: Column(
          //                         crossAxisAlignment:
          //                             m.sender == userId
          //                                 ? CrossAxisAlignment.end
          //                                 : CrossAxisAlignment.start,
          //                         children: [
          //                           Text(
          //                             m.message,
          //                             style: TextStyle(
          //                               color:
          //                                   m.receiver == widget.user.id
          //                                       ? Colors.white
          //                                       : Colors.black,
          //                             ),
          //                           ),
          //                           SizedBox(height: 5),
          //                           Text(
          //                             formatTime(m.createdAt),
          //                             style: TextStyle(
          //                               fontSize: 13,
          //                               color:
          //                                   m.receiver == widget.user.id
          //                                       ? Colors.white
          //                                       : Colors.black,
          //                             ),
          //                           ),
          //                         ],
          //                       ),
          //                     ),
          //                   ),
          //                 ],
          //               );
          //             },
          //           ),
          // ),

          //Expanded(child: Text(widget.user.id)),
          // 🔽 This always sticks to bottom
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// body:
//           isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : ListView.builder(
//                 itemCount: messages.length,
//                 controller: _scrollController,
//                 itemBuilder: (_, i) {
//                   final m = messages[i];
//                   return Align(
//                     alignment:
//                         m.sender == myUser
//                             ? Alignment.centerRight
//                             : Alignment.centerLeft,
//                     child: Container(
//                       margin: const EdgeInsets.all(4),
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color:
//                             m.sender == myUser
//                                 ? Colors.blue
//                                 : Colors.grey.shade200,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(m.message),
//                     ),
//                   );
//                 },
//               ),
//       bottomNavigationBar: TextField(
//         onSubmitted: (text) {
//           // send logic
//         },