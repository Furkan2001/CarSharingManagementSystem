import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/see_posts_screen.dart';
import 'screens/create_post_screen.dart';
import 'screens/your_posts_screen.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/posts': (context) => const VehiclePostsScreen(), 
        '/create_post': (context) => const CreatePostScreen(),
        '/your_posts': (context) => const YourPostsScreen(),
      }
    );
  }
}
