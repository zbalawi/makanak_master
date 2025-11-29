// presentation/screens/settings_screen.dart
import 'package:flutter/material.dart';
import '../../core/models/order.dart';
import 'support_screen.dart';

class SettingsScreen extends StatelessWidget {
  final String userName;
  final UserType userType;

  const SettingsScreen({
    super.key,
    required this.userName,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    final typeText =
    userType == UserType.client ? 'عميل' : 'فني';

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الاسم: $userName ($typeText)'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('التواصل مع الدعم الفني'),
              subtitle: const Text('في حال وجود أي مشكلة أو استفسار'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SupportScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
