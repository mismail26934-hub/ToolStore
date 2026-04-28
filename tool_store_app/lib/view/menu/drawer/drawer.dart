import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tool_store_app/view/custom/routes/page_routes.dart';
import 'package:tool_store_app/view/custom/show_dialog/show_dialog.dart';
import 'package:tool_store_app/view/var/var.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key, required this.title});

  final String title;

  bool get _isLoggedIn => title.trim().isNotEmpty;

  String get _displayName =>
      _isLoggedIn ? title.trim().toUpperCase() : 'GUEST USER';

  Widget _buildSectionTitle(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: clrOrange.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _isLoggedIn ? Icons.verified_user_outlined : Icons.person_outline,
              color: clrOrange,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isLoggedIn ? 'Akses Aktif' : 'Mode Tamu',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  _isLoggedIn
                      ? 'Kelola request tool, user, dan dashboard dengan cepat.'
                      : 'Silakan login untuk mengakses seluruh menu aplikasi.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade700,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey.shade500),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [clrOrange, const Color.fromARGB(255, 255, 184, 76)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.handyman,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isLoggedIn ? level : 'Silakan login untuk melanjutkan',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.92),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.18)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.tips_and_updates_outlined,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Akses cepat ke dashboard, data tool, riwayat, dan pengaturan user.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    ShowDialogBox.show(
      context: context,
      title: 'Logout',
      contentTitle: 'Are you sure logout ?',
      onPressedNo: () {
        if (!context.mounted) return;
        Navigator.pop(context);
      },
      onPressedYes: () async {
        Navigator.pop(context);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        if (!context.mounted) return;
        PageRoutes.routeLoginFast(context);
      },
      textNo: 'Back',
      textYes: 'Yes',
      textColorNo: clrBlack,
      textColorYes: clrRed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF7F8FA),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(context),
          _buildInfoCard(context),
          _buildSectionTitle(context, 'Main Menu'),
          _buildMenuTile(
            context: context,
            icon: Icons.dashboard_customize_outlined,
            title: 'Dashboard',
            subtitle: 'Lihat ringkasan aktivitas dan monitoring request.',
            iconColor: Colors.deepOrange,
            onTap: () {
              PageRoutes.routeDashboard(context, '');
            },
          ),
          _buildMenuTile(
            context: context,
            icon: Icons.handyman_outlined,
            title: 'Data Tool',
            subtitle: 'Buka daftar request tool dan detail item pekerjaan.',
            iconColor: Colors.blue,
            onTap: () {
              PageRoutes.routeHome(context);
              Navigator.pop(context);
            },
          ),
          _buildMenuTile(
            context: context,
            icon: Icons.history_outlined,
            title: 'History',
            subtitle: 'Pantau data request sebelumnya dan progres terbaru.',
            iconColor: Colors.teal,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _buildMenuTile(
            context: context,
            icon: Icons.task_alt_outlined,
            title: 'Completed',
            subtitle: 'Lihat item yang sudah selesai diproses.',
            iconColor: Colors.green,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _buildSectionTitle(context, 'Account'),
          _buildMenuTile(
            context: context,
            icon: Icons.person_outline,
            title: 'User',
            subtitle: 'Kelola data user dan informasi akun.',
            iconColor: Colors.purple,
            onTap: () {
              PageRoutes.routeUser(context);
              Navigator.pop(context);
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  if (_isLoggedIn) {
                    _handleLogout(context);
                    return;
                  }
                  PageRoutes.routeLoginFast(context);
                },
                child: Ink(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isLoggedIn
                        ? clrRed.withOpacity(0.08)
                        : Colors.blue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isLoggedIn
                          ? clrRed.withOpacity(0.16)
                          : Colors.blue.withOpacity(0.16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _isLoggedIn
                              ? clrRed.withOpacity(0.14)
                              : Colors.blue.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          _isLoggedIn
                              ? Icons.logout_outlined
                              : Icons.login_outlined,
                          color: _isLoggedIn ? clrRed : Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isLoggedIn ? 'Logout' : 'Login',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isLoggedIn
                                  ? 'Keluar dari sesi dan hapus data login lokal.'
                                  : 'Masuk untuk membuka seluruh fitur aplikasi.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Colors.grey.shade700,
                                    height: 1.35,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
