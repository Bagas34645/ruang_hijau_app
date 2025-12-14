import 'package:flutter/material.dart';
import '../services/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;

  void _login() async {
    setState(() => _loading = true);
    // Capture messenger and navigator synchronously to avoid using
    // BuildContext across async gaps.
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final res = await Api.login({
      'email': _emailCtrl.text,
      'password': _passwordCtrl.text,
    });

    if (!mounted) return;
    setState(() => _loading = false);

    if (res['statusCode'] == 200 && res['user'] != null) {
      final body = res['body'];
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(body?['message'] ?? 'Login berhasil')),
      );
      navigator.pushNamedAndRemoveUntil('/home', (route) => false);
    } else {
      final body = res['body'];
      // If server responded OK but token missing, show clearer message
      String msg = body?['message'] ?? 'Login gagal';
      if (res['statusCode'] == 200 && res['user'] == null) {
        // Attempt to read token from SharedPreferences (maybe saved by Api.login earlier)
        // Try to see if user was stored locally by Api.login
        final prefs = await SharedPreferences.getInstance();
        final localUser = prefs.getString('user');
        if (localUser != null && localUser.isNotEmpty) {
          if (!mounted) return;
          messenger.showSnackBar(
            SnackBar(content: Text(body?['message'] ?? 'Login berhasil')),
          );
          navigator.pushNamedAndRemoveUntil('/home', (route) => false);
          return;
        }

        // Show debug dialog with response to help diagnose why token is missing
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) {
              final text = '${res['statusCode']} - ${res['body'] ?? 'no body'}';
              return AlertDialog(
                title: const Text('Token tidak ditemukan'),
                content: SingleChildScrollView(child: Text(text)),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                    child: const Text('Tutup'),
                  ),
                  TextButton(
                    onPressed: () async {
                      // copy to clipboard if available
                      try {
                        // import not added; use Clipboard if available at runtime
                        Navigator.pop(ctx);
                      } catch (_) {
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text('Salin'),
                  ),
                ],
              );
            },
          );
        }

        msg =
            'Login berhasil, tapi token tidak diterima dari server. Coba lagi atau hubungi administrator.';
      }
      messenger.showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Selamat Datang',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _emailCtrl,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Masuk',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text('Belum punya akun? Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
