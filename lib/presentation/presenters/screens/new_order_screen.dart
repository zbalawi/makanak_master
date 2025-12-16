import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/order.dart';
import '../state/order_provider.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_primary_button.dart';

class NewOrderScreen extends StatefulWidget {
  final String clientName;

  const NewOrderScreen({super.key, required this.clientName});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  final _formKey = GlobalKey<FormState>();

  final _descController = TextEditingController();
  final _priceController = TextEditingController();

  String _serviceType = 'تكييف';

  @override
  void dispose() {
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;

    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('السعر غير صالح')),
      );
      return;
    }

    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      serviceType: _serviceType,
      description: _descController.text.trim(),
      clientName: widget.clientName,
      technicianName: null,
      clientPrice: price,
      technicianOfferPrice: null,
      status: OrderStatus.waitingForOffer,
      createdAt: DateTime.now(),
    );

    final orders = context.read<OrderProvider>();
    await orders.createOrder(order);

    if (!mounted) return;

    if (orders.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(orders.error!)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إنشاء الطلب بنجاح ✔')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('طلب جديد')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _serviceType,
                  decoration: const InputDecoration(
                    labelText: 'نوع الخدمة',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'تكييف', child: Text('تكييف')),
                    DropdownMenuItem(value: 'سباكة', child: Text('سباكة')),
                    DropdownMenuItem(value: 'كهرباء', child: Text('كهرباء')),
                    DropdownMenuItem(value: 'نجارة', child: Text('نجارة')),
                  ],
                  onChanged: (v) => setState(() => _serviceType = v ?? 'تكييف'),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _descController,
                  label: 'وصف المشكلة',
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return 'اكتب وصف المشكلة';
                    if (value.length < 10) return 'الوصف قصير جداً';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _priceController,
                  label: 'السعر المقترح',
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return 'اكتب السعر';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                AppPrimaryButton(
                  text: 'إرسال الطلب',
                  loading: orders.loading,
                  onPressed: orders.loading ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
