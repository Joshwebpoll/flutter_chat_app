import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player_app/providers/auth_provider.dart';

class Profile extends ConsumerWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<String>>(authProvider, (prev, next) {
      next.whenOrNull(
        data: (value) {
          if (value == "Logged out") {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushNamed(context, '/');
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

    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Center(
        child: ElevatedButton(
          onPressed:
              authState.isLoading
                  ? null
                  : () {
                    ref.read(authProvider.notifier).logOut();
                  },
          child:
              authState.isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Logout"),
        ),
      ),
    );
  }
}
