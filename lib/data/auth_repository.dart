import '../core/models/order.dart';
import '../core/models/user_session.dart';

abstract class AuthRepository {
  Future<UserSession> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required UserType type,
  });

  Future<UserSession> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<UserSession?> getCurrentUser();

  Future<UserSession> updateProfile({
    String? name,
    String? phone,
    String? address,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

class InMemoryAuthRepository implements AuthRepository {
  final Map<String, UserSession> _usersByEmail = {};
  final Map<String, String> _passwordsByEmail = {};

  UserSession? _currentUser;

  @override
  Future<UserSession> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required UserType type,
  }) async {
    final key = email.toLowerCase();
    if (_usersByEmail.containsKey(key)) {
      throw Exception('EMAIL_EXISTS');
    }

    final uid = DateTime.now().millisecondsSinceEpoch.toString();
    final session = UserSession(
      uid: uid,
      name: name,
      email: key,
      phone: phone,
      address: address,
      type: type,
    );

    _usersByEmail[key] = session;
    _passwordsByEmail[key] = password;
    _currentUser = session;

    return session;
  }

  @override
  Future<UserSession> login({
    required String email,
    required String password,
  }) async {
    final key = email.toLowerCase();
    if (!_usersByEmail.containsKey(key)) {
      throw Exception('USER_NOT_FOUND');
    }

    final storedPass = _passwordsByEmail[key];
    if (storedPass != password) {
      throw Exception('WRONG_PASSWORD');
    }

    final session = _usersByEmail[key]!;
    _currentUser = session;
    return session;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }

  @override
  Future<UserSession?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<UserSession> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    if (_currentUser == null) {
      throw Exception('NOT_LOGGED_IN');
    }

    final emailKey = _currentUser!.email.toLowerCase();
    final updated = UserSession(
      uid: _currentUser!.uid,
      name: name ?? _currentUser!.name,
      email: _currentUser!.email,
      phone: phone ?? _currentUser!.phone,
      address: address ?? _currentUser!.address,
      type: _currentUser!.type,
    );

    _usersByEmail[emailKey] = updated;
    _currentUser = updated;
    return updated;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_currentUser == null) {
      throw Exception('NOT_LOGGED_IN');
    }

    final emailKey = _currentUser!.email.toLowerCase();
    final stored = _passwordsByEmail[emailKey];

    if (stored != currentPassword) {
      throw Exception('WRONG_PASSWORD');
    }

    _passwordsByEmail[emailKey] = newPassword;
  }
}
