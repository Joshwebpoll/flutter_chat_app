// // pubspec.yaml dependencies you'll need:
// // dependencies:
// //   flutter:
// //     sdk: flutter
// //   socket_io_client: ^2.0.3+1
// //   intl: ^0.18.1
// //   shared_preferences: ^2.2.2
// //   http: ^1.1.0

// // main.dart
// import 'package:flutter/material.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Load saved authentication token
//   await AuthService().loadToken();

//   runApp(ChatApp());
// }

// class ChatApp extends StatelessWidget {
//   final AuthService _authService = AuthService();

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Chat App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         fontFamily: 'SF Pro Display',
//       ),
//       home: _authService.isAuthenticated ? ChatPreviewScreen() : LoginScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// // Models
// class ChatPreview {
//   final String id;
//   final String name;
//   final String lastMessage;
//   final DateTime lastMessageTime;
//   final String avatar;
//   final int unreadCount;
//   final bool isOnline;

//   ChatPreview({
//     required this.id,
//     required this.name,
//     required this.lastMessage,
//     required this.lastMessageTime,
//     required this.avatar,
//     this.unreadCount = 0,
//     this.isOnline = false,
//   });
// }

// class Message {
//   final String id;
//   final String content;
//   final String senderId;
//   final String senderName;
//   final DateTime timestamp;
//   final MessageType type;
//   final bool isMe;

//   Message({
//     required this.id,
//     required this.content,
//     required this.senderId,
//     required this.senderName,
//     required this.timestamp,
//     this.type = MessageType.text,
//     required this.isMe,
//   });
// }

// enum MessageType { text, image, file }

// // Auth Service
// class AuthService {
//   static final AuthService _instance = AuthService._internal();
//   factory AuthService() => _instance;
//   AuthService._internal();

//   String? _token;
//   String? _userId;
//   String? _userName;

//   String? get token => _token;
//   String? get userId => _userId;
//   String? get userName => _userName;

//   Future<void> loadToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     _token = prefs.getString('jwt_token');
//     _userId = prefs.getString('user_id');
//     _userName = prefs.getString('user_name');
//   }

//   Future<void> saveToken(String token, String userId, String userName) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('jwt_token', token);
//     await prefs.setString('user_id', userId);
//     await prefs.setString('user_name', userName);
//     _token = token;
//     _userId = userId;
//     _userName = userName;
//   }

//   Future<void> clearToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('jwt_token');
//     await prefs.remove('user_id');
//     await prefs.remove('user_name');
//     _token = null;
//     _userId = null;
//     _userName = null;
//   }

//   bool get isAuthenticated => _token != null && _token!.isNotEmpty;

//   // Login method - replace with your actual login API
//   Future<bool> login(String email, String password) async {
//     try {
//       final response = await http.post(
//         Uri.parse(
//           'https://buddy-chat-backend-ii8g.onrender.com/api/v1/auth/login',
//         ), // Replace with your login endpoint
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({'email': email, 'password': password}),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         await saveToken(data['token'], 'osh', 'me');
//         return true;
//       }
//       return false;
//     } catch (e) {
//       print('Login error: $e');
//       return false;
//     }
//   }

//   Future<void> logout() async {
//     await clearToken();
//     SocketService().disconnect();
//   }
// }

// // Socket Service with JWT Authentication and Room Management
// class SocketService {
//   static final SocketService _instance = SocketService._internal();
//   factory SocketService() => _instance;
//   SocketService._internal();

//   IO.Socket? socket;
//   bool isConnected = false;
//   final AuthService _authService = AuthService();
//   String? currentRoom;
//   Map<String, Function(dynamic)> _messageCallbacks = {};

//   void connect(String url) {
//     // If already connected, don't reconnect
//     if (isConnected && socket != null) {
//       print('Socket already connected');
//       return;
//     }

//     if (_authService.token == null) {
//       print('No token available for socket connection');
//       return;
//     }

//     // Disconnect existing socket if any
//     if (socket != null) {
//       socket!.disconnect();
//     }

//     socket = IO.io(url, <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': false,
//       'auth': {'token': _authService.token},
//       'extraHeaders': {'Authorization': 'Bearer ${_authService.token}'},
//     });

//     socket!.connect();

//     socket!.onConnect((_) {
//       print('Connected to server');
//       isConnected = true;
//     });

//     socket!.onDisconnect((_) {
//       print('Disconnected from server');
//       isConnected = false;
//       currentRoom = null;
//     });

//     socket!.on('connect_error', (error) {
//       print('Connection error: $error');
//       if (error.toString().contains('authentication') ||
//           error.toString().contains('token') ||
//           error.toString().contains('unauthorized')) {
//         _handleAuthError();
//       }
//     });

//     socket!.on('error', (error) {
//       print('Socket error: $error');
//       if (error.toString().contains('token') ||
//           error.toString().contains('unauthorized')) {
//         _handleAuthError();
//       }
//     });
//   }

//   void _handleAuthError() {
//     print('Authentication error - token might be expired');
//     disconnect();
//   }

//   void disconnect() {
//     if (socket != null) {
//       socket!.disconnect();
//       socket = null;
//     }
//     isConnected = false;
//     currentRoom = null;
//     _messageCallbacks.clear();
//   }

//   void reconnectWithNewToken() {
//     if (socket != null) {
//       String url = socket!.io.uri;
//       disconnect();
//       connect(url);
//     }
//   }

//   void joinRoom(String roomId) {
//     if (!isConnected || _authService.token == null) {
//       print('Cannot join room: not connected or no token');
//       return;
//     }

//     // Leave current room if different
//     if (currentRoom != null && currentRoom != roomId) {
//       leaveRoom(currentRoom!);
//     }

//     if (currentRoom != roomId) {
//       socket?.emit('join_room', {
//         'roomId': roomId,
//         'token': _authService.token,
//       });
//       currentRoom = roomId;
//       print('Joined room: $roomId');
//     }
//   }

//   void leaveRoom(String roomId) {
//     if (!isConnected || _authService.token == null) {
//       return;
//     }

//     socket?.emit('leave_room', {'roomId': roomId, 'token': _authService.token});

//     if (currentRoom == roomId) {
//       currentRoom = null;
//     }

//     // Remove message callback for this room
//     _messageCallbacks.remove(roomId);
//     print('Left room: $roomId');
//   }

//   void sendMessage(String roomId, String message) {
//     if (!isConnected || _authService.token == null) {
//       print('Cannot send message: not connected or no token');
//       return;
//     }
//     socket?.emit('send_message', {
//       'roomId': roomId,
//       'message': message,
//       'timestamp': DateTime.now().toIso8601String(),
//       'senderId': _authService.userId,
//       'senderName': _authService.userName,
//       'token': _authService.token,
//     });
//   }

//   void onMessage(String roomId, Function(dynamic) callback) {
//     _messageCallbacks[roomId] = callback;

//     // Remove existing listener to avoid duplicates
//     socket?.off('new_message');

//     socket?.on('new_message', (data) {
//       String messageRoomId = data['roomId'] ?? '';
//       if (_messageCallbacks.containsKey(messageRoomId)) {
//         _messageCallbacks[messageRoomId]!(data);
//       }
//     });
//   }

//   void removeMessageListener(String roomId) {
//     _messageCallbacks.remove(roomId);
//     if (_messageCallbacks.isEmpty) {
//       socket?.off('new_message');
//     }
//   }

//   void onUserOnline(Function(dynamic) callback) {
//     socket?.on('user_online', callback);
//   }

//   void onUserOffline(Function(dynamic) callback) {
//     socket?.on('user_offline', callback);
//   }

//   // Get connection status
//   bool get connectionStatus => isConnected;
//   String? get activeRoom => currentRoom;
// }

// // Login Screen
// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _authService = AuthService();
//   bool _isLoading = false;

//   Future<void> _login() async {
//     if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please enter email and password')),
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     final success = await _authService.login(
//       _emailController.text.trim(),
//       _passwordController.text,
//     );

//     setState(() {
//       _isLoading = false;
//     });

//     if (success) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => ChatPreviewScreen()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Login failed. Please try again.')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.all(24),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'Welcome Back',
//                 style: TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//               SizedBox(height: 8),
//               Text(
//                 'Sign in to continue',
//                 style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
//               ),
//               SizedBox(height: 48),
//               TextField(
//                 controller: _emailController,
//                 decoration: InputDecoration(
//                   labelText: 'Email',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   prefixIcon: Icon(Icons.email),
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               SizedBox(height: 16),
//               TextField(
//                 controller: _passwordController,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   prefixIcon: Icon(Icons.lock),
//                 ),
//                 obscureText: true,
//               ),
//               SizedBox(height: 32),
//               SizedBox(
//                 width: double.infinity,
//                 height: 48,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _login,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child:
//                       _isLoading
//                           ? CircularProgressIndicator(color: Colors.white)
//                           : Text(
//                             'Sign In',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.white,
//                             ),
//                           ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
// }

// // Chat Preview Screen
// class ChatPreviewScreen extends StatefulWidget {
//   @override
//   _ChatPreviewScreenState createState() => _ChatPreviewScreenState();
// }

// class _ChatPreviewScreenState extends State<ChatPreviewScreen> {
//   final SocketService _socketService = SocketService();
//   final AuthService _authService = AuthService();
//   List<ChatPreview> chats = [];

//   @override
//   void initState() {
//     super.initState();
//     _initializeSocket();
//     _loadMockData();
//   }

//   void _initializeSocket() {
//     if (_authService.isAuthenticated) {
//       // Replace with your backend URL
//       _socketService.connect('https://buddy-chat-backend-ii8g.onrender.com');
//     } else {
//       // Redirect to login if not authenticated
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => LoginScreen()),
//         );
//       });
//     }
//   }

//   Future<void> _logout() async {
//     await _authService.logout();
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => LoginScreen()),
//     );
//   }

//   void _loadMockData() {
//     // Mock data - replace with your actual data loading
//     setState(() {
//       chats = [
//         ChatPreview(
//           id: '1',
//           name: 'John Doe',
//           lastMessage: 'Hey, how are you doing?',
//           lastMessageTime: DateTime.now().subtract(Duration(minutes: 5)),
//           avatar: 'JD',
//           unreadCount: 2,
//           isOnline: true,
//         ),
//         ChatPreview(
//           id: '2',
//           name: 'Sarah Wilson',
//           lastMessage: 'Thanks for the help yesterday!',
//           lastMessageTime: DateTime.now().subtract(Duration(hours: 1)),
//           avatar: 'SW',
//           unreadCount: 0,
//           isOnline: false,
//         ),
//         ChatPreview(
//           id: '3',
//           name: 'Team Alpha',
//           lastMessage: 'Meeting at 3 PM today',
//           lastMessageTime: DateTime.now().subtract(Duration(hours: 2)),
//           avatar: 'TA',
//           unreadCount: 5,
//           isOnline: true,
//         ),
//       ];
//     });
//   }

//   @override
//   void dispose() {
//     // Don't disconnect socket here - it should remain connected
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text(
//           'Messages',
//           style: TextStyle(
//             fontSize: 28,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.search, color: Colors.black),
//             onPressed: () {
//               // Implement search functionality
//             },
//           ),
//           PopupMenuButton<String>(
//             icon: Icon(Icons.more_vert, color: Colors.black),
//             onSelected: (value) {
//               if (value == 'logout') {
//                 _logout();
//               }
//             },
//             itemBuilder:
//                 (context) => [
//                   PopupMenuItem(
//                     value: 'logout',
//                     child: Row(
//                       children: [
//                         Icon(Icons.logout, color: Colors.red),
//                         SizedBox(width: 8),
//                         Text('Logout', style: TextStyle(color: Colors.red)),
//                       ],
//                     ),
//                   ),
//                 ],
//           ),
//         ],
//       ),
//       body: ListView.separated(
//         padding: EdgeInsets.symmetric(vertical: 8),
//         itemCount: chats.length,
//         separatorBuilder:
//             (context, index) =>
//                 Divider(height: 1, color: Colors.grey.shade200, indent: 80),
//         itemBuilder: (context, index) {
//           final chat = chats[index];
//           return ChatPreviewTile(
//             chat: chat,
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder:
//                       (context) => ChatScreen(
//                         chatId: chat.id,
//                         chatName: chat.name,
//                         isOnline: chat.isOnline,
//                       ),
//                 ),
//               ).then((_) {
//                 // When returning from chat screen, refresh the preview if needed
//                 setState(() {
//                   // Optionally refresh chat list or update last seen messages
//                 });
//               });
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Implement new chat functionality
//         },
//         backgroundColor: Colors.blue,
//         child: Icon(Icons.chat_bubble, color: Colors.white),
//       ),
//     );
//   }
// }

// // Chat Preview Tile Widget
// class ChatPreviewTile extends StatelessWidget {
//   final ChatPreview chat;
//   final VoidCallback onTap;

//   const ChatPreviewTile({Key? key, required this.chat, required this.onTap})
//     : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         child: Row(
//           children: [
//             Stack(
//               children: [
//                 CircleAvatar(
//                   radius: 28,
//                   backgroundColor: Colors.blue.shade100,
//                   child: Text(
//                     chat.avatar,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.blue.shade700,
//                     ),
//                   ),
//                 ),
//                 if (chat.isOnline)
//                   Positioned(
//                     right: 0,
//                     bottom: 0,
//                     child: Container(
//                       width: 16,
//                       height: 16,
//                       decoration: BoxDecoration(
//                         color: Colors.green,
//                         shape: BoxShape.circle,
//                         border: Border.all(color: Colors.white, width: 2),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//             SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         chat.name,
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black,
//                         ),
//                       ),
//                       Text(
//                         _formatTime(chat.lastMessageTime),
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 4),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           chat.lastMessage,
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey.shade700,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       if (chat.unreadCount > 0)
//                         Container(
//                           margin: EdgeInsets.only(left: 8),
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 4,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.blue,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Text(
//                             chat.unreadCount.toString(),
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _formatTime(DateTime time) {
//     final now = DateTime.now();
//     final difference = now.difference(time);

//     if (difference.inDays > 0) {
//       return DateFormat('dd/MM').format(time);
//     } else if (difference.inHours > 0) {
//       return '${difference.inHours}h';
//     } else if (difference.inMinutes > 0) {
//       return '${difference.inMinutes}m';
//     } else {
//       return 'now';
//     }
//   }
// }

// // Chat Screen
// class ChatScreen extends StatefulWidget {
//   final String chatId;
//   final String chatName;
//   final bool isOnline;

//   const ChatScreen({
//     Key? key,
//     required this.chatId,
//     required this.chatName,
//     required this.isOnline,
//   }) : super(key: key);

//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final SocketService _socketService = SocketService();
//   final AuthService _authService = AuthService();
//   List<Message> messages = [];

//   @override
//   void initState() {
//     super.initState();
//     if (_authService.isAuthenticated) {
//       _joinRoom();
//       _loadMessages();
//       _listenForMessages();
//     } else {
//       // Redirect to login if not authenticated
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => LoginScreen()),
//         );
//       });
//     }
//   }

//   void _joinRoom() {
//     _socketService.joinRoom(widget.chatId);
//   }

//   void _loadMessages() {
//     // Mock messages - replace with your actual message loading
//     setState(() {
//       messages = [
//         Message(
//           id: '1',
//           content: 'Hey there! How are you doing?',
//           senderId: 'other',
//           senderName: widget.chatName,
//           timestamp: DateTime.now().subtract(Duration(minutes: 10)),
//           isMe: false,
//         ),
//         Message(
//           id: '2',
//           content: 'I\'m doing great! Thanks for asking. How about you?',
//           senderId: _authService.userId ?? 'me',
//           senderName: _authService.userName ?? 'Me',
//           timestamp: DateTime.now().subtract(Duration(minutes: 9)),
//           isMe: true,
//         ),
//         Message(
//           id: '3',
//           content:
//               'Everything is going well. Working on some exciting projects!',
//           senderId: 'other',
//           senderName: widget.chatName,
//           timestamp: DateTime.now().subtract(Duration(minutes: 5)),
//           isMe: false,
//         ),
//       ];
//     });
//     _scrollToBottom();
//   }

//   void _listenForMessages() {
//     _socketService.onMessage(widget.chatId, (data) {
//       final newMessage = Message(
//         id: data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
//         content: data['message'] ?? '',
//         senderId: data['senderId'] ?? '',
//         senderName: data['senderName'] ?? '',
//         timestamp: DateTime.parse(
//           data['timestamp'] ?? DateTime.now().toIso8601String(),
//         ),
//         isMe: data['senderId'] == (_authService.userId ?? 'me'),
//       );

//       setState(() {
//         messages.add(newMessage);
//       });
//       _scrollToBottom();
//     });
//   }

//   void _sendMessage() {
//     if (_messageController.text.trim().isEmpty) return;

//     final messageText = _messageController.text.trim();
//     final newMessage = Message(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       content: messageText,
//       senderId: _authService.userId ?? 'me',
//       senderName: _authService.userName ?? 'Me',
//       timestamp: DateTime.now(),
//       isMe: true,
//     );

//     setState(() {
//       messages.add(newMessage);
//     });

//     _socketService.sendMessage(widget.chatId, messageText);
//     _messageController.clear();
//     _scrollToBottom();
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 1,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             // Leave the current room when going back
//             _socketService.leaveRoom(widget.chatId);
//             Navigator.pop(context);
//           },
//         ),
//         title: Row(
//           children: [
//             CircleAvatar(
//               radius: 18,
//               backgroundColor: Colors.blue.shade100,
//               child: Text(
//                 widget.chatName.substring(0, 2).toUpperCase(),
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.blue.shade700,
//                 ),
//               ),
//             ),
//             SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.chatName,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black,
//                     ),
//                   ),
//                   if (widget.isOnline)
//                     Text(
//                       'Online',
//                       style: TextStyle(fontSize: 12, color: Colors.green),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.videocam, color: Colors.black),
//             onPressed: () {
//               // Implement video call
//             },
//           ),
//           IconButton(
//             icon: Icon(Icons.call, color: Colors.black),
//             onPressed: () {
//               // Implement voice call
//             },
//           ),
//           IconButton(
//             icon: Icon(Icons.more_vert, color: Colors.black),
//             onPressed: () {
//               // Implement menu
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               controller: _scrollController,
//               padding: EdgeInsets.all(16),
//               itemCount: messages.length,
//               itemBuilder: (context, index) {
//                 return MessageBubble(message: messages[index]);
//               },
//             ),
//           ),
//           _buildMessageInput(),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageInput() {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.shade200,
//             offset: Offset(0, -1),
//             blurRadius: 4,
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           IconButton(
//             icon: Icon(Icons.add, color: Colors.blue),
//             onPressed: () {
//               // Implement attachment functionality
//             },
//           ),
//           Expanded(
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 borderRadius: BorderRadius.circular(24),
//               ),
//               child: TextField(
//                 controller: _messageController,
//                 decoration: InputDecoration(
//                   hintText: 'Type a message...',
//                   border: InputBorder.none,
//                   contentPadding: EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 12,
//                   ),
//                 ),
//                 maxLines: null,
//                 onSubmitted: (_) => _sendMessage(),
//               ),
//             ),
//           ),
//           SizedBox(width: 8),
//           GestureDetector(
//             onTap: _sendMessage,
//             child: Container(
//               padding: EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.blue,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(Icons.send, color: Colors.white, size: 20),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     // Clean up listeners and leave room when disposing chat screen
//     _socketService.removeMessageListener(widget.chatId);
//     _socketService.leaveRoom(widget.chatId);
//     _messageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
// }

// // Message Bubble Widget
// class MessageBubble extends StatelessWidget {
//   final Message message;

//   const MessageBubble({Key? key, required this.message}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 16),
//       child: Row(
//         mainAxisAlignment:
//             message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           if (!message.isMe) ...[
//             CircleAvatar(
//               radius: 12,
//               backgroundColor: Colors.blue.shade100,
//               child: Text(
//                 message.senderName.substring(0, 1).toUpperCase(),
//                 style: TextStyle(
//                   fontSize: 10,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.blue.shade700,
//                 ),
//               ),
//             ),
//             SizedBox(width: 8),
//           ],
//           Flexible(
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               decoration: BoxDecoration(
//                 color: message.isMe ? Colors.blue : Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(20),
//                   topRight: Radius.circular(20),
//                   bottomLeft:
//                       message.isMe ? Radius.circular(20) : Radius.circular(4),
//                   bottomRight:
//                       message.isMe ? Radius.circular(4) : Radius.circular(20),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.shade200,
//                     offset: Offset(0, 1),
//                     blurRadius: 2,
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     message.content,
//                     style: TextStyle(
//                       color: message.isMe ? Colors.white : Colors.black,
//                       fontSize: 16,
//                     ),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     DateFormat('HH:mm').format(message.timestamp),
//                     style: TextStyle(
//                       color:
//                           message.isMe ? Colors.white70 : Colors.grey.shade600,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           if (message.isMe) ...[
//             SizedBox(width: 8),
//             CircleAvatar(
//               radius: 12,
//               backgroundColor: Colors.green.shade100,
//               child: Text(
//                 'M',
//                 style: TextStyle(
//                   fontSize: 10,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.green.shade700,
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }
