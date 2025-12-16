import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/order.dart';
import '../../../core/roots/app_roots.dart';
import '../../../core/roots/app_router.dart';

import '../state/auth_provider.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _snackShown = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorOnce(String message) {
    if (_snackShown) return;
    _snackShown = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      context.read<AuthProvider>().clearError();
      _snackShown = false;
    });
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() != true) return;

    final auth = context.read<AuthProvider>();

    final ok = await auth.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!ok || !mounted) return;

    final user = auth.user;
    if (user == null) return;

    // ✅ التنقل باستخدام Routes فقط
    if (user.type == UserType.client) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.clientHome,
        arguments: ClientHomeArgs(clientName: user.name),
      );
    } else {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.technicianHome,
        arguments: TechnicianHomeArgs(technicianName: user.name),
      );
    }
  }

  void _goToRegister() {
    // ✅ Named Route
    Navigator.pushNamed(context, AppRoutes.register);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final err = auth.error;
    if (err != null && err.isNotEmpty) {
      _showErrorOnce(err);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل الدخول'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 24),

              AppTextField(
                controller: _emailController,
                label: 'البريد الإلكتروني',
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return 'اكتب البريد الإلكتروني';
                  if (!value.contains('@')) return 'بريد غير صالح';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              AppTextField(
                controller: _passwordController,
                label: 'كلمة المرور',
                obscureText: true,
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return 'اكتب كلمة المرور';
                  if (value.length < 6) {
                    return 'كلمة المرور لازم تكون 6 أحرف على الأقل';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // ✅ زر الدخول باستخدام Provider
              AppPrimaryButton(
                text: 'دخول',
                loading: auth.loading,
                onPressed: auth.loading ? null : _handleLogin,
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: _goToRegister,
                child: const Text('ما عندك حساب؟ سجل الآن'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
