// providers/me_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player_app/services/auth_service.dart';
import '../models/single_model.dart';

final authServiceProvider = Provider<Services>((ref) => Services());

final meProvider = FutureProvider<SingleModel>((ref) {
  final service = ref.read(authServiceProvider);
  return service.getMe();
});
