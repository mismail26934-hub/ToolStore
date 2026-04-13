import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tool_store_app/model/post_get_data.dart';
import 'package:tool_store_app/view/menu/user/user_data.dart';
import 'package:tool_store_app/view/var/var.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Background lembut
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo atau Icon
                Hero(
                  tag: 'logo-app',
                  child: Icon(
                    Icons.lock_person_rounded,
                    size: 80,
                    color: clrOrange,
                  ),
                ),
                SizedBox(height: 16),

                // Judul dengan Font Weight Tebal
                Hero(
                  tag: 'text-app',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      "Data Tool Monitoring ",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
                Text(
                  "Please Login !",
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 32),

                // Card Rounded untuk Form Input
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Input Username/Email
                      TextFormField(
                        controller: username,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Required !' : null,
                      ),
                      SizedBox(height: 20),

                      // Input Password
                      TextFormField(
                        obscureText: isLoadingLogin,
                        controller: password,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isLoadingLogin
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                              () => isLoadingLogin = !isLoadingLogin,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Required !' : null,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),
                // Tombol Login (Full Width & Rounded)
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final navigator = Navigator.of(context);
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        setState(() {
                          isLoadingLogin = true;
                          loadingLogin = true;
                        });
                        // Pastikan ini diset true di awal
                        try {
                          final response = await login(
                            username.text,
                            password.text,
                          );

                          final String statusLogin = (response['value'] ?? "0")
                              .toString();
                          final String message = response['message'] ?? "Error";
                          if (statusLogin == '1') {
                            final userData = response['user'] ?? response;
                            final SharedPreferences prefs =
                                await SharedPreferences.getInstance();

                            // Simpan semua data
                            await prefs.setString('value', statusLogin);
                            await prefs.setString(
                              'idUsersApp',
                              userData['id_users']?.toString() ?? "",
                            );
                            await prefs.setString(
                              'name',
                              userData['nama_user']?.toString() ?? "",
                            );
                            await prefs.setString(
                              'username',
                              userData['username']?.toString() ?? "",
                            );
                            await prefs.setString(
                              'password',
                              userData['password']?.toString() ?? "",
                            );
                            await prefs.setString(
                              'level',
                              userData['level']?.toString() ?? "",
                            );
                            await prefs.setString(
                              'token',
                              userData['token']?.toString() ?? "",
                            );
                            await prefs.setString(
                              'status',
                              userData['status']?.toString() ?? "",
                            );
                            await prefs.setString(
                              'idTu',
                              userData['id_tu']?.toString() ?? "",
                            );
                            await prefs.setString(
                              'foto',
                              userData['foto']?.toString() ?? "",
                            );
                            username.clear();
                            password.clear();
                            // --- WAJIB CEK MOUNTED TEPAT SEBELUM NAVIGASI ---
                            if (!mounted) return;

                            navigator.pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const ToolData(),
                              ),
                            );
                            setState(() {
                              loadingLogin = false;
                            });
                          } else {
                            if (mounted) {
                              loadingLogin = false;
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  duration: Duration(seconds: 4),
                                  backgroundColor: loadingLogin
                                      ? clrOrange
                                      : statusLogin == '1'
                                      ? clrGreen
                                      : clrRed,
                                  content: Text(
                                    loadingLogin ? "Loading" : message,
                                  ),
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                backgroundColor: clrRed,
                                content: Text(cekInternet),
                              ),
                            );
                          }
                        } finally {
                          // --- CEK MOUNTED SEBELUM SETSTATE ---
                          if (mounted) {
                            setState(() {
                              isLoadingLogin = false;
                            });
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: clrOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 2,
                    ),
                    child: loadingLogin
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(clrWhite),
                            strokeWidth: 3,
                          )
                        : Text(
                            "LOGIN",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
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
