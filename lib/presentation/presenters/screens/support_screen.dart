// presentation/screens/support_screen.dart
import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الدعم الفني'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'التواصل مع الدعم:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('📞 رقم الهاتف: 0599-000000'),
            Text('✉️ البريد الإلكتروني: support@makanak.com'),
            Text('💬 واتساب: 0599-000000'),
          ],
        ),
      ),
    );
  }
}
