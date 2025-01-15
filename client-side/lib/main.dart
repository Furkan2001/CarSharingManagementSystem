import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/vehicle_posts.dart';
import 'screens/vehicle_requests.dart';
import 'screens/create_post_screen.dart';
import 'screens/your_posts_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/my_requests.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/firebase_service.dart';
import 'services/local_db_service.dart';
import 'services/auth_service.dart';
import 'package:intl/intl.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final isLoggedIn = await isUserLoggedIn();
  if (isLoggedIn) {
    final userIdString = await getUserId();
    final apiKey = await getApiKey();

    if (userIdString != null && apiKey != null) {
      final userId = int.tryParse(userIdString);
      if (userId != null) {
        AuthService().setCredentials(userId, apiKey);
      }
    }
  }

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  MyApp({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vehicle Sharing App',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Colors.indigoAccent.shade700),
        useMaterial3: true,
      ),
      navigatorKey: navigatorKey,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/posts': (context) => const VehiclePostsScreen(),
        '/requests': (context) => const VehicleRequestsScreen(),
        '/create_post': (context) => const CreatePostScreen(),
        '/your_posts': (context) => const YourPostsScreen(),
        '/messages': (context) => MessagesScreen(),
        '/my_requests': (context) => const MyRequestsScreen(),
      },
      home: isLoggedIn ? const VehiclePostsScreen() : const LoginScreen(),
    );
  }
}
