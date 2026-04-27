import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tool_store_app/view/custom/navbar/sliver_menu_item.dart';
import 'package:tool_store_app/view/custom/routes/page_routes.dart';
import 'package:tool_store_app/view/custom/show_dialog/show_dialog.dart';
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
            accountName: Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            accountEmail: Text(
              level,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.orange),
            ),
            decoration: BoxDecoration(color: Colors.orange),
          ),
          // Menggunakan _buildMenuItem
          MenuItem(
            iconMenu: Icons.dashboard,
            title: 'Dashboard',
            onTap: () => {PageRoutes.routeDashboard(context, '')},
            textColor: clrBlack,
          ),
          MenuItem(
            iconMenu: Icons.file_present,
            title: 'Tool Data',
            onTap: () => {
              PageRoutes.routeHome(context),
              Navigator.pop(context),
            },
            textColor: clrBlack,
          ),
          MenuItem(
            iconMenu: Icons.file_copy,
            title: 'History',
            onTap: () => {},
            textColor: clrBlack,
          ),

          MenuItem(
            iconMenu: Icons.book,
            title: 'Completed',
            onTap: () => {},
            textColor: clrBlack,
          ),
          MenuItem(
            iconMenu: Icons.person,
            title: 'User',
            onTap: () => {
              PageRoutes.routeUser(context),
              Navigator.pop(context),
            },
            textColor: clrBlack,
          ),

          const Divider(), // Garis pemisah
          MenuItem(
            iconMenu: Icons.logout_outlined,
            title: title.isNotEmpty ? 'Logout' : 'Login',
            onTap: () {
              // Tutup drawer
              ShowDialogBox.show(
                context: context,
                title: 'Logout',
                contentTitle: 'Are you sure logout ?',
                onPressedNo: () {
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
                onPressedYes: () async {
                  // Tutup dialog dulu
                  Navigator.pop(context);
                  // Hapus data session
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.clear();
                  // Cek mounted sebelum navigasi (best practice)
                  if (!context.mounted) return;
                  // Navigasi ke halaman login
                  // Ganti PageRoutes dengan route yang kamu gunakan
                  if (!context.mounted) return;
                  PageRoutes.routeLoginFast(context);
                },
                textNo: 'Back',
                textYes: 'Yes',
                textColorNo: clrBlack,
                textColorYes: clrRed,
              );
            },
            textColor: clrBlack,
          ),
        ],
      ),
    );
  }
}
