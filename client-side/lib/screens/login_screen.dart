import 'dart:convert'; // For JSON decoding
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:webview_flutter/webview_flutter.dart'; // For navigating to the returned link in-app
import '../widgets/custom_appbar.dart';
import '../services/auth_service.dart';
import 'vehicle_posts.dart';
import '../services/local_db_service.dart';
import '../services/firebase_service.dart';
import '../utils/main_link.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  void _debugLogin(BuildContext context) async {
    AuthService().setCredentials(1, 'api12324');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const VehiclePostsScreen()),
    );

    await FirebaseApi().initNotifications();
  }

  Future<void> _handleLogin(BuildContext context) async {
    final String link = MainLink().url;
    final String apiUrl = 'http://$link:3000/login';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData.containsKey('authorizationUrl')) {
          final String redirectUrl = responseData['authorizationUrl'];
          print('Redirect URL: $redirectUrl');

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WebViewScreen(
                url: redirectUrl,
                onFinalRedirect: (authUrl) async {
                  try {
                    // Make an HTTP GET request to fetch the JSON from the final URL
                    final response = await http.get(Uri.parse(authUrl));

                    if (response.statusCode == 200) {
                      // Parse the JSON response
                      final Map<String, dynamic> responseData =
                          jsonDecode(response.body);

                      final int? userId = responseData['userId'];
                      final String? apiKey = responseData['apiKey'];

                      print(userId);
                      print(apiKey);

                      if (userId != null && apiKey != null) {
                        AuthService().setCredentials(userId, apiKey);
                        saveLoginInfo(userId.toString(), apiKey);
                        await FirebaseApi().initNotifications();

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VehiclePostsScreen(),
                          ),
                        );
                      } else {
                        // Handle case where userId or apiKey is missing
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to retrieve user info.'),
                          ),
                        );
                      }
                    } else {
                      // Handle non-200 status code
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Error: Unable to fetch user info. Status: ${response.statusCode}'),
                        ),
                      );
                    }
                  } catch (error) {
                    // Handle errors like network issues
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $error'),
                      ),
                    );
                  }
                },
              ),
            ),
          );
        } else {
          print('Field "authorizationUrl" not found in the response.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to log in. Please try again.')),
          );
        }
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
              onPressed: () => _debugLogin(context),
              child: const Text(
                'Debug Login',
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
              onPressed: () => _handleLogin(context),
              child: const Text(
                'Gtü Giriş',
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
  final void Function(String finalUrl) onFinalRedirect;

  const WebViewScreen({
    required this.url,
    required this.onFinalRedirect,
    Key? key,
  }) : super(key: key);

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
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (navigationRequest) {
            final String link = MainLink().url;
            if (navigationRequest.url.startsWith('http://$link:3000/auth')) {
              widget.onFinalRedirect(navigationRequest.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
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
