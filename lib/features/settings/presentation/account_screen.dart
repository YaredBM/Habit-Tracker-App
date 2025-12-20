import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/features/auth/presentation/sign_in_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}



class _AccountScreenState extends State<AccountScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _usernameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passwordCtrl;

  bool _obscurePassword = true;
  bool _isSaving = false;

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController(text: _user?.displayName ?? '');
    _emailCtrl = TextEditingController(text: _user?.email ?? '');
    _passwordCtrl = TextEditingController();

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SignInScreen()),
              (_) => false,
        );
      });
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }



  Future<void> _saveChanges() async {
    final user = _user;
    if (user == null) return;

    final messenger = ScaffoldMessenger.of(context);

    if (!_formKey.currentState!.validate()) return;

    final newName = _usernameCtrl.text.trim();
    final newEmail = _emailCtrl.text.trim();
    final newPassword = _passwordCtrl.text;

    final nameChanged = newName.isNotEmpty && newName != (user.displayName ?? '');
    final emailChanged = newEmail.isNotEmpty && newEmail != (user.email ?? '');

    setState(() => _isSaving = true);

    try {
      if (nameChanged) {
        await user.updateDisplayName(newName);
      }

      if (emailChanged) {
        await _updateEmailCompat(user, newEmail);

        // Optional: also mirror to Firestore user profile
      }

      if (newPassword.isNotEmpty) {
        if (newPassword.length < 6) {
          throw FirebaseAuthException(
            code: 'weak-password',
            message: 'Password should be at least 6 characters.',
          );
        }
        await user.updatePassword(newPassword);
      }

      await user.reload();
      final refreshed = FirebaseAuth.instance.currentUser;

      // Mirror basic profile to Firestore for your app UI
      if (refreshed != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(refreshed.uid)
            .set({
          'displayName': refreshed.displayName ?? newName,
          'email': refreshed.email ?? newEmail,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (!mounted) return;
      setState(() => _isSaving = false);
      _passwordCtrl.clear();

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            emailChanged
                ? 'Changes saved. Check your inbox if email verification was sent.'
                : 'Changes saved.',
          ),
          duration: const Duration(milliseconds: 1200),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);

      messenger.showSnackBar(
        SnackBar(
          content: Text(_friendlyAuthError(e)),
          duration: const Duration(milliseconds: 1600),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not save changes. Try again.'),
        ),
      );
    }
  }

  /// Compatibility layer to handle API differences across firebase_auth versions.
  ///
  /// - Newer patterns may offer `verifyBeforeUpdateEmail`.
  /// - Older patterns provide `updateEmail`.
  /// We use `dynamic` to avoid compile-time errors when one method is missing.
  Future<void> _updateEmailCompat(User user, String newEmail) async {
    final dyn = user as dynamic;

    try {
      // Prefer verify-before-update if available
      await dyn.verifyBeforeUpdateEmail(newEmail);
      return;
    } on NoSuchMethodError {
      // Fall back
    }

    // Try classic updateEmail
    await dyn.updateEmail(newEmail);
  }

  String _friendlyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'requires-recent-login':
        return 'For security, please log in again and retry this change.';
      case 'email-already-in-use':
        return 'That email is already in use.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return e.message ?? 'That password is too weak.';
      default:
        return e.message ?? 'Authentication error.';
    }
  }

  Future<void> _logOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignInScreen()),
          (route) => false,
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final user = _user;
    if (user == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF15151A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Delete account?',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          content: Text(
            'This will permanently remove your account data.',
            style: GoogleFonts.poppins(color: Colors.grey[300]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    ) ??
        false;

    if (!confirmed) return;

    try {
      // delete Firestore user doc (optional)
      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();

      // delete auth account
      await user.delete();

      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Account deleted.')),
      );

      nav.pop();
    } on FirebaseAuthException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(_friendlyAuthError(e))),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not delete account.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const SignInScreen();
    }

    final cardColor = const Color(0xFF111116);
    final borderColor = Colors.white.withValues(alpha: 0.08);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'My account',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _FieldCard(
                  color: cardColor,
                  borderColor: borderColor,
                  child: TextFormField(
                    controller: _usernameCtrl,
                    style: GoogleFonts.poppins(color: Colors.white),
                    decoration: _inputDecoration('Username'),
                    validator: (v) {
                      final t = (v ?? '').trim();
                      if (t.isEmpty) return 'Please enter a username.';
                      if (t.length < 2) return 'Too short.';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 10),

                _FieldCard(
                  color: cardColor,
                  borderColor: borderColor,
                  child: TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    style: GoogleFonts.poppins(color: Colors.white),
                    decoration: _inputDecoration('Password').copyWith(
                      hintText: 'Leave blank to keep current',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                _FieldCard(
                  color: cardColor,
                  borderColor: borderColor,
                  child: TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.poppins(color: Colors.white),
                    decoration: _inputDecoration('Email'),
                    validator: (v) {
                      final t = (v ?? '').trim();
                      if (t.isEmpty) return 'Please enter an email.';
                      if (!t.contains('@')) return 'Invalid email.';
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 14),

                // Optional quick info row
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.verified_user,
                          color: Colors.white.withValues(alpha: 0.7), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          user.emailVerified
                              ? 'Email verified'
                              : 'Email not verified',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ),
                      if (!user.emailVerified)
                        TextButton(
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            try {
                              await user.sendEmailVerification();
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Verification email sent.'),
                                ),
                              );
                            } catch (_) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Could not send verification email.'),
                                ),
                              );
                            }
                          },
                          child: Text(
                            'Send',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // My habits / Delete account rows like your mock
                _ActionRowCard(
                  title: 'My habits',
                  color: cardColor,
                  borderColor: borderColor,
                  onTap: () {
                    // If you have a habits list screen, push it here.
                    // Navigator.of(context).push(MaterialPageRoute(builder: (_) => MyHabitsScreen()));
                  },
                ),
                const SizedBox(height: 8),
                _ActionRowCard(
                  title: 'Delete account',
                  color: cardColor,
                  borderColor: borderColor,
                  onTap: _confirmDeleteAccount,
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _isSaving ? 'Saving...' : 'Save changes',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                GestureDetector(
                  onTap: _logOut,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Log Out',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFFE36A6A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.logout, size: 16, color: Color(0xFFE36A6A)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(
        fontSize: 12,
        color: Colors.white.withValues(alpha: 0.6),
      ),
      hintStyle: GoogleFonts.poppins(
        fontSize: 12,
        color: Colors.white.withValues(alpha: 0.35),
      ),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({
    required this.child,
    required this.color,
    required this.borderColor,
  });

  final Widget child;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}

class _ActionRowCard extends StatelessWidget {
  const _ActionRowCard({
    required this.title,
    required this.onTap,
    required this.color,
    required this.borderColor,
  });

  final String title;
  final VoidCallback onTap;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.play_arrow_rounded,
                size: 18,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
