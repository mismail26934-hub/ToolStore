import 'package:flutter/material.dart';
import 'package:tool_store_app/view/custom/routes/page_routes.dart';
import 'package:tool_store_app/view/var/var.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    final cards = [
      {
        'title': 'Draft',
        'icon': Icons.drafts,
        'onTap': () {
          PageRoutes.routeLazyListExample(context, '');
        },
      },
      {'title': 'Superior Approval', 'icon': Icons.checklist, 'onTap': () {}},
      {
        'title': 'Service Admin',
        'icon': Icons.playlist_add_check_circle_outlined,
        'onTap': () {},
      },
      {
        'title': 'Dept. Head Approval',
        'icon': Icons.check_box_rounded,
        'onTap': () {},
      },
      {
        'title': 'Counter / GA Processing',
        'icon': Icons.list_alt_sharp,
        'onTap': () {},
      },
      {'title': 'Completed', 'icon': Icons.equalizer_rounded, 'onTap': () {}},
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 251, 174, 21),
              Color.fromARGB(255, 249, 191, 0),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Dashboard Tool Monitoring',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tool Store Dashboard',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: GridView.builder(
                      itemCount: cards.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.95,
                          ),
                      itemBuilder: (context, index) {
                        final item = cards[index];
                        return _DashboardCard(
                          title: item['title'] as String,
                          icon: item['icon'] as IconData,
                          onTap: item['onTap'] as void Function()?,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.28),
            width: 1.1,
          ),
        ),
        child: Card(
          color: clrOrange,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Icon(icon, color: Colors.white, size: 37)),
                const SizedBox(height: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
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
