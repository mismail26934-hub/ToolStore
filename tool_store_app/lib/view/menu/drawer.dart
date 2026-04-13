import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tool_store_app/view/custom/routes/page_routes.dart';
import 'package:tool_store_app/view/var/var.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header Drawer
          UserAccountsDrawerHeader(
            accountName: Text(title),
            accountEmail: Text(""),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.orange),
            ),
            decoration: BoxDecoration(color: Colors.orange),
          ),
          // Menggunakan _buildMenuItem
          _buildMenuItem(
            icon: Icons.home,
            title: 'Home',
            onTap: () => {
              PageRoutes.routeHome(context),
              Navigator.pop(context),
            },
          ),

          _buildMenuItem(
            icon: Icons.settings,
            title: 'Pengaturan',
            onTap: () {
              Navigator.pop(context);
              // Navigasi ke halaman pengaturan di sini
            },
          ),

          const Divider(), // Garis pemisah

          _buildMenuItem(
            icon: Icons.logout,
            title: title.isNotEmpty ? 'Logout' : 'Login',
            onTap: title.isNotEmpty
                ? () {
                    Navigator.pop(context); // Tutup drawer
                    _showLogoutDialog(context); // Panggil dialog logout
                  }
                : () {
                    PageRoutes.routeLogin(context);
                  },
          ),
        ],
      ),
    );
  }

  // --- HELPER METHODS ---

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: clrBlack),
      title: Text(title),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are You Sure Logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back'),
          ),
          TextButton(
            onPressed: () async {
              // Logika logout Anda di sini
              Navigator.pop(context);
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.clear();
              if (!context.mounted) return;
              PageRoutes.routeLogin(context);
            },
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
