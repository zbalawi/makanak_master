import 'package:flutter/material.dart';
import '../../core/models/order.dart';
import '../../core/di.dart';
import '../../core/models/user_session.dart';

class SettingsScreen extends StatefulWidget {
  final String? userName;
  final UserType? userType;

  const SettingsScreen({
    super.key,
    this.userName,
    this.userType,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmNewPassController = TextEditingController();

  UserSession? _session;
  bool _loadingProfile = true;
  bool _savingProfile = false;
  bool _changingPassword = false;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final s = await authRepository.getCurrentUser();
    setState(() {
      _session = s;
      if (s != null) {
        _nameController.text = s.name;
        _phoneController.text = s.phone;
        _addressController.text = s.address;
      }
      _loadingProfile = false;
    });
  }

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

  Future<void> _saveProfile() async {
    if (_session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد مستخدم مسجل حالياً')),
      );
      return;
    }

    setState(() => _savingProfile = true);

    try {
      final updated = await authRepository.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );
      setState(() => _session = updated);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ البيانات بنجاح ✔')),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء حفظ البيانات')),
      );
    } finally {
      if (mounted) setState(() => _savingProfile = false);
    }
  }

  Future<void> _changePassword() async {
    if (_session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد مستخدم مسجل حالياً')),
      );
      return;
    }

    if (_newPassController.text.trim() !=
        _confirmNewPassController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كلمتا المرور الجديدتان غير متطابقتين')),
      );
      return;
    }

    if (_newPassController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('كلمة المرور الجديدة يجب أن تكون 6 أحرف على الأقل')),
      );
      return;
    }

    setState(() => _changingPassword = true);

    try {
      await authRepository.changePassword(
        currentPassword: _currentPassController.text.trim(),
        newPassword: _newPassController.text.trim(),
      );

      _currentPassController.clear();
      _newPassController.clear();
      _confirmNewPassController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح ✔')),
      );
    } catch (e) {
      String message = 'حدث خطأ أثناء تغيير كلمة المرور';
      final text = e.toString();
      if (text.contains('WRONG_PASSWORD')) {
        message = 'كلمة المرور الحالية غير صحيحة';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _changingPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeText = _session?.type == UserType.technician
        ? 'فني'
        : 'عميل';

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: _loadingProfile
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_session != null) ...[
                Text(
                  'الحساب: ${_session!.email} ($typeText)',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
              ],
              const Text(
                'البيانات الشخصية',
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'رقم الموبايل',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'العنوان',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                  _savingProfile ? null : _saveProfile,
                  child: _savingProfile
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2),
                  )
                      : const Text('حفظ البيانات'),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                'تغيير كلمة المرور',
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _currentPassController,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور الحالية',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _newPassController,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور الجديدة',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _confirmNewPassController,
                decoration: const InputDecoration(
                  labelText: 'تأكيد كلمة المرور الجديدة',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _changingPassword
                      ? null
                      : _changePassword,
                  child: _changingPassword
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2),
                  )
                      : const Text('تغيير كلمة المرور'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
