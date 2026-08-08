import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/login_response.dart';
import '../models/user_model.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  final bool registrationSuccess;

  const LoginPage({super.key, this.registrationSuccess = false});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    if (widget.registrationSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Pendaftaran Berhasil')),
              ],
            ),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });
    final LoginResponse response = await _authService.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );
    setState(() {
      _isLoading = false;
    });
    if (response.status == 'success' && response.user != null) {
      final UserModel userData = response.user!;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('Selamat datang, ${userData.name}!'),
              ],
            ),
            backgroundColor: const Color(0xFF2E7D32), // Hijau kustom
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    response.message,

                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFC62828), // Merah kustom
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Money Notes',

                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,

                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),

                const Text(
                  'Kelola catatan keuangan Anda dengan mudah',

                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // ======== CARD FORM LOGIN ========
                Container(
                  padding: const EdgeInsets.all(24.0),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),

                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),

                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,

                      children: [
                        const Text(
                          'Masuk ke Akun',
                          style: TextStyle(
                            fontSize: 18,

                            fontWeight: FontWeight.bold,
                            color: Color(0xFF263238),
                          ),
                        ),

                        const SizedBox(height: 24),
                        // Kolom Input Username
                        TextFormField(
                          controller: _usernameController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Username',

                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),

                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),

                              borderSide: const BorderSide(
                                color: Color(0xFF1565C0),

                                width: 1.5,
                              ),
                            ),
                          ),

                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Username wajib diisi';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 18),
                        // Kolom Input Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleLogin(),
                          decoration: InputDecoration(
                            labelText: 'Password',

                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),

                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),

                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey),
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),

                              borderSide: const BorderSide(
                                color: Color(0xFF1565C0),

                                width: 1.5,
                              ),
                            ),
                          ),

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password wajib diisi';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 24),
                        // Tombol Submit Masuk
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,

                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),

                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),

                            elevation: 2,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'MASUK',

                                  style: TextStyle(
                                    fontSize: 16,

                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ======== FOOTER TEXT ========
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Text(
                      'Belum memiliki akun? ',

                      style: TextStyle(color: Colors.grey),
                    ),

                    GestureDetector(
                      onTap: () {
                        // Link halaman register
                      },

                      child: const Text(
                        'Daftar Sekarang',
                        style: TextStyle(
                          color: Color(0xFF1565C0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Link Masuk Tanpa Login
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,

                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },

                  child: const Text(
                    'Masuk tanpa login',

                    style: TextStyle(color: Colors.grey),
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
