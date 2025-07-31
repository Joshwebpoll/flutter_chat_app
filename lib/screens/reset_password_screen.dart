import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player_app/providers/auth_provider.dart';
import 'package:music_player_app/utils/app_toast.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<String>>(authProvider, (prev, next) {
      if (prev != next) {
        next.whenOrNull(
          data: (message) {
            if (message.isNotEmpty) {
              AppToast.show(
                context,
                message,
                type: ToastTypes.success,
                position: ToastPosition.bottom,
                duration: Duration(seconds: 5),
              );
              // CompanyToast.show(context, message, type: ToastType.success);
              Future.microtask(() {
                if (!context.mounted) return;
                ref.read(authProvider.notifier).reset();
                Navigator.pushNamed(
                  context,
                  '/password_otp',
                  arguments: {'email': emailController.text},
                );
              });
            }
          },

          error: (e, _) {
            AppToast.show(
              context,
              e.toString(),
              type: ToastTypes.error,
              position: ToastPosition.bottom,
              duration: Duration(seconds: 5),
            );
          },
        );
      }
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),
              const Text(
                'Enter your email to receive a reset link.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextFormField(
                style: TextStyle(fontSize: 14.5),
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed:
                    ref.watch(authProvider).isLoading
                        ? null
                        : () {
                          if (_formKey.currentState!.validate()) {
                            // Handle reset logic
                            ref
                                .read(authProvider.notifier)
                                .resetPassword(emailController.text);
                          }
                        },
                child:
                    ref.watch(authProvider).isLoading
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(),
                        )
                        : const Text('Send Reset Link'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
