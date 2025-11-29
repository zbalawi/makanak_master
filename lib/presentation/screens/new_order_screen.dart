// presentation/screens/new_order_screen.dart
import 'package:flutter/material.dart';
import '../../core/di.dart';
import '../presenters/client_home_presenter.dart';

class NewOrderScreen extends StatefulWidget {
  final String clientName;

  const NewOrderScreen({super.key, required this.clientName});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  late final ClientHomePresenter _presenter;

  String _selectedService = 'صيانة تكييف';

  final List<String> _services = const [
    'صيانة تكييف',
    'صيانة كهرباء',
    'سباكة',
    'أجهزة منزلية',
    'تنظيف',
    'أخرى',
  ];

  @override
  void initState() {
    super.initState();
    _presenter = ClientHomePresenter(orderRepository);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;

    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اكتب سعر صحيح')),
      );
      return;
    }

    await _presenter.createOrder(
      clientName: widget.clientName,
      serviceType: _selectedService,
      description: _descriptionController.text.trim(),
      clientPrice: price,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إنشاء الطلب ✔')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلب خدمة جديدة'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedService,
                items: _services
                    .map(
                      (s) =>
                      DropdownMenuItem(value: s, child: Text(s)),
                )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedService = value);
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'نوع الخدمة',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'وصف المشكلة',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'اكتب وصف بسيط للمشكلة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'السعر المقترح (مثلاً 100)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'اكتب السعر';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('إرسال الطلب'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
