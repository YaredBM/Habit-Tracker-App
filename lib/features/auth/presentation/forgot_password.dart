import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/auth_service.dart';
import 'sign_in_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  String? _error; // global Firebase / generic error
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleDone() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Local validation
    setState(() {
      _emailError =
      email.isEmpty ? 'Please enter your email or username' : null;
      _passwordError =
      password.isEmpty ? 'Please enter a new password' : null;
      _confirmPasswordError =
      confirmPassword.isEmpty ? 'Please confirm your password' : null;
      _error = null;
    });

    if (_emailError != null ||
        _passwordError != null ||
        _confirmPasswordError != null) {
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _confirmPasswordError = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Firebase reset flow: send reset email
      await AuthService.instance.sendPasswordResetEmail(email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password reset email sent. Please check your inbox.',
          ),
        ),
      );

      // Go back to Sign In screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            _error = 'No account found for that email.';
            break;
          case 'invalid-email':
            _error = 'Please enter a valid email.';
            break;
          case 'network-request-failed':
            _error = 'Network error. Please try again.';
            break;
          default:
            _error = e.message ?? 'Failed to send reset email.';
        }
      });
    } catch (_) {
      setState(() {
        _error = 'Something went wrong. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFF111015);
    final fieldColor = const Color(0xFF1E1C22);
    final borderColor = Colors.white12;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                SizedBox(
                  height: 150,
                  child: Image.asset(
                    'lib/assets/Light_Logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'New password',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Global error
                if (_error != null) ...[
                  Text(
                    _error!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.redAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                ],

                // Email
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Email',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[300],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _AuthTextField(
                  controller: _emailController,
                  hintText: 'Enter email or username',
                  fieldColor: fieldColor,
                  borderColor: borderColor,
                  prefixIcon: Icons.person_outline,
                  obscureText: false,
                ),
                if (_emailError != null) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _emailError!,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 18),

                // Password
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'New Password',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[300],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _AuthTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  fieldColor: fieldColor,
                  borderColor: borderColor,
                  prefixIcon: Icons.vpn_key_outlined,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey[400],
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                if (_passwordError != null) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _passwordError!,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 18),

                // Confirm Password
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Confirm Password',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[300],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _AuthTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Password',
                  fieldColor: fieldColor,
                  borderColor: borderColor,
                  prefixIcon: Icons.vpn_key_outlined,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey[400],
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                if (_confirmPasswordError != null) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _confirmPasswordError!,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 22),

                // Done button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleDone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A282F),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      'Done',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Reusable auth text field
class _AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Color fieldColor;
  final Color borderColor;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;

  const _AuthTextField({
    required this.controller,
    required this.hintText,
    required this.fieldColor,
    required this.borderColor,
    required this.prefixIcon,
    required this.obscureText,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: Colors.white,
      ),
      cursorColor: Colors.white70,
      decoration: InputDecoration(
        filled: true,
        fillColor: fieldColor,
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.grey[500],
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: Colors.grey[400],
        ),
        suffixIcon: suffixIcon,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Colors.white24, width: 1.2),
        ),
      ),
    );
  }
}
