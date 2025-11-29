import '../core/models/order.dart';
import '../core/models/user_session.dart';

abstract class AuthRepository {
  Future<UserSession> register({
    required String name,
    required String email,
    required String password,
    required UserType type,
  });

  Future<UserSession> login({
    required String email,
    required String password,
  });

  Future<void> logout();
}

class InMemoryAuthRepository implements AuthRepository {
  final Map<String, UserSession> _usersByEmail = {};
  final Map<String, String> _passwordsByEmail = {};

  @override
  Future<UserSession> register({
    required String name,
    required String email,
    required String password,
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
      type: type,
    );

    _usersByEmail[key] = session;
    _passwordsByEmail[key] = password;

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

    return _usersByEmail[key]!;
  }

  @override
  Future<void> logout() async {

  }
}
