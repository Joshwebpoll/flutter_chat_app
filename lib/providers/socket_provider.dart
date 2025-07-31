import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player_app/global_socket/socket.dart';

final socketProvider = Provider((ref) => SocketService());
