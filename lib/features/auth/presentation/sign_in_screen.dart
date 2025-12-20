import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'sign_up_screen.dart';
import 'forgot_password.dart';
import '../data/auth_service.dart';
import '../../habits/presentation/habits_screen.dart';
import '../../settings/presentation/language_screen.dart';


class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _identifierController = TextEditingController(); // email or username
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  String? _error;            // global error (wrong credentials, etc.)
  String? _identifierError;  // per-field errors
  String? _passwordError;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text.trim();

    // Local validation
    setState(() {
      _identifierError =
      identifier.isEmpty ? 'Please enter email or username' : null;
      _passwordError =
      password.isEmpty ? 'Please enter your password' : null;
      _error = null;
    });

    if (_identifierError != null || _passwordError != null) {
      return; // don't hit Firebase if fields are invalid
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.instance.signInWithIdentifier(
        identifier: identifier,
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
        switch (e.code) {
          case 'user-not-found':
          case 'wrong-password':
          case 'invalid-credential':
            _error = 'Email/username or password is incorrect.';
            break;
          case 'too-many-requests':
            _error =
            'Too many attempts. Please wait a moment and try again.';
            break;
          case 'network-request-failed':
            _error =
            'Network error. Check your connection and try again.';
            break;
          default:
            _error = e.message ?? 'Could not sign you in.';
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
    final bgColor = const Color(0xFF111015); // dark background
    final fieldColor = const Color(0xFF1E1C22);
    final borderColor = Colors.white12;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () async {
                      // Opens the language picker; returns code if you kept Navigator.pop(code)
                      final result = await Navigator.of(context).push<String>(
                        MaterialPageRoute(
                          builder: (_) => const LanguageScreen(),
                        ),
                      );

                      // If you later wire localization, apply it here using your state manager.
                      // For now, you can just keep the selection or ignore.
                      debugPrint('Selected language: $result');
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1E1C22),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'lib/assets/uk_flag.png', // default icon (you can swap based on saved locale)
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Logo
                SizedBox(
                  height: 160,
                  child: Image.asset(
                    'lib/assets/Light_Logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 32),

                // Sign In title
                Text(
                  'Sign In',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Global error (wrong credentials, etc.)
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

                // Identifier field (email or username)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Email or Username',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[300],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _AuthTextField(
                  controller: _identifierController,
                  hintText: 'Enter email or username',
                  fieldColor: fieldColor,
                  borderColor: borderColor,
                  prefixIcon: Icons.person_outline,
                  obscureText: false,
                ),
                if (_identifierError != null) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _identifierError!,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // Password field
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Password',
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

                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Sign in button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignIn,
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
                      'Sign in',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // "Or continue with" divider
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
                        'Or continue with',
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

                // Social buttons (not wired yet)
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


                const SizedBox(height: 24),

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account yet? ",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF77F7E2),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

// Reusable auth text field
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

class _SocialButton extends StatelessWidget {
  final IconData icon;

  const _SocialButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: Social sign-in
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
