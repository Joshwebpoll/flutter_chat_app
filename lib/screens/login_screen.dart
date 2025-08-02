import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player_app/providers/auth_provider.dart';
import 'package:music_player_app/utils/app_toast.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final checktoken = AuthService().getToken();
    // print(checktoken);
    final loginState = ref.watch(authProvider);

    ref.listen<AsyncValue<String>>(authProvider, (prev, next) {
      next.whenOrNull(
        data: (message) {
          if (message == 'Login Successful' && prev?.value != message) {
            if (!context.mounted) return;
            // AppToast.show(
            //   context,
            //   message.isNotEmpty ? "Login Successful" : "",
            //   type: ToastTypes.success,
            //   position: ToastPosition.bottom,
            //   duration: Duration(seconds: 5),
            // );
            // CompanyToast.show(context, message, type: ToastType.success);

            Future.microtask(() {
              if (!context.mounted) return;
              ref.read(authProvider.notifier).reset();
              Navigator.pushNamed(context, '/home');
            });
          }
        },

        error: (e, _) {
          if (!context.mounted) return;
          AppToast.show(
            context,
            e.toString(),
            type: ToastTypes.error,
            position: ToastPosition.bottom,
            duration: Duration(seconds: 5),
          );
        },
      );
    });
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 40),
            Image.asset(
              'assets/images/chats.png',
              gaplessPlayback: true,
              height: 200,
            ),

            // const Text(
            //   'Login',
            //   style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            //   textAlign: TextAlign.center,
            // ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    style: TextStyle(fontSize: 15),
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: const OutlineInputBorder(),
                    ),
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
                  const SizedBox(height: 15),
                  TextFormField(
                    style: TextStyle(fontSize: 15),
                    controller: passwordController,

                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',

                      suffixIcon: IconButton(
                        icon: Icon(
                          size: 20,
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/reset'),
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          loginState.isLoading
                              ? null
                              : () async {
                                if (_formKey.currentState!.validate()) {
                                  await ref
                                      .read(authProvider.notifier)
                                      .login(
                                        emailController.text,
                                        passwordController.text,
                                      );
                                }
                              },
                      child:
                          loginState.isLoading
                              ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(),
                              )
                              : const Text('Login'),
                    ),
                  ),

                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/signup'),
                    child: const Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
