import 'package:flutter/material.dart';
import '../services/api.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ===== LOGIKA LOGIN DENGAN VALIDASI =====
  Future<void> _login() async {
    // Validasi input
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty) {
      _showSnackBar('Email tidak boleh kosong', isError: true);
      return;
    }

    if (!_isValidEmail(email)) {
      _showSnackBar('Format email tidak valid', isError: true);
      return;
    }

    if (password.isEmpty) {
      _showSnackBar('Password tidak boleh kosong', isError: true);
      return;
    }

    if (password.length < 6) {
      _showSnackBar('Password minimal 6 karakter', isError: true);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      print('DEBUG: Attempting login with email: $email');

      final res = await Api.login({'email': email, 'password': password});

      if (!mounted) return;

      print('DEBUG: Login response statusCode: ${res['statusCode']}');
      print('DEBUG: Login response body: ${res['body']}');
      print('DEBUG: Login response user: ${res['user']}');

      final body = res['body'];

      // Status 200 = Success
      if (res['statusCode'] == 200 && res['user'] != null) {
        _showSnackBar('Login berhasil!', isError: false);

        // Clear form
        _emailCtrl.clear();
        _passwordCtrl.clear();

        // Navigate to home
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
      // Status 401 = Invalid email/password
      else if (res['statusCode'] == 401) {
        setState(() => _loading = false);
        final message = body?['message'] ?? 'Email atau password salah';
        _showSnackBar(message, isError: true);
      }
      // Status 400 = Bad request (missing fields, etc)
      else if (res['statusCode'] == 400) {
        setState(() => _loading = false);
        final message = body?['message'] ?? 'Request tidak valid';
        _showSnackBar(message, isError: true);
      }
      // Status 500 = Server error
      else if (res['statusCode'] == 500) {
        setState(() => _loading = false);
        final message = body?['message'] ?? 'Terjadi kesalahan server';
        _showSnackBar(message, isError: true);
      }
      // Other status codes
      else {
        setState(() => _loading = false);
        final message =
            body?['message'] ?? 'Login gagal (Status: ${res['statusCode']})';
        _showSnackBar(message, isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      print('DEBUG: Login error: $e');
      _showSnackBar('Terjadi kesalahan: $e', isError: true);
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, maxLines: 2, overflow: TextOverflow.ellipsis),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildEmailField(),
                  const SizedBox(height: 16),
                  _buildPasswordField(),
                  const SizedBox(height: 32),
                  _buildLoginButton(),
                  const SizedBox(height: 16),
                  _buildRegisterRedirect(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[100],
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.eco, size: 48, color: Colors.green[700]),
        ),
        const SizedBox(height: 24),
        Text(
          'Selamat Datang',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.green[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Silakan masuk untuk melanjutkan',
          style: TextStyle(fontSize: 15, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailCtrl,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'nama@email.com',
        prefixIcon: Icon(Icons.email_outlined, color: Colors.green[600]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.shade600, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordCtrl,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Masukkan password',
        prefixIcon: Icon(Icons.lock_outline, color: Colors.green[600]),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey[600],
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.shade600, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: () {
        if (_loading) return;
        _login();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _loading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Masuk',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
    );
  }

  Widget _buildRegisterRedirect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Belum punya akun? ',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/register'),
          child: Text(
            'Daftar',
            style: TextStyle(
              color: Colors.green[700],
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
