import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tool_store_app/model/post_get_data.dart';
import 'package:tool_store_app/view/menu/tooll/tool_data.dart';
import 'package:tool_store_app/view/var/var.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _obscurePassword = true;

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: clrOrange),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: clrOrange, width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: clrWhite,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [clrOrange.withValues(alpha: 0.08), Colors.white, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Hero(
                        tag: 'logo-app',
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: clrOrange.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            Icons.handyman,
                            size: 72,
                            color: clrOrange,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Hero(
                        tag: 'text-app',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            "Data Tool Monitoring",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                  decoration: TextDecoration.none,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Hero(
                        tag: 'subtitle',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            "Masuk untuk melanjutkan ke dashboard",
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Hero(
                        tag: 'login-card',
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: clrOrange.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.lock_open_outlined,
                                        size: 18,
                                        color: clrOrange,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Login Akun',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                TextFormField(
                                  controller: username,
                                  textInputAction: TextInputAction.next,
                                  decoration: _inputDecoration(
                                    label: 'Username',
                                    icon: Icons.person_outline,
                                  ),
                                  validator: (value) =>
                                      value == null || value.trim().isEmpty
                                      ? 'Required !'
                                      : null,
                                ),
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: password,
                                  obscureText: _obscurePassword,
                                  decoration: _inputDecoration(
                                    label: 'Password',
                                    icon: Icons.lock_outline,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                      ),
                                      onPressed: () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                    ),
                                  ),
                                  validator: (value) =>
                                      value == null || value.trim().isEmpty
                                      ? 'Required !'
                                      : null,
                                ),
                                const SizedBox(height: 22),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton.icon(
                                    onPressed: loadingLogin
                                        ? null
                                        : () async {
                                            if (formKey.currentState!
                                                .validate()) {
                                              final navigator = Navigator.of(
                                                context,
                                              );
                                              final scaffoldMessenger =
                                                  ScaffoldMessenger.of(context);
                                              setState(() {
                                                loadingLogin = true;
                                              });
                                              try {
                                                final response = await login(
                                                  username.text,
                                                  password.text,
                                                );

                                                final String statusLogin =
                                                    (response['value'] ?? "0")
                                                        .toString();
                                                final String message =
                                                    response['message'] ??
                                                    "Error";
                                                if (statusLogin == '1') {
                                                  final userData =
                                                      response['user'] ??
                                                      response;
                                                  final SharedPreferences
                                                  prefs =
                                                      await SharedPreferences.getInstance();

                                                  await prefs.setString(
                                                    'value',
                                                    statusLogin,
                                                  );
                                                  await prefs.setString(
                                                    'idUsersApp',
                                                    userData['id_users']
                                                            ?.toString() ??
                                                        "",
                                                  );
                                                  await prefs.setString(
                                                    'name',
                                                    userData['nama_user']
                                                            ?.toString() ??
                                                        "",
                                                  );
                                                  await prefs.setString(
                                                    'username',
                                                    userData['username']
                                                            ?.toString() ??
                                                        "",
                                                  );
                                                  await prefs.setString(
                                                    'password',
                                                    userData['password']
                                                            ?.toString() ??
                                                        "",
                                                  );
                                                  await prefs.setString(
                                                    'level',
                                                    userData['level']
                                                            ?.toString() ??
                                                        "",
                                                  );
                                                  await prefs.setString(
                                                    'token',
                                                    userData['token']
                                                            ?.toString() ??
                                                        "",
                                                  );
                                                  await prefs.setString(
                                                    'status',
                                                    userData['status']
                                                            ?.toString() ??
                                                        "",
                                                  );
                                                  await prefs.setString(
                                                    'idTu',
                                                    userData['id_tu']
                                                            ?.toString() ??
                                                        "",
                                                  );
                                                  await prefs.setString(
                                                    'foto',
                                                    userData['foto']
                                                            ?.toString() ??
                                                        "",
                                                  );
                                                  username.clear();
                                                  password.clear();
                                                  if (!mounted) return;
                                                  navigator.pushReplacement(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const ToolData(),
                                                    ),
                                                  );
                                                } else if (mounted) {
                                                  scaffoldMessenger
                                                      .showSnackBar(
                                                        SnackBar(
                                                          duration:
                                                              const Duration(
                                                                seconds: 4,
                                                              ),
                                                          backgroundColor:
                                                              clrRed,
                                                          content: Text(
                                                            message,
                                                          ),
                                                        ),
                                                      );
                                                }
                                              } catch (e) {
                                                if (mounted) {
                                                  scaffoldMessenger
                                                      .showSnackBar(
                                                        SnackBar(
                                                          backgroundColor:
                                                              clrRed,
                                                          content: Text(
                                                            cekInternet,
                                                          ),
                                                        ),
                                                      );
                                                }
                                              } finally {
                                                if (mounted) {
                                                  setState(() {
                                                    loadingLogin = false;
                                                  });
                                                }
                                              }
                                            }
                                          },
                                    icon: loadingLogin
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.login_rounded,
                                            size: 20,
                                          ),
                                    label: Text(
                                      loadingLogin ? "Loading..." : "LOGIN",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: clrOrange,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
