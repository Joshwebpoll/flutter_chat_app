import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:music_player_app/global_socket/socket.dart';
import 'package:music_player_app/models/message_model.dart';
import 'package:music_player_app/models/user_model.dart';
import 'package:music_player_app/reuseable_dart/capitalize.dart';
import 'package:music_player_app/reuseable_dart/image_upload.dart';
import 'package:music_player_app/reuseable_dart/time_format.dart';
import 'package:music_player_app/services/auth_service.dart';
import 'package:music_player_app/services/message_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  final UserModel user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final authService = Services();
  final socket = SocketService();
  // late IO.Socket socket;
  final ScrollController _scrollController = ScrollController();
  double _keyboardHeight = 0;
  bool isLoading = true;

  File? _image;
  final picker = ImagePicker();

  List<Message> myMessage = [];
  String? myUser;
  final TextEditingController messageController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    socket.removeListener('chatMessage');
    socket.listen('chatMessage', (data) {
      print('📩 New message: $data');
      final message = Message.fromJson(data);

      if (message.sender == widget.user.id) {
        // Auto-mark as read
        socket.sendMessage('mark-read', {'from': message.sender});
      }

      setState(() {
        myMessage.add(message);
      });
      _scrollToBottom();
    });
    getMessages();
    getUserx().then((_) {
      //initSocket(); // only connect after user is known
    });
    markMessagesAsRead();
  }

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty || myUser == null) return;

    final message = {"to": widget.user.id, 'message': text};

    // ✅ Create local copy
    final newMsg = Message(
      id: UniqueKey().toString(),
      sender: myUser!,
      receiver: widget.user.id,
      message: text,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    setState(() {
      myMessage.add(newMsg);
    });

    socket.sendMessage('chatMessage', message);
    messageController.clear();
    _scrollToBottom();
  }

  @override
  void dispose() {
    //  socket.dispose();
    socket.removeListener("chatMessage");
    socket.removeListener("mark-read");
    // socket.removeListener("chatMessage");
    messageController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  Future<void> getMessages() async {
    setState(() {
      isLoading = true;
    });
    try {
      final message = MessageService();
      final mess = await message.previousMessage(widget.user.id);
      print(widget.user.id);
      setState(() {
        myMessage.addAll(mess);
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getUserx() async {
    try {
      final mess = await authService.getMe();
      setState(() {
        myUser = mess.id;
      });
      print(myUser);
    } catch (e) {
      print(e);
    }
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

  void markMessagesAsRead() {
    socket.sendMessage('mark-read', {
      'from': widget.user.id, // the other person you're chatting with
    });
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
    print(_image);
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    if (viewInsets != _keyboardHeight && viewInsets > 0) {
      _keyboardHeight = viewInsets;
      // Keyboard just opened
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(45),
        child: AppBar(
          leadingWidth: 20,
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
            child:
                isLoading
                    ? Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      ),
                    )
                    : ListView.builder(
                      scrollDirection: Axis.vertical,
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8),

                      itemCount: myMessage.length,
                      itemBuilder: (context, index) {
                        final messagex = myMessage[index];
                        print("meee ${messagex.message}");
                        return Column(
                          children: [
                            Align(
                              alignment:
                                  messagex.sender == myUser
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
                                      messagex.sender == myUser
                                          ? Colors.blue
                                          : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      messagex.sender == myUser
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      messagex.message,
                                      style: TextStyle(
                                        color:
                                            messagex.sender == myUser
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      formatTime(messagex.createdAt),
                                      style: TextStyle(fontSize: 13),
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
                IconButton(
                  icon: const Icon(Icons.file_upload),
                  onPressed: () async {
                    await pickImage();
                  },
                ),
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
