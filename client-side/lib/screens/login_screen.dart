import 'package:flutter/material.dart';
import 'see_posts_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  
  void _handleLogin() {
    String name = _nameController.text;
    String id = _idController.text;
    
    
    print('Ad/Soyad: $name, Öğrenci No: $id');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const VehiclePostsScreen()),
    );

    // TODO: Connect to backend authentication when ready
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giriş'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Ad/Soyad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _idController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Öğrenci No',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _handleLogin,
              child: const Text('Giriş'),
            ),
          ],
        ),
      ),
    );
  }
}
