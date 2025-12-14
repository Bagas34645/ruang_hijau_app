import 'package:flutter/material.dart';
import '../services/api.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;

  void _register() async {
    setState(() => _loading = true);
    final res = await Api.register({
      'name': _nameCtrl.text,
      'email': _emailCtrl.text,
      'password': _passwordCtrl.text,
    });
    if (!mounted) return;
    setState(() => _loading = false);

    if (res['statusCode'] == 201 || res['statusCode'] == 200) {
      final body = res['body'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(body?['message'] ?? 'Register berhasil')),
      );
      Navigator.pop(context);
    } else {
      final body = res['body'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(body?['message'] ?? 'Register gagal')),
      );
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
                  'Pendaftaran',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                  onPressed: _loading ? null : _register,
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
                          'Daftar',
                          style: TextStyle(color: Colors.white),
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
