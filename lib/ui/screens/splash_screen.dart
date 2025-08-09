import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth/role_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    scheduleMicrotask(_bootstrap);
  }

  Future<void> _bootstrap() async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      context.go('/login');
      return;
    }
    try {
      final roleService = RoleService(FirebaseFirestore.instance);
      final role = await roleService.fetchRoleForUser(user.uid);
      if (!mounted) return;
      if (role == 'admin') {
        context.go('/admin');
      } else {
        context.go('/employee');
      }
    } catch (_) {
      if (!mounted) return;
      context.go('/employee');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}


