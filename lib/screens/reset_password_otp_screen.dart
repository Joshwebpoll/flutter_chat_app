import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player_app/providers/auth_provider.dart';
import 'package:music_player_app/utils/app_toast.dart';

import 'package:pin_code_fields/pin_code_fields.dart';

class ResetPasswordOtpScreen extends ConsumerStatefulWidget {
  final String email;

  const ResetPasswordOtpScreen({super.key, required this.email});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ResetPasswordOtpScreenState();
}

class _ResetPasswordOtpScreenState
    extends ConsumerState<ResetPasswordOtpScreen> {
  // final TextEditingController _otpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _otp = '';
  void _verifyOtp() {
    if (_formKey.currentState!.validate()) {
      // ✅ OTP is valid - send to backend
      // final otp = _otpController.text;
      ref.read(authProvider.notifier).verifyResetPassword(_otp);
    }
  }

  @override
  void dispose() {
    // _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
              Future.microtask(() {
                if (!context.mounted) return;
                ref.read(authProvider.notifier).reset();
                Navigator.popAndPushNamed(
                  context,
                  '/change_password',
                  arguments: {'resetCode': _otp},
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
      appBar: AppBar(title: const Text("Verify Otp")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.email_outlined, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              Text(
                'We sent a 6-digit code to:',
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                widget.email,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              Form(
                key: _formKey,
                child: PinCodeTextField(
                  appContext: context,
                  length: 6,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.fade,
                  validator: (value) {
                    if (value == null || value.length != 6) {
                      return 'Please enter the 6-digit OTP';
                    }
                    return null;
                  },
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(8),
                    fieldHeight: 50,
                    fieldWidth: 40,
                    inactiveColor: Colors.grey.shade400,
                    activeColor: Colors.blue,
                    selectedColor: Colors.blueAccent,
                  ),
                  onChanged: (value) {
                    _otp = value;
                  },
                ),
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed:
                    ref.watch(authProvider).isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    ref.watch(authProvider).isLoading
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(),
                        )
                        : const Text("Verify"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
