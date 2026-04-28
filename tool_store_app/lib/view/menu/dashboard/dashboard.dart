import 'package:flutter/material.dart';
import 'package:tool_store_app/view/custom/routes/page_routes.dart';
import 'package:tool_store_app/view/menu/drawer/drawer.dart';
import 'package:tool_store_app/view/var/var.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF7F8FA),
      drawer: DrawerMenu(title: name),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _DashboardHeader(
              onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const crossAxisSpacing = 12.0;
                    const mainAxisSpacing = 12.0;
                    final cardWidth =
                        (constraints.maxWidth - crossAxisSpacing) / 2;
                    final cardHeight =
                        (constraints.maxHeight - (mainAxisSpacing * 2)) / 3;
                    final childAspectRatio = cardWidth / cardHeight;

                    return GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: crossAxisSpacing,
                      mainAxisSpacing: mainAxisSpacing,
                      childAspectRatio: childAspectRatio,
                      children: [
                        _DashboardCard(
                          title: 'Draft',
                          subtitle: 'Request baru yang masih perlu dicek.',
                          icon: Icons.drafts_outlined,
                          value: '1',
                          iconColor: Colors.deepOrange,
                          onTap: () {
                            PageRoutes.routeLazyListExample(context, '');
                          },
                        ),
                        _DashboardCard(
                          title: 'Superior Approval',
                          subtitle: 'Menunggu persetujuan atasan terkait.',
                          icon: Icons.fact_check_outlined,
                          value: '5',
                          iconColor: Colors.blue,
                          onTap: () {},
                        ),
                        _DashboardCard(
                          title: 'Service Admin',
                          subtitle: 'Masuk ke proses validasi admin service.',
                          icon: Icons.playlist_add_check_circle_outlined,
                          value: '2',
                          iconColor: Colors.purple,
                          onTap: () {},
                        ),
                        _DashboardCard(
                          title: 'Dept. Head Approval',
                          subtitle: 'Perlu persetujuan dari kepala departemen.',
                          icon: Icons.approval_outlined,
                          value: '3',
                          iconColor: Colors.teal,
                          onTap: () {},
                        ),
                        _DashboardCard(
                          title: 'Counter / GA Processing',
                          subtitle: 'Sedang diproses oleh Counter atau GA.',
                          icon: Icons.inventory_2_outlined,
                          value: '4',
                          iconColor: Colors.amber.shade800,
                          onTap: () {},
                        ),
                        _DashboardCard(
                          title: 'Completed',
                          subtitle: 'Request selesai dan siap ditinjau.',
                          icon: Icons.task_alt_outlined,
                          value: '6',
                          iconColor: Colors.green,
                          onTap: () {},
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.onMenuTap});

  static const _headerRadius = 28.0;
  static const _buttonRadius = 16.0;
  static const _logoRadius = 20.0;
  static const _notificationCount = '6';

  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [clrOrange, const Color.fromARGB(255, 255, 184, 76)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(_headerRadius),
          bottomRight: Radius.circular(_headerRadius),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildMenuButton(),
              const Spacer(),
              _buildNotificationBadge(context),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildLogo(),
              const SizedBox(width: 10),
              Expanded(
                flex: 5,
                child: Hero(
                  tag: 'text-app',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      'Dashboard Tool Monitoring',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton() {
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(_buttonRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(_buttonRadius),
        onTap: onMenuTap,
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Icon(Icons.menu, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildNotificationBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(_buttonRadius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_none_rounded,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            _notificationCount,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Hero(
      tag: 'logo-app',
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(_logoRadius),
        ),
        child: const Icon(Icons.handyman, color: Colors.white, size: 24),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.iconColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String value;
  final Color iconColor;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: iconColor, size: 22),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade700,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
