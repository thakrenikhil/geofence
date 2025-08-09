import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../flutter_gen/gen_l10n/app_localizations.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _officeNameController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _radiusController = TextEditingController(
    text: '100',
  );
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _officeNameController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _radiusController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final auth = FirebaseAuth.instance;
      final cred = await auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final user = cred.user!;
      // First-admin bootstrap: if no admin exists, this user becomes admin.
      final adminCheck = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();
      final assignedRole = adminCheck.docs.isEmpty ? 'admin' : 'employee';
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': assignedRole,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      });

      // If first admin, also create an office record
      if (assignedRole == 'admin') {
        await FirebaseFirestore.instance.collection('offices').add({
          'name': _officeNameController.text.trim(),
          'latitude': double.tryParse(_latitudeController.text.trim()) ?? 0,
          'longitude': double.tryParse(_longitudeController.text.trim()) ?? 0,
          'radiusMeters': double.tryParse(_radiusController.text.trim()) ?? 100,
          'createdBy': user.uid,
          'createdAt': DateTime.now().toUtc().toIso8601String(),
        });
      }
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (!mounted) return;
      if (assignedRole == 'admin') {
        context.go('/admin');
      } else {
        context.go('/employee');
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Auth error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isWide = MediaQuery.of(context).size.width > 700;
    return Scaffold(
      appBar: AppBar(title: Text(t.signUp)),
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
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Admin bootstrap: Use this only for office admins',
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(color: Colors.orange),
                      ),
                    ),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: t.name),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
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
                          (v == null || v.length < 6) ? 'Min 6 chars' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(labelText: t.confirmPassword),
                      validator: (v) => (v != _passwordController.text)
                          ? 'Passwords do not match'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    // Office details (only required when bootstrapping first admin)
                    ExpansionTile(
                      title: const Text('Office details (for admin only)'),
                      initiallyExpanded: true,
                      children: [
                        TextFormField(
                          controller: _officeNameController,
                          decoration: const InputDecoration(
                            labelText: 'Office name',
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Required for admin'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _latitudeController,
                                decoration: const InputDecoration(
                                  labelText: 'Latitude',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _longitudeController,
                                decoration: const InputDecoration(
                                  labelText: 'Longitude',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _radiusController,
                                decoration: const InputDecoration(
                                  labelText: 'Radius (meters)',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: () async {
                                final result = await Navigator.of(
                                  context,
                                ).pushNamed('/mapPicker');
                                if (result != null) {
                                  final map = result as dynamic;
                                  final lat = (map.latitude as double?) ?? 0;
                                  final lng = (map.longitude as double?) ?? 0;
                                  final rad =
                                      (map.radiusMeters as double?) ?? 100;
                                  _latitudeController.text = lat
                                      .toStringAsFixed(6);
                                  _longitudeController.text = lng
                                      .toStringAsFixed(6);
                                  _radiusController.text = rad.toStringAsFixed(
                                    0,
                                  );
                                }
                              },
                              icon: const Icon(Icons.map),
                              label: const Text('Pick on map'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                    const SizedBox(height: 8),
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
                            : Text(t.signUp),
                      ),
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
