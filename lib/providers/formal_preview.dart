// import 'package:flutter/material.dart';
// import 'package:music_player_app/global_socket/socket.dart';
// import 'package:music_player_app/models/chat_preview_model.dart';
// import 'package:music_player_app/models/message_model.dart';
// import 'package:music_player_app/models/user_model.dart';
// import 'package:music_player_app/reuseable_dart/capitalize.dart';
// import 'package:music_player_app/reuseable_dart/time_format.dart';

// import 'package:music_player_app/services/auth_service.dart';
// import 'package:music_player_app/services/message_service.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final authService = Services();
//   final message = MessageService();

//   List<UserModel> allUsers = [];
//   bool isLoading = true;
//   String? myUser;

//   List<Message> myMessage = [];
//   List<ChatPreview> previews = [];
//   String? errorMessage;

//   final TextEditingController messageController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     setupSocketListeners();
//     fetchUsers();
//     fetchPreviews();
//   }

//   // ✅ Always remove old listeners first to prevent duplicates
//   void setupSocketListeners() {
//     // Remove any existing listeners first
//     SocketService().removeListener("mark-read");
//     SocketService().removeListener("chatMessage");

//     print("🔄 Setting up fresh socket listeners...");

//     // Listen for mark-read events
//     SocketService().listen("mark-read", (data) {
//       print("📖 Mark read received: $data");
//       if (!mounted) return; // Safety check

//       final senderId = data['senderId'];

//       setState(() {
//         final index = previews.indexWhere((p) => p.userId == senderId);
//         if (index != -1) {
//           previews[index] = previews[index].copyWith(unreadCount: 0);
//         }
//       });
//     });

//     // Listen for new chat messages
//     SocketService().listen("chatMessage", (data) {
//       print("📥 New message received: $data");
//       if (!mounted) return; // Safety check

//       _handleNewMessage(data);
//     });

//     print("✅ Socket listeners set up successfully");
//   }

//   // ✅ Separated message handling logic for better organization
//   // void _handleNewMessage(Map<String, dynamic> data) {
//   //   final chatUserId = data['sender'];

//   //   // Find the user who sent the message
//   //   final userIndex = allUsers.indexWhere((user) => user.id == chatUserId);
//   //   if (userIndex == -1) {
//   //     print("❌ User not found for ID: $chatUserId");
//   //     return;
//   //   }

//   //   final user = allUsers[userIndex];

//   //   setState(() {
//   //     final existingIndex = previews.indexWhere((p) => p.userId == chatUserId);

//   //     if (existingIndex != -1) {
//   //       // Update existing preview
//   //       final existing = previews.removeAt(existingIndex);

//   //       final updated = ChatPreview(
//   //         userId: chatUserId,
//   //         name: user.name,
//   //         imageUrl: user.imageUrl,
//   //         latestMessage: data['message'],
//   //         unreadCount: existing.unreadCount + 1,
//   //         createdAt: DateTime.parse(data['createdAt']),
//   //       );

//   //       // Move to top of the list
//   //       previews.insert(0, updated);
//   //     } else {
//   //       // Create new preview for first-time chat
//   //       final newPreview = ChatPreview(
//   //         userId: chatUserId,
//   //         name: user.name,
//   //         imageUrl: user.imageUrl,
//   //         latestMessage: data['message'],
//   //         unreadCount: 1,
//   //         createdAt: DateTime.parse(data['createdAt']),
//   //       );

//   //       previews.insert(0, newPreview);
//   //     }
//   //   });
//   // }

//   Future<void> fetchUsers() async {
//     try {
//       final users = await authService.getUser();
//       setState(() {
//         allUsers = users;
//         isLoading = false;
//       });
//     } catch (e) {
//       print("❌ Error fetching users: $e");
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> fetchPreviews() async {
//     try {
//       final chatPreview = await message.chatPreviews();
//       setState(() {
//         previews = chatPreview;
//         isLoading = false;
//       });
//     } catch (e) {
//       print("❌ Error fetching previews: $e");
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   // ✅ Added refresh method to update previews when returning from chat
//   Future<void> _refreshPreviews() async {
//     try {
//       // ✅ Re-setup socket listeners every time we refresh
//       setupSocketListeners();

//       final updatedPreviews = await message.chatPreviews();
//       setState(() {
//         previews = updatedPreviews;
//       });
//     } catch (e) {
//       print("❌ Error refreshing previews: $e");
//     }
//   }

//   // ✅ Handle navigation to chat with proper result handling
//   Future<void> _navigateToChat(UserModel user) async {
//     print("🚀 Navigating to chat with ${user.name}");

//     final result = await Navigator.pushNamed(context, '/chat', arguments: user);

//     print("🔙 Returned from chat, result: $result");

//     // ✅ CRITICAL: Always re-setup socket listeners when returning from any navigation
//     print("🔄 Re-setting up socket listeners after navigation");
//     setupSocketListeners();

//     // Handle the result when returning from chat
//     if (result == 'read') {
//       // Mark as read in local state immediately
//       setState(() {
//         final previewIndex = previews.indexWhere((p) => p.userId == user.id);
//         if (previewIndex != -1) {
//           previews[previewIndex] = previews[previewIndex].copyWith(
//             unreadCount: 0,
//           );
//         }
//       });

//       // Also refresh from server to get latest data
//       await _refreshPreviews();
//     } else {
//       // Even if not marked as read, refresh to get latest messages
//       await _refreshPreviews();
//     }
//   }

//   @override
//   void dispose() {
//     // ✅ Clean up socket listeners
//     SocketService().removeListener("chatMessage");
//     SocketService().removeListener("mark-read");
//     messageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "BuddyChat",
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         // ✅ Added refresh action
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: () {
//               print("🔄 Manual refresh triggered");
//               _refreshPreviews();
//             },
//           ),
//         ],
//       ),
//       body:
//           isLoading
//               ? Center(child: CircularProgressIndicator())
//               : Column(
//                 children: [
//                   // Users list (horizontal)
//                   Expanded(
//                     flex: 1,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       padding: const EdgeInsets.all(8),
//                       physics: BouncingScrollPhysics(),
//                       itemCount: allUsers.length,
//                       itemBuilder: (context, index) {
//                         final user = allUsers[index];

//                         return GestureDetector(
//                           onTap: () => _navigateToChat(user),
//                           child: Container(
//                             margin: EdgeInsets.symmetric(horizontal: 8),
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 CircleAvatar(
//                                   radius: 25,
//                                   backgroundColor: Colors.amber,
//                                   foregroundImage:
//                                       user.imageUrl != null
//                                           ? NetworkImage(user.imageUrl!)
//                                           : AssetImage(
//                                                 'assets/images/avatar.png',
//                                               )
//                                               as ImageProvider,
//                                 ),
//                                 SizedBox(height: 4),
//                                 SizedBox(
//                                   width: 60,
//                                   child: Text(
//                                     capitalize(user.name),
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 12,
//                                     ),
//                                     textAlign: TextAlign.center,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),

//                   Divider(),

//                   // Chat previews list
//                   Expanded(
//                     flex: 4,
//                     child:
//                         previews.isEmpty
//                             ? Center(
//                               child: Text(
//                                 "No conversations yet",
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                             )
//                             : ListView.builder(
//                               itemCount: previews.length,
//                               itemBuilder: (context, index) {
//                                 final preview = previews[index];

//                                 return GestureDetector(
//                                   onTap: () async {
//                                     // Create UserModel from preview data
//                                     final user = UserModel(
//                                       id: preview.userId,
//                                       name: preview.name,
//                                       imageUrl: preview.image,
//                                     );
//                                     await _navigateToChat(user);
//                                   },
//                                   child: Container(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 16,
//                                       vertical: 12,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       border: Border(
//                                         bottom: BorderSide(
//                                           color: Colors.grey[300]!,
//                                           width: 0.5,
//                                         ),
//                                       ),
//                                     ),
//                                     child: Row(
//                                       children: [
//                                         // Avatar
//                                         CircleAvatar(
//                                           radius: 25,
//                                           backgroundColor: Colors.amber,
//                                           foregroundImage:
//                                               preview.image != null
//                                                   ? NetworkImage(preview.image!)
//                                                   : AssetImage(
//                                                         'assets/images/avatar.png',
//                                                       )
//                                                       as ImageProvider,
//                                         ),

//                                         SizedBox(width: 12),

//                                         // Message content
//                                         Expanded(
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 capitalize(preview.name),
//                                                 style: TextStyle(
//                                                   fontSize: 16,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                               SizedBox(height: 4),
//                                               Text(
//                                                 preview.latestMessage,
//                                                 style: TextStyle(
//                                                   color: Colors.grey[600],
//                                                   fontSize: 14,
//                                                 ),
//                                                 overflow: TextOverflow.ellipsis,
//                                                 maxLines: 1,
//                                               ),
//                                             ],
//                                           ),
//                                         ),

//                                         // Time and unread count
//                                         Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.end,
//                                           children: [
//                                             Text(
//                                               formatChatTime(preview.createdAt),
//                                               style: TextStyle(
//                                                 color: Colors.grey[500],
//                                                 fontSize: 12,
//                                               ),
//                                             ),
//                                             SizedBox(height: 4),
//                                             if (preview.unreadCount > 0)
//                                               Container(
//                                                 padding: EdgeInsets.symmetric(
//                                                   horizontal: 8,
//                                                   vertical: 4,
//                                                 ),
//                                                 decoration: BoxDecoration(
//                                                   color: Colors.green,
//                                                   borderRadius:
//                                                       BorderRadius.circular(12),
//                                                 ),
//                                                 child: Text(
//                                                   preview.unreadCount > 99
//                                                       ? '99+'
//                                                       : preview.unreadCount
//                                                           .toString(),
//                                                   style: TextStyle(
//                                                     color: Colors.white,
//                                                     fontSize: 12,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                 ),
//                                               ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                   ),

//                   // Login button (for testing)
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: ElevatedButton(
//                       onPressed: () async {
//                         try {
//                           await authService.login(
//                             "joshharyomide@gmail.com",
//                             "123456",
//                           );
//                           await _refreshPreviews();
//                         } catch (e) {
//                           print("❌ Login error: $e");
//                         }
//                       },
//                       child: Text('Login'),
//                     ),
//                   ),
//                 ],
//               ),
//     );
//   }
// }
