import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/di.dart';
import '../../../core/models/order.dart';
import '../../../core/models/user_session.dart';
import '../state/auth_provider.dart';
import '../widgets/app_primary_button.dart';
import '../widgets/app_text_field.dart';
import 'client_home_screen.dart';
import 'technician_home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  UserType _selectedType = UserType.client;

  bool _snackShown = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _showErrorOnce(String message) {
    if (_snackShown) return;
    _snackShown = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      context.read<AuthProvider>().clearError();
      _snackShown = false;
    });
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState?.validate() != true) return;

    final pass = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (pass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كلمتا المرور غير متطابقتين')),
      );
      return;
    }

    final ok = await context.read<AuthProvider>().register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: pass,
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      type: _selectedType,
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنشاء الحساب بنجاح، سجّل الدخول الآن ✔'),
        ),
      );
      Navigator.pop(context); // ✅ رجوع لشاشة تسجيل الدخول
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final err = auth.error;
    if (err != null && err.isNotEmpty) {
      _showErrorOnce(err);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب جديد')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 12),

                AppTextField(
                  controller: _nameController,
                  label: 'الاسم الكامل',
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return 'اكتب اسمك';
                    if (value.length < 3) return 'الاسم قصير جداً';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

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
                  controller: _phoneController,
                  label: 'رقم الموبايل',
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return 'اكتب رقم الموبايل';
                    if (value.length < 7) return 'رقم موبايل قصير جداً';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                AppTextField(
                  controller: _addressController,
                  label: 'العنوان',
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return 'اكتب العنوان';
                    if (value.length < 5) return 'العنوان قصير جداً';
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
                    if (value.length < 6)
                      return 'كلمة المرور لازم تكون 6 أحرف على الأقل';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                AppTextField(
                  controller: _confirmController,
                  label: 'تأكيد كلمة المرور',
                  obscureText: true,
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return 'أكد كلمة المرور';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    const Text('نوع الحساب: '),
                    const SizedBox(width: 8),
                    DropdownButton<UserType>(
                      value: _selectedType,
                      items: const [
                        DropdownMenuItem(
                          value: UserType.client,
                          child: Text('عميل'),
                        ),
                        DropdownMenuItem(
                          value: UserType.technician,
                          child: Text('فني'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _selectedType = value);
                        // ملاحظة: هذا setState بسيط فقط للـ dropdown selection،
                        // أما البيانات/التحميل/الأخطاء كلها Provider.
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                AppPrimaryButton(
                  text: 'إنشاء الحساب',
                  loading: auth.loading,
                  onPressed: auth.loading ? null : _handleRegister,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
