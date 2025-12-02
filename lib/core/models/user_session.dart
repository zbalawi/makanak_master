import 'order.dart';

class UserSession {
  final String uid;
  String name;
  String email;
  String phone;
  String address;
  final UserType type;

  UserSession({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'type': type.name,
    };
  }

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      uid: json['uid'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      type: (json['type'] as String) == 'technician'
          ? UserType.technician
          : UserType.client,
    );
  }
}
