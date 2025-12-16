import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/auth_provider.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_primary_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmNewPassController = TextEditingController();

  bool _initialized = false;
  bool _snackShown = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmNewPassController.dispose();
    super.dispose();
  }

  void _initFromSession(AuthProvider auth) {
    if (_initialized) return;
    final u = auth.user;
    if (u == null) return;

    _nameController.text = u.name;
    _phoneController.text = u.phone;
    _addressController.text = u.address;

    _initialized = true;
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

  Future<void> _saveProfile(AuthProvider auth) async {
    if (_profileFormKey.currentState?.validate() != true) return;

    final ok = await auth.updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حفظ البيانات بنجاح ✔')));
    }
  }

  Future<void> _changePassword(AuthProvider auth) async {
    if (_passwordFormKey.currentState?.validate() != true) return;

    final currentPass = _currentPassController.text.trim();
    final newPass = _newPassController.text.trim();
    final confirm = _confirmNewPassController.text.trim();

    if (newPass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كلمتا المرور الجديدتان غير متطابقتين')),
      );
      return;
    }

    final ok = await auth.changePassword(
      currentPassword: currentPass,
      newPassword: newPass,
    );

    if (!mounted) return;

    if (ok) {
      _currentPassController.clear();
      _newPassController.clear();
      _confirmNewPassController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح ✔')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // تعبئة الحقول أول مرة من بيانات المستخدم
    _initFromSession(auth);

    // عرض أي Error من Provider مرة واحدة
    final err = auth.error;
    if (err != null && err.isNotEmpty) {
      _showErrorOnce(err);
    }

    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: user == null
          ? const Center(child: Text('لا يوجد مستخدم مسجل حالياً'))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الحساب: ${user.email}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'البيانات الشخصية',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Form(
                      key: _profileFormKey,
                      child: Column(
                        children: [
                          AppTextField(
                            controller: _nameController,
                            label: 'الاسم',
                            validator: (v) {
                              final value = v?.trim() ?? '';
                              if (value.isEmpty) return 'اكتب الاسم';
                              if (value.length < 3) return 'الاسم قصير جداً';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: _phoneController,
                            label: 'رقم الموبايل',
                            keyboardType: TextInputType.phone,
                            validator: (v) {
                              final value = v?.trim() ?? '';
                              if (value.isEmpty) return 'اكتب رقم الموبايل';
                              if (value.length < 7)
                                return 'رقم موبايل قصير جداً';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
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
                          const SizedBox(height: 12),

                          AppPrimaryButton(
                            text: 'حفظ البيانات',
                            loading: auth.loading,
                            onPressed: auth.loading
                                ? null
                                : () => _saveProfile(auth),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 12),

                    const Text(
                      'تغيير كلمة المرور',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Form(
                      key: _passwordFormKey,
                      child: Column(
                        children: [
                          AppTextField(
                            controller: _currentPassController,
                            label: 'كلمة المرور الحالية',
                            obscureText: true,
                            validator: (v) {
                              final value = v?.trim() ?? '';
                              if (value.isEmpty)
                                return 'اكتب كلمة المرور الحالية';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: _newPassController,
                            label: 'كلمة المرور الجديدة',
                            obscureText: true,
                            validator: (v) {
                              final value = v?.trim() ?? '';
                              if (value.isEmpty)
                                return 'اكتب كلمة المرور الجديدة';
                              if (value.length < 6)
                                return 'لازم تكون 6 أحرف على الأقل';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: _confirmNewPassController,
                            label: 'تأكيد كلمة المرور الجديدة',
                            obscureText: true,
                            validator: (v) {
                              final value = v?.trim() ?? '';
                              if (value.isEmpty)
                                return 'أكد كلمة المرور الجديدة';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          AppPrimaryButton(
                            text: 'تغيير كلمة المرور',
                            loading: auth.loading,
                            onPressed: auth.loading
                                ? null
                                : () => _changePassword(auth),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
