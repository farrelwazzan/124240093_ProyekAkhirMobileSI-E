
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLogin = true;
  bool isLoading = false;
  String? errorMessage;


  Future<void> submit() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      if (isLogin) {
        await _authService.login(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login berhasil! Selamat datang di KuliNear.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await _authService.register(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi berhasil! Akun berhasil dibuat.'),
            backgroundColor: Colors.green,
          ),
        );
      }
      } catch (e) {
        if (!mounted) return;

        String message;

        final error = e.toString().toLowerCase();

        if (error.contains('invalid login credentials')) {
          message = 'Email atau password yang kamu masukkan salah.';
        } else if (error.contains('user already registered')) {
          message = 'Email sudah terdaftar. Silakan login.';
        } else if (error.contains('password should be')) {
          message = 'Password belum memenuhi ketentuan.';
        } else if (error.contains('email not confirmed')) {
          message = 'Email belum dikonfirmasi.';
        } else {
          message = isLogin
              ? 'Login gagal. Periksa kembali data akunmu.'
              : 'Registrasi gagal. Silakan coba kembali.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.restaurant,
                  size: 64,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),

                const Text(
                  'KuliNear',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  isLogin
                      ? 'Masuk ke akun kamu'
                      : 'Buat akun KuliNear',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                if (errorMessage != null)
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),

                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: isLoading ? null : submit,
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : Text(isLogin ? 'Login' : 'Register'),
                ),

                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          setState(() {
                            isLogin = !isLogin;
                            errorMessage = null;
                          });
                        },
                  child: Text(
                    isLogin
                        ? 'Belum punya akun? Register'
                        : 'Sudah punya akun? Login',
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
