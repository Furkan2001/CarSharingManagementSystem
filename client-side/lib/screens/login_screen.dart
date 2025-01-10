import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';
import 'vehicle_posts.dart'; // Import the next screen where user will be navigated

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  void _handleLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const VehiclePostsScreen()),
    );

    // TODO: Connect to backend authentication when ready
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Giriş'),
      backgroundColor: const Color.fromARGB(
          255, 54, 69, 74), // Set background color for the entire page
      body: Center(
        child: ElevatedButton(
          onPressed: () => _handleLogin(context),
          child: const Text(
            'Gtü ile Giriş',
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(200, 50), // Button size
            textStyle: const TextStyle(fontSize: 15),
            backgroundColor: const Color.fromARGB(255, 6, 30, 69),
          ),
        ),
      ),
    );
  }
}
