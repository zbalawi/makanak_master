import 'package:flutter/material.dart';
import '../../../core/models/order.dart';
import 'client_home_screen.dart';
import 'technician_home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  UserType _selectedType = UserType.client;

  void _continue() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اكتب اسمك')),
      );
      return;
    }

    if (_selectedType == UserType.client) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ClientHomeScreen(clientName: name),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TechnicianHomeScreen(technicianName: name),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Makanak - تسجيل الدخول'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'أهلاً في Makanak 👋',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'اسمك',
                border: OutlineInputBorder(),
              ),
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
                    if (value != null) {
                      setState(() => _selectedType = value);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _continue,
                child: const Text('دخول'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
