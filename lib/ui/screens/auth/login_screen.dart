import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../flutter_gen/gen_l10n/app_localizations.dart';
import '../../../services/auth/role_service.dart';
import '../../../services/admin/invite_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final auth = FirebaseAuth.instance;
      // If there's a pending invite for this email and the user is new, allow default password login
      final credentials = await auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      String role = 'employee';
      try {
        final roleService = RoleService(FirebaseFirestore.instance);
        role = await roleService.fetchRoleForUser(credentials.user!.uid);
      } catch (e) {
        // Firestore unavailable or not enabled: continue as employee
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Firestore unavailable; continuing as employee'),
            ),
          );
        }
      }
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (role == 'admin') {
        context.go('/admin');
      } else {
        context.go('/employee');
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      // Try to claim an invite using default password 12345678 when sign-in fails
      try {
        final invite = await InviteService(
          FirebaseFirestore.instance,
        ).getInviteByEmail(_emailController.text.trim());
        if (invite != null && _passwordController.text.trim() == '12345678') {
          final created = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                email: _emailController.text.trim(),
                password: '12345678',
              );
          await FirebaseFirestore.instance
              .collection('users')
              .doc(created.user!.uid)
              .set({
                'name': invite['name'] ?? '',
                'email': _emailController.text.trim().toLowerCase(),
                'role': (invite['role'] ?? 'employee').toString(),
                'invited': false,
                'createdAt': DateTime.now().toUtc().toIso8601String(),
              });
          // Remove email-key record now that uid-based record exists
          await InviteService(
            FirebaseFirestore.instance,
          ).deleteInvite(_emailController.text.trim());

          if (!mounted) return;
          setState(() => _isLoading = false);
          final role = (invite['role'] ?? 'employee').toString();
          if (role == 'admin') {
            context.go('/admin');
          } else {
            context.go('/employee');
          }
          return;
        }
      } catch (_) {
        // ignore and show normal error
      }
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Auth error')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: isWide ? 0 : 16),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      t.login,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: t.email),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(labelText: t.password),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(t.signIn),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.push('/signup'),
                      child: Text(t.signUp),
                    ),
                    TextButton(
                      onPressed: () => context.push('/reset'),
                      child: const Text('Forgot password?'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
