import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/features/auth/presentation/sign_in_screen.dart';
import '/l10n/app_localizations.dart';

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

    if (!_formKey.currentState!.validate()) return;

    final t = AppLocalizations.of(context)!;

    final newName = _usernameCtrl.text.trim();
    final newEmail = _emailCtrl.text.trim();
    final newPassword = _passwordCtrl.text;

    final nameChanged =
        newName.isNotEmpty && newName != (user.displayName ?? '');
    final emailChanged =
        newEmail.isNotEmpty && newEmail != (user.email ?? '');

    setState(() => _isSaving = true);

    try {
      if (nameChanged) {
        await user.updateDisplayName(newName);
      }

      if (emailChanged) {
        await _updateEmailCompat(user, newEmail);
      }

      if (newPassword.isNotEmpty) {
        if (newPassword.length < 6) {
          throw FirebaseAuthException(
            code: 'weak-password',
            message: t.accountWeakPasswordError,
          );
        }
        await user.updatePassword(newPassword);
      }

      await user.reload();
      final refreshed = FirebaseAuth.instance.currentUser;

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            emailChanged
                ? t.accountChangesSavedEmailVerificationHint
                : t.accountChangesSaved,
          ),
          duration: const Duration(milliseconds: 1200),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() => _isSaving = false);

      final msg = _friendlyAuthError(context, e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          duration: const Duration(milliseconds: 1600),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.accountCouldNotSaveChanges)),
      );
    }
  }

  /// Compatibility layer for firebase_auth API differences.
  Future<void> _updateEmailCompat(User user, String newEmail) async {
    final dyn = user as dynamic;

    try {
      await dyn.verifyBeforeUpdateEmail(newEmail);
      return;
    } on NoSuchMethodError {
      // Fall back
    }

    await dyn.updateEmail(newEmail);
  }

  String _friendlyAuthError(BuildContext context, FirebaseAuthException e) {
    final t = AppLocalizations.of(context)!;

    switch (e.code) {
      case 'requires-recent-login':
        return t.accountRequiresRecentLoginError;
      case 'email-already-in-use':
        return t.accountEmailAlreadyInUseError;
      case 'invalid-email':
        return t.accountInvalidEmailError;
      case 'weak-password':
        return e.message ?? t.accountWeakPasswordGenericError;
      default:
        return e.message ?? t.accountAuthGenericError;
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

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final t = AppLocalizations.of(ctx)!;
        return AlertDialog(
          backgroundColor: const Color(0xFF15151A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            t.accountDeleteDialogTitle,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          content: Text(
            t.accountDeleteDialogBody,
            style: GoogleFonts.poppins(color: Colors.grey[300]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(t.commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(t.commonDelete),
            ),
          ],
        );
      },
    ) ??
        false;

    if (!mounted) return;
    if (!confirmed) return;

    final t = AppLocalizations.of(context)!;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
      await user.delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.accountDeletedSnackbar)),
      );

      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final msg = _friendlyAuthError(context, e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.accountCouldNotDelete)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

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
          t.accountTitle,
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
                    decoration: _inputDecoration(t.accountUsernameLabel),
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (s.isEmpty) return t.accountUsernameEmptyError;
                      if (s.length < 2) return t.accountUsernameTooShortError;
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
                    decoration: _inputDecoration(t.accountPasswordLabel).copyWith(
                      hintText: t.accountPasswordLeaveBlankHint,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
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
                    decoration: _inputDecoration(t.accountEmailLabel),
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (s.isEmpty) return t.accountEmailEmptyError;
                      if (!s.contains('@')) return t.accountEmailInvalidError;
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 14),

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
                              ? t.accountEmailVerified
                              : t.accountEmailNotVerified,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ),
                      if (!user.emailVerified)
                        TextButton(
                          onPressed: () async {
                            try {
                              await user.sendEmailVerification();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(t.accountVerificationEmailSent),
                                ),
                              );
                            } catch (_) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(t.accountVerificationEmailFailed),
                                ),
                              );
                            }
                          },
                          child: Text(
                            t.accountSendButton,
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                _ActionRowCard(
                  title: t.accountMyHabits,
                  color: cardColor,
                  borderColor: borderColor,
                  onTap: () {
                    // Push your habits screen here if needed.
                  },
                ),
                const SizedBox(height: 8),
                _ActionRowCard(
                  title: t.accountDeleteAccount,
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
                      _isSaving ? t.accountSaving : t.accountSaveChanges,
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
                        t.accountLogOut,
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
