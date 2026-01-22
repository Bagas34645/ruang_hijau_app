import 'package:flutter/material.dart';
import '../services/api.dart';
import '../services/google_auth_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _loading = false;
  bool _googleLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Google Sign-In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  // ===== GOOGLE SIGN-IN =====
  Future<void> _handleGoogleSignIn() async {
    if (_googleLoading || _loading) return;

    setState(() => _googleLoading = true);

    try {
      print('DEBUG: Starting Google Sign-In from Register...');

      // Sign out dulu untuk memastikan user bisa pilih akun
      await _googleSignIn.signOut();

      // Mulai proses sign in
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('DEBUG: User cancelled Google Sign-In');
        if (mounted) {
          setState(() => _googleLoading = false);
        }
        return;
      }

      print('DEBUG: Google Sign-In successful');
      print('DEBUG: Email: ${googleUser.email}');

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Kirim ke backend
      final response = await GoogleAuthService.signInWithGoogle(
        googleId: googleUser.id,
        email: googleUser.email,
        displayName: googleUser.displayName ?? googleUser.email.split('@')[0],
        photoUrl: googleUser.photoUrl,
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      if (!mounted) return;

      print('DEBUG: Backend response: ${response['statusCode']}');

      if (response['statusCode'] == 200 && response['user'] != null) {
        final isNewUser = response['isNewUser'] ?? false;

        _showSnackBar(
          isNewUser
              ? 'Akun Google berhasil didaftarkan!'
              : 'Akun Google sudah terdaftar. Login berhasil!',
          isError: false,
        );

        // Navigate to home
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        setState(() => _googleLoading = false);
        final body = response['body'];
        final message = body?['message'] ?? 'Pendaftaran Google gagal';
        _showSnackBar(message, isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _googleLoading = false);
      print('DEBUG: Google Sign-In error: $e');
      _showSnackBar('Terjadi kesalahan: $e', isError: true);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Mohon periksa kembali form Anda', isError: true);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      print(
        'DEBUG: Attempting registration with email: ${_emailCtrl.text.trim()}',
      );

      final res = await Api.register({
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'password': _passwordCtrl.text,
        'phone': _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      });

      if (!mounted) return;

      print('DEBUG: Registration response statusCode: ${res['statusCode']}');
      print('DEBUG: Registration response body: ${res['body']}');

      final body = res['body'];
      final message = body?['message'] ?? 'Terjadi kesalahan registrasi';

      if (res['statusCode'] == 201) {
        // Success
        _showSnackBar(message, isError: false);
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;

        // Clear form before navigation
        _nameCtrl.clear();
        _emailCtrl.clear();
        _passwordCtrl.clear();
        _confirmPasswordCtrl.clear();
        _phoneCtrl.clear();

        // Navigate back to login
        Navigator.pop(context);
      } else if (res['statusCode'] == 400) {
        // Validation error from backend
        setState(() => _loading = false);
        _showSnackBar(message, isError: true);
      } else {
        // Other errors
        setState(() => _loading = false);
        _showSnackBar(
          message ?? 'Terjadi kesalahan. Status: ${res['statusCode']}',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      print('DEBUG: Registration error: $e');
      _showSnackBar('Terjadi kesalahan: $e', isError: true);
    }
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

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (value.trim().length < 3) {
      return 'Nama minimal 3 karakter';
    }
    if (value.trim().length > 100) {
      return 'Nama maksimal 100 karakter';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid (contoh: user@example.com)';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    if (value.length > 50) {
      return 'Password maksimal 50 karakter';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != _passwordCtrl.text) {
      return 'Password tidak cocok';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      // Optional field, but if filled must be valid
      if (value.trim().length < 7) {
        return 'Nomor telepon minimal 7 digit';
      }
      if (value.trim().length > 20) {
        return 'Nomor telepon maksimal 20 karakter';
      }
      // Allow only digits, spaces, hyphens, plus, and parentheses
      if (!RegExp(r'^[0-9\-\+\(\)\s]{7,20}$').hasMatch(value.trim())) {
        return 'Format nomor telepon tidak valid';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green[700]),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildGoogleSignInButton(),
                    const SizedBox(height: 20),
                    _buildDivider(),
                    const SizedBox(height: 20),
                    _buildNameField(),
                    const SizedBox(height: 16),
                    _buildEmailField(),
                    const SizedBox(height: 16),
                    _buildPhoneField(),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    const SizedBox(height: 16),
                    _buildConfirmPasswordField(),
                    const SizedBox(height: 32),
                    _buildRegisterButton(),
                    const SizedBox(height: 16),
                    _buildLoginRedirect(),
                    const SizedBox(height: 20),
                  ],
                ),
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
          child: Icon(
            Icons.person_add_rounded,
            size: 48,
            color: Colors.green[700],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Buat Akun Baru',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.green[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Daftar untuk bergabung dengan komunitas kami',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton() {
    return OutlinedButton(
      onPressed: () {
        if (_loading || _googleLoading) return;
        _handleGoogleSignIn();
      },
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: Colors.grey.shade300, width: 1.5),
        backgroundColor: Colors.white,
      ),
      child: _googleLoading
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'https://www.google.com/favicon.ico',
                  width: 24,
                  height: 24,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.g_mobiledata,
                      color: Colors.red[600],
                      size: 28,
                    );
                  },
                ),
                const SizedBox(width: 12),
                Text(
                  'Daftar dengan Google',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'atau daftar dengan email',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameCtrl,
      validator: _validateName,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: 'Nama Lengkap',
        hintText: 'Masukkan nama lengkap Anda',
        prefixIcon: Icon(Icons.person, color: Colors.green[700]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green[700]!, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailCtrl,
      validator: _validateEmail,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'Masukkan email Anda',
        prefixIcon: Icon(Icons.email, color: Colors.green[700]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green[700]!, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneCtrl,
      validator: _validatePhone,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: 'Nomor Telepon (Opsional)',
        hintText: 'Masukkan nomor telepon',
        prefixIcon: Icon(Icons.phone, color: Colors.green[700]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green[700]!, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordCtrl,
      validator: _validatePassword,
      textInputAction: TextInputAction.next,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Minimal 6 karakter',
        prefixIcon: Icon(Icons.lock, color: Colors.green[700]),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey[600],
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green[700]!, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordCtrl,
      validator: _validateConfirmPassword,
      obscureText: _obscureConfirmPassword,
      decoration: InputDecoration(
        labelText: 'Konfirmasi Password',
        hintText: 'Masukkan ulang password',
        prefixIcon: Icon(Icons.lock, color: Colors.green[700]),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey[600],
          ),
          onPressed: () => setState(
            () => _obscureConfirmPassword = !_obscureConfirmPassword,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green[700]!, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: (_loading || _googleLoading) ? null : _register,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey[300],
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
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
              'Daftar Sekarang',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
    );
  }

  Widget _buildLoginRedirect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sudah punya akun? ',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          child: Text(
            'Masuk',
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
