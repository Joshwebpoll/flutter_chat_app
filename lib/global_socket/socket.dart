// import 'package:socket_io_client/socket_io_client.dart' as IO;

// class SocketService {
//   static final SocketService _instance = SocketService._internal();

//   factory SocketService() => _instance;

//   late IO.Socket socket;

//   SocketService._internal(); // Private constructor

//   void connect(String token) {
//     socket = IO.io(
//       "http://192.168.52.59:3000",
//       IO.OptionBuilder()
//           .setTransports(['websocket'])
//           .enableReconnection()
//           .setReconnectionAttempts(5)
//           .setReconnectionDelay(1000)
//           .enableAutoConnect()
//           .setAuth({"token": token})
//           .build(),
//     );

//     socket.connect();

//     socket.onConnect((_) {
//       print('✅ Connected to socket server');
//     });

//     socket.onDisconnect((_) {
//       print('❌ Disconnected from socket');
//     });
//   }

//   void sendMessage(String event, dynamic data) {
//     socket.emit(event, data);
//   }

//   void listen(String event, Function(dynamic) callback) {
//     socket.on(event, callback);
//   }

//   void removeListener(String event) {
//     socket.off(event);
//   }

//   void disconnect() {
//     socket.disconnect();
//   }

//   IO.Socket getSocket() => socket;
// }
// LateError (LateInitializationError: Field 'socket' has not been initialized.)

import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();

  factory SocketService() => _instance;

  IO.Socket? _socket;

  SocketService._internal(); // Private constructor

  void connect(String token) {
    // _socket = IO.io(
    //   "https://buddy-chat-backend-ii8g.onrender.com",
    //   IO.OptionBuilder()
    //       .setTransports(['websocket'])
    //       .enableReconnection()
    //       .setReconnectionAttempts(5)
    //       .setReconnectionDelay(1000)
    //       .enableAutoConnect()
    //       .setAuth({"token": token})
    //       .build(),
    // );
    _socket = IO.io(
      "https://buddy-chat-backend-ii8g.onrender.com",
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'auth': {'token': token},
        'extraHeaders': {'Authorization': 'Bearer $token'},
      },
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('✅ Connected to socket server');
    });

    _socket!.onDisconnect((_) {
      print('❌ Disconnected from socket');
    });
  }

  void sendMessage(String event, dynamic data) {
    if (_socket?.connected ?? false) {
      _socket!.emit(event, data);
    } else {
      print('⚠️ Cannot send message: Socket not connected');
    }
  }

  void listen(String event, Function(dynamic) callback) {
    // _socket?.off(event);
    _socket?.on(event, callback);
  }

  void removeListener(String event) {
    _socket?.off(event);
  }

  void disconnect() {
    _socket?.disconnect();
  }

  IO.Socket? getSocket() => _socket;
}
