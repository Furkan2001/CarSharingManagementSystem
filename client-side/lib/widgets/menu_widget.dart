import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
      color: const Color.fromARGB(255, 6, 30, 69),
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
          ],
        ),
      ),
    );
  }

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
        style: TextStyle(color: textColor),),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, routeName); 
      },
    );
  }
}
