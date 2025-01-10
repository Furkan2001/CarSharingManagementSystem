import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class User {
  final String firstName;
  final String lastName;
  final int sustainabilityPoints;

  User({
    required this.firstName,
    required this.lastName,
    required this.sustainabilityPoints,
  });

  // Factory constructor to create a User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['name'] ?? 'Name',
      lastName: json['surname'] ?? 'Last Name',
      sustainabilityPoints: json['sustainabilityPoint'] ?? 0,
    );
  }
}

class Menu extends StatefulWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  // State variables to hold user data
  User? _user;
  bool _isLoading = true;
  String? _errorMessage;

  final String _userId = "1"; // Example user ID
  final String _apiKey = "api12324"; // Example API key

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final String apiUrl =
        'http://10.0.2.2:3000/api/Users/get-user/$_userId'; // Adjusted for Android emulator

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'x-api-key': _apiKey,
          'user_id': _userId,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Directly parse the user data without expecting a 'user' field
        setState(() {
          _user = User.fromJson(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to fetch user data. Status code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred while fetching user data.';
        _isLoading = false;
      });
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color.fromARGB(255, 6, 30, 69),
        child: Column(
          children: <Widget>[
            // User Information Section
            _buildUserInfo(),
            const Divider(color: Colors.white54),
            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  _buildMenuItem(
                    context: context,
                    title: 'Paylaşımları Gör',
                    icon: Icons.list,
                    routeName: '/posts',
                    iconColor: const Color.fromARGB(255, 153, 153, 153),
                    textColor: Colors.white,
                  ),
                  _buildMenuItem(
                    context: context,
                    title: 'İstekleri Gör',
                    icon: Icons.list,
                    routeName: '/requests',
                    iconColor: const Color.fromARGB(255, 153, 153, 153),
                    textColor: Colors.white,
                  ),
                  _buildMenuItem(
                    context: context,
                    title: 'Paylaşım Oluştur',
                    icon: Icons.add,
                    routeName: '/create_post',
                    iconColor: const Color.fromARGB(255, 153, 153, 153),
                    textColor: Colors.white,
                  ),
                  _buildMenuItem(
                    context: context,
                    title: 'Paylaşımlarım',
                    icon: Icons.person,
                    routeName: '/your_posts',
                    iconColor: const Color.fromARGB(255, 153, 153, 153),
                    textColor: Colors.white,
                  ),
                  _buildMenuItem(
                    context: context,
                    title: 'Mesajlaşmalar',
                    icon: Icons.message,
                    routeName: '/messages',
                    iconColor: const Color.fromARGB(255, 153, 153, 153),
                    textColor: Colors.white,
                  ),
                  _buildMenuItem(
                    context: context,
                    title: 'İsteklerim',
                    icon: Icons.output,
                    routeName: '/my_requests',
                    iconColor: const Color.fromARGB(255, 153, 153, 153),
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to build the user information section at the top of the Drawer
  Widget _buildUserInfo() {
    if (_isLoading) {
      return const DrawerHeader(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 6, 30, 69),
        ),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    } else if (_errorMessage != null) {
      return DrawerHeader(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 6, 30, 69),
        ),
        child: Center(
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else if (_user != null) {
      return UserAccountsDrawerHeader(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 6, 30, 69),
        ),
        accountName: Text(
          '${_user!.firstName} ${_user!.lastName}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        accountEmail: Text(
          'Sürdürülebilirlik Puanı: ${_user!.sustainabilityPoints}',
          style: const TextStyle(fontSize: 16),
        ),
        currentAccountPicture: CircleAvatar(
          backgroundColor: Colors.white,
          child: Text(
            _user!.firstName.isNotEmpty ? _user!.firstName[0] : 'U',
            style: const TextStyle(fontSize: 24, color: Colors.blue),
          ),
        ),
      );
    } else {
      return const DrawerHeader(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 6, 30, 69),
        ),
        child: Center(
          child: Text(
            'Kullanıcı Bilgisi Yok',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }
  }

  // Widget to build individual menu items
  Widget _buildMenuItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String routeName,
    required Color iconColor,
    required Color textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      onTap: () {
        Navigator.pop(context); // Close the drawer
        Navigator.pushNamed(
            context, routeName); // Navigate to the selected route
      },
    );
  }
}
