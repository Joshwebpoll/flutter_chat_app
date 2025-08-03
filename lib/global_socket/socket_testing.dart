import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketManager {
  static final SocketManager _instance = SocketManager._internal();
  factory SocketManager() => _instance;

  IO.Socket? socket;

  SocketManager._internal();

  void connect(String? token) {
    // ✅ Avoid reconnecting or calling methods on null
    if (socket != null && socket!.connected) return;

    socket = IO.io(
      "https://buddy-chat-backend-ii8g.onrender.com",
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect() // Better to explicitly connect after handlers
          .build(),
    );

    // ✅ Setup handlers before connect
    socket!.onConnect((_) => print("✅ Connected"));
    socket!.onDisconnect((_) => print("🔌 Disconnected"));
    socket!.onConnectError((data) => print("❌ Connect error: $data"));

    socket!.connect(); // 🚀 connect here after handlers
  }

  void onMessage(Function(dynamic data) callback) {
    socket?.on('chatMessage', callback);
  }

  void offMessage() {
    socket?.off('chatMessage');
  }

  void dispose() {
    socket?.dispose();
    socket = null; // 🔁 optional: reset socket for future use
  }

  bool get isConnected => socket?.connected ?? false;
}
