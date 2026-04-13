import 'package:flutter/material.dart';
import 'package:tool_store_app/view/custom/mixin/mixin_pref.dart';
import 'package:tool_store_app/view/custom/routes/page_routes.dart';
import 'package:tool_store_app/view/var/var.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with MixinPref {
  @override
  void initState() {
    super.initState();
    _handleSplash();
  }

  Future<void> _handleSplash() async {
    // 1. Ambil data dari SharedPreferences via Mixin
    await refreshPref();

    // 2. Durasi splash screen (2-3 detik)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // 3. Logika Navigasi: Jika idUsersApp kosong/null lari ke Login, jika ada lari ke Home
    if (idUsersApp == "" || idUsersApp == "null" || idUsersApp.isEmpty) {
      PageRoutes.routeLogin(context);
    } else {
      PageRoutes.routeHome(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan warna background yang sama dengan login atau putih bersih
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon yang sama dengan halaman Login
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: clrOrange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Hero(
                    tag: 'logo-app',
                    child: Icon(
                      Icons.lock_person_rounded,
                      size: 100,
                      color: clrOrange,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Judul yang sama dengan style Login
                Hero(
                  tag: 'text-app',
                  child: Material(
                    color: Colors.transparent,
                    child: const Text(
                      "Data Tool Monitoring",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Monitoring System",
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          // Indikator loading di bagian bawah agar elegan
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(clrOrange),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  "Checking Session...",
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
