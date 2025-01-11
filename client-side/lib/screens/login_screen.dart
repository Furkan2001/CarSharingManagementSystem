import 'dart:convert'; // For JSON decoding
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:webview_flutter/webview_flutter.dart'; // For navigating to the returned link in-app
import '../widgets/custom_appbar.dart';
import 'vehicle_posts.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  void _handleLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const VehiclePostsScreen()),
    );

    // TODO: Connect to backend authentication when ready
  }

  Future<void> _loginViaApi(BuildContext context) async {
    const String apiUrl = 'http://10.0.2.2:3000/login';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final String redirectUrl = response.body;
        print('Redirect URL: $redirectUrl');

        // Navigate to the returned link using WebView
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewScreen(url: redirectUrl),
          ),
        );
      } else {
        print(
            'Failed to get redirect URL. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to log in. Please try again.')),
        );
      }
    } catch (error) {
      print('Error during login: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Giriş'),
      backgroundColor: const Color.fromARGB(
          255, 54, 69, 74), // Set background color for the entire page
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
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
            const SizedBox(height: 20), // Add some spacing between buttons
            ElevatedButton(
              onPressed: () => _loginViaApi(context),
              child: const Text(
                'Login via API',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50), // Button size
                textStyle: const TextStyle(fontSize: 15),
                backgroundColor: const Color.fromARGB(255, 6, 30, 69),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WebViewScreen extends StatefulWidget {
  final String url;

  const WebViewScreen({required this.url, Key? key}) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
