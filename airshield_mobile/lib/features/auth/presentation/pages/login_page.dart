import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/auth_bloc.dart';
import 'register_page.dart';

/// Login Page
/// 
/// Allows users to sign in with email and password
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                _buildHeader(),
                const SizedBox(height: 48),
                _buildForm(),
                const SizedBox(height: 24),
                _buildLoginButton(),
                const SizedBox(height: 16),
                _buildDemoButton(),
                const SizedBox(height: 16),
                _buildRegisterLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.shield,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome to',
          style: GoogleFonts.poppins(
            fontSize: 24,
            color: Colors.white70,
          ),
        ),
        Text(
          'AirShield',
          style: GoogleFonts.poppins(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to monitor air quality and protect your health',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.poppins(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: GoogleFonts.poppins(color: Colors.white54),
              prefixIcon: const Icon(Icons.email_outlined, color: Colors.white54),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF4CAF50)),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              filled: true,
              fillColor: const Color(0xFF16213E),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Password field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: GoogleFonts.poppins(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: GoogleFonts.poppins(color: Colors.white54),
              prefixIcon: const Icon(Icons.lock_outlined, color: Colors.white54),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white54,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF4CAF50)),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              filled: true,
              fillColor: const Color(0xFF16213E),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : _onLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Sign In',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildDemoButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: () {
          context.read<AuthBloc>().add(const DemoLoginRequested());
        },
        icon: const Icon(Icons.visibility_outlined, size: 18, color: Colors.white54),
        label: Text(
          'Xem thử (Demo)',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white54,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white54,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RegisterPage()),
            );
          },
          child: Text(
            'Sign Up',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF4CAF50),
            ),
          ),
        ),
      ],
    );
  }
}
