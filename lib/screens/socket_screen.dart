// socket_service.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  void connect() {
    socket = IO.io(
      "http://localhost:3000",
      IO.OptionBuilder()
          .setTransports(['websocket']) // for Flutter or Dart VM
          .enableAutoConnect()
          .build(),
    );

    // Listen to events
    socket.onConnect((_) {
      print('Connected to socket server');
    });

    socket.onDisconnect((_) {
      print('Disconnected');
    });

    socket.on('message', (data) {
      print('Received: $data');
    });
  }

  void sendMessage(String message) {
    socket.emit('message', message);
  }

  void disconnect() {
    socket.disconnect();
  }
}
