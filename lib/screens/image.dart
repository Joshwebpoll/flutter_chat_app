// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:path/path.dart';
// import 'package:music_player_app/utils/app_toast.dart';

// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});

//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final nameController = TextEditingController();
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final confirmpasswordController = TextEditingController();
//   final usernameController = TextEditingController();
//   final phoneController = TextEditingController();
//   bool _obscurePassword = true;
//   bool _obscureConfirm = true;
//   File? _selectedImage;
//   bool _isLoading = false;

//   @override
//   void dispose() {
//     nameController.dispose();
//     emailController.dispose();
//     passwordController.dispose();
//     confirmpasswordController.dispose();
//     usernameController.dispose();
//     phoneController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickImage() async {
//     final pickedFile = await ImagePicker().pickImage(
//       source: ImageSource.gallery,
//     );
//     if (pickedFile != null) {
//       setState(() => _selectedImage = File(pickedFile.path));
//     }
//   }

//   Future<void> _submitSignup() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() => _isLoading = true);

//       try {
//         final uri = Uri.parse(
//           'https://your-api.com/api/signup',
//         ); // ✅ Change this to your actual API endpoint
//         var request = http.MultipartRequest('POST', uri);

//         request.fields['name'] = nameController.text;
//         request.fields['email'] = emailController.text;
//         request.fields['username'] = usernameController.text;
//         request.fields['phone'] = phoneController.text;
//         request.fields['password'] = passwordController.text;
//         request.fields['password_confirmation'] =
//             confirmpasswordController.text;

//         if (_selectedImage != null) {
//           var stream = http.ByteStream(_selectedImage!.openRead());
//           var length = await _selectedImage!.length();
//           var multipartFile = http.MultipartFile(
//             'image', // must match the Laravel controller field name
//             stream,
//             length,
//             filename: basename(_selectedImage!.path),
//           );
//           request.files.add(multipartFile);
//         }

//         final response = await request.send();

//         final resBody = await response.stream.bytesToString();

//         if (response.statusCode == 200) {
//           AppToast.show(
//             context,
//             'Signup successful!',
//             type: ToastTypes.success,
//           );
//           Navigator.pushReplacementNamed(
//             context,
//             '/verify',
//             arguments: {'email': emailController.text},
//           );
//         } else {
//           AppToast.show(
//             context,
//             'Signup failed: $resBody',
//             type: ToastTypes.error,
//           );
//         }
//       } catch (e) {
//         AppToast.show(context, 'Error: $e', type: ToastTypes.error);
//       } finally {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Sign Up')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               const SizedBox(height: 20),
//               Center(
//                 child: GestureDetector(
//                   onTap: _pickImage,
//                   child: CircleAvatar(
//                     radius: 40,
//                     backgroundImage:
//                         _selectedImage != null
//                             ? FileImage(_selectedImage!)
//                             : null,
//                     child:
//                         _selectedImage == null
//                             ? const Icon(Icons.camera_alt, size: 30)
//                             : null,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               const Center(child: Text('Tap to select profile image')),

//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: nameController,
//                 decoration: const InputDecoration(labelText: 'Full Name'),
//                 validator:
//                     (value) =>
//                         value == null || value.trim().isEmpty
//                             ? 'Name is required'
//                             : null,
//               ),
//               const SizedBox(height: 15),
//               TextFormField(
//                 controller: emailController,
//                 decoration: const InputDecoration(labelText: 'Email'),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Email is required';
//                   }
//                   if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
//                     return 'Enter a valid email';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 15),
//               TextFormField(
//                 controller: usernameController,
//                 decoration: const InputDecoration(labelText: 'Username'),
//                 validator:
//                     (value) =>
//                         value == null || value.trim().isEmpty
//                             ? 'Username is required'
//                             : null,
//               ),
//               const SizedBox(height: 15),
//               TextFormField(
//                 controller: phoneController,
//                 decoration: const InputDecoration(labelText: 'Phone Number'),
//                 validator:
//                     (value) =>
//                         value == null || value.trim().isEmpty
//                             ? 'Phone number is required'
//                             : null,
//               ),
//               const SizedBox(height: 15),
//               TextFormField(
//                 controller: passwordController,
//                 obscureText: _obscurePassword,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _obscurePassword
//                           ? Icons.visibility_off
//                           : Icons.visibility,
//                     ),
//                     onPressed:
//                         () => setState(
//                           () => _obscurePassword = !_obscurePassword,
//                         ),
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty)
//                     return 'Password is required';
//                   if (value.length < 6)
//                     return 'Password must be at least 6 characters';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 15),
//               TextFormField(
//                 controller: confirmpasswordController,
//                 obscureText: _obscureConfirm,
//                 decoration: InputDecoration(
//                   labelText: 'Confirm Password',
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _obscureConfirm ? Icons.visibility_off : Icons.visibility,
//                     ),
//                     onPressed:
//                         () =>
//                             setState(() => _obscureConfirm = !_obscureConfirm),
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty)
//                     return 'Confirm your password';
//                   if (value != passwordController.text)
//                     return 'Passwords do not match';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _isLoading ? null : _submitSignup,
//                 child:
//                     _isLoading
//                         ? const SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                         : const Text('Sign Up'),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.pushNamed(context, '/'),
//                 child: const Text("Already have an account? Login"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
