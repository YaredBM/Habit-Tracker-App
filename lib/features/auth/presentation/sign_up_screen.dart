import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/l10n/app_localizations.dart';

import '../../habits/presentation/habits_screen.dart';
import '../data/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  String? _error; // global Firebase error
  String? _emailError; // per-field errors
  String? _usernameError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final t = AppLocalizations.of(context)!;

    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // Local validation
    setState(() {
      _emailError = email.isEmpty ? t.signUpEmailRequired : null;
      _usernameError = username.isEmpty ? t.signUpUsernameRequired : null;
      _passwordError = password.isEmpty ? t.signUpPasswordRequired : null;
      _error = null;
    });

    // If any field is invalid, don't hit Firebase
    if (_emailError != null || _usernameError != null || _passwordError != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.instance.signUpWithEmailAndUsername(
        email: email,
        username: username,
        password: password,
      );

      if (!mounted) return;

      // Go to Habits and clear auth screens from back stack
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HabitsScreen()),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message ?? t.signUpErrorDefault;
      });
    } catch (e, _) {
      setState(() {
        _error = t.signUpErrorGeneric;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final bgColor = const Color(0xFF111015); // dark background
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
                  t.signUpTitle,
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
                    t.signUpEmailLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[300],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _AuthTextField(
                  controller: _emailController,
                  hintText: t.signUpEmailHint,
                  fieldColor: fieldColor,
                  borderColor: borderColor,
                  prefixIcon: Icons.email_outlined,
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

                // Username
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    t.signUpUsernameLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[300],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _AuthTextField(
                  controller: _usernameController,
                  hintText: t.signUpUsernameHint,
                  fieldColor: fieldColor,
                  borderColor: borderColor,
                  prefixIcon: Icons.person_outline,
                  obscureText: false,
                ),
                if (_usernameError != null) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _usernameError!,
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
                    t.signUpPasswordLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[300],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _AuthTextField(
                  controller: _passwordController,
                  hintText: t.signUpPasswordHint,
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

                const SizedBox(height: 22),

                // Sign up button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignUp,
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
                      t.signUpButton,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Or continue with
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey[700],
                        thickness: 0.7,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        t.signUpOrContinueWith,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey[700],
                        thickness: 0.7,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Social buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    _SocialButton(
                      icon: Icons.g_mobiledata, // placeholder
                    ),
                    SizedBox(width: 16),
                    _SocialButton(
                      icon: Icons.facebook,
                    ),
                  ],
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

// Reusable auth textfield
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

class _SocialButton extends StatelessWidget {
  final IconData icon;

  const _SocialButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: Social sign up
      },
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        width: 56,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1C22),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }
}
