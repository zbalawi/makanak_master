import 'package:flutter/foundation.dart';

import '../../../core/models/order.dart';
import '../../../core/models/user_session.dart';
import '../../../data/auth_repository.dart';


class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo;

  AuthProvider(this._repo);

  UserSession? _user;
  bool _loading = false;
  String? _error;

  UserSession? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  Future<void> restoreSession() async {
    _user = await _repo.getCurrentUser();
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _error = null;
    try {
      _user = await _repo.login(email: email, password: password);
      notifyListeners();
      return true;
    } catch (e) {
      _error = _mapAuthError(e.toString());
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required UserType type,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      await _repo.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        address: address,
        type: type,
      );
      // ملاحظة: حسب طلبك: بعد التسجيل يرجع على login، فمش لازم نعمل auto-login هنا
      return true;
    } catch (e) {
      _error = _mapAuthError(e.toString());
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    _user = null;
    notifyListeners();
  }

  Future<bool> updateProfile({String? name, String? phone, String? address}) async {
    _setLoading(true);
    _error = null;
    try {
      _user = await _repo.updateProfile(name: name, phone: phone, address: address);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'حدث خطأ أثناء حفظ البيانات';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> changePassword({required String currentPassword, required String newPassword}) async {
    _setLoading(true);
    _error = null;
    try {
      await _repo.changePassword(currentPassword: currentPassword, newPassword: newPassword);
      return true;
    } catch (e) {
      final t = e.toString();
      _error = t.contains('WRONG_PASSWORD') ? 'كلمة المرور الحالية غير صحيحة' : 'تعذر تغيير كلمة المرور';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  String _mapAuthError(String text) {
    if (text.contains('EMAIL_EXISTS')) return 'هذا البريد مسجل من قبل';
    if (text.contains('USER_NOT_FOUND')) return 'المستخدم غير موجود';
    if (text.contains('WRONG_PASSWORD')) return 'كلمة المرور غير صحيحة';
    return 'حدث خطأ. حاول مرة أخرى';
  }
}
