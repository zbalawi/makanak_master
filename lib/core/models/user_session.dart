import 'order.dart';

class UserSession {
  final String uid;
  final String name;
  final String email;
  final UserType type;

  UserSession({
    required this.uid,
    required this.name,
    required this.email,
    required this.type,
  });
}
