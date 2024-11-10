import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menü',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          _buildMenuItem(
            context: context,
            title: 'Paylaşımları Gör',
            icon: Icons.list,
            routeName: '/posts',
          ),
          _buildMenuItem(
            context: context,
            title: 'İstekleri Gör',
            icon: Icons.list,
            routeName: '/requests',
          ),
          _buildMenuItem(
            context: context,
            title: 'Paylaşım Oluştur',
            icon: Icons.add,
            routeName: '/create_post',
          ),
          _buildMenuItem(
            context: context,
            title: 'Paylaşımlarım',
            icon: Icons.person,
            routeName: '/your_posts',
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String routeName,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, routeName); 
      },
    );
  }
}
