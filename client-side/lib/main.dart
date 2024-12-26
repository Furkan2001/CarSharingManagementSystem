import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/vehicle_posts.dart';
import 'screens/vehicle_requests.dart';
import 'screens/create_post_screen.dart';
import 'screens/your_posts_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/my_requests.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vehicle Sharing App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigoAccent.shade700),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/posts': (context) => const VehiclePostsScreen(),
        '/requests': (context) => const VehicleRequestsScreen(),
        '/create_post': (context) => const CreatePostScreen(),
        '/your_posts': (context) => const YourPostsScreen(),
        '/messages': (context) => MessagesScreen(),
        '/my_requests': (context) => const MyRequestsScreen(userId: 2,),
      }
    );
  }
}
