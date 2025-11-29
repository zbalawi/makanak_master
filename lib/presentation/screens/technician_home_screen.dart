// presentation/screens/technician_home_screen.dart
import 'package:flutter/material.dart';
import '../../core/models/order.dart';
import '../../core/helpers/formatters.dart';
import '../../core/di.dart';
import '../presenters/technician_home_presenter.dart';
import 'settings_screen.dart';

class TechnicianHomeScreen extends StatefulWidget {
  final String technicianName;

  const TechnicianHomeScreen({super.key, required this.technicianName});

  @override
  State<TechnicianHomeScreen> createState() => _TechnicianHomeScreenState();
}

class _TechnicianHomeScreenState extends State<TechnicianHomeScreen> {
  late final TechnicianHomePresenter _presenter;
  List<Order> _openOrders = [];
  List<Order> _myOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _presenter = TechnicianHomePresenter(orderRepository);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final open = await _presenter.loadOpenOrders();
    final mine = await _presenter.loadTechnicianOrders(widget.technicianName);
    setState(() {
      _openOrders = open;
      _myOrders = mine;
      _isLoading = false;
    });
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SizedBox.shrink()),
          (route) => false,
    );
    Navigator.pushReplacementNamed(context, '/');
  }

  void _goToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          userName: widget.technicianName,
          userType: UserType.technician,
        ),
      ),
    );
  }

  void _showOfferDialog(Order order) {
    final clientPrice = order.clientPrice;
    final double option1 = clientPrice;
    final double option2 =
    (clientPrice * 1.10).clamp(0.0, clientPrice * 1.25) as double;
    final double option3 =
    (clientPrice * 1.20).clamp(0.0, clientPrice * 1.25) as double;

    final options = <double>{
      option1,
      option2,
      option3,
    }.toList()
      ..sort();

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'سعر العميل: ${formatPrice(clientPrice)}',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text('اختر العرض المناسب:'),
              const SizedBox(height: 12),
              ...options.map((p) {
                return ListTile(
                  title: Text('عرض: ${formatPrice(p)}'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _presenter.sendOffer(
                      orderId: order.id,
                      technicianName: widget.technicianName,
                      offerPrice: p,
                    );
                    await _loadData();
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Future<void> _nextStatus(Order order) async {
    OrderStatus? next;
    switch (order.status) {
      case OrderStatus.onTheWay:
        next = OrderStatus.arrived;
        break;
      case OrderStatus.arrived:
        next = OrderStatus.inProgress;
        break;
      case OrderStatus.inProgress:
        next = OrderStatus.completed;
        break;
      default:
        next = null;
    }

    if (next != null) {
      await _presenter.updateStatus(
        orderId: order.id,
        newStatus: next,
      );
      await _loadData();
    }
  }

  String? _nextStatusButtonText(Order order) {
    switch (order.status) {
      case OrderStatus.onTheWay:
        return 'وصلت';
      case OrderStatus.arrived:
        return 'بدء العمل';
      case OrderStatus.inProgress:
        return 'إنهاء الطلب';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = _presenter.calculateWallet(
      widget.technicianName,
      _myOrders,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('الفني: ${widget.technicianName}'),
        actions: [
          IconButton(
            onPressed: _goToSettings,
            icon: const Icon(Icons.settings),
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
          onRefresh: _loadData,
          child: ListView(
            children: [
              Card(
                color: Colors.green.shade50,
                child: ListTile(
                  leading: const Icon(Icons.account_balance),
                  title: const Text('الملخص المالي'),
                  subtitle: Text(
                    'إجمالي الإيراد: ${formatPrice((wallet['gross'] ?? 0.0))}\n'
                        'نسبة الشركة (15%): ${formatPrice((wallet['company'] ?? 0.0))}\n'
                        'الصافي لك: ${formatPrice((wallet['net'] ?? 0.0))}\n'
                        'مطلوب تسديد نسبة الشركة أسبوعياً.',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'الطلبات المتاحة:',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_openOrders.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('ما في طلبات متاحة حالياً.'),
                )
              else
                ..._openOrders.map((o) {
                  return Card(
                    child: ListTile(
                      title: Text(o.serviceType),
                      subtitle: Text(
                        'عميل: ${o.clientName}\n'
                            'سعر العميل: ${formatPrice(o.clientPrice)}\n'
                            'الحالة: ${statusToText(o.status)}',
                      ),
                      trailing: TextButton(
                        onPressed: () => _showOfferDialog(o),
                        child: const Text('تقديم عرض'),
                      ),
                    ),
                  );
                }).toList(),
              const SizedBox(height: 12),
              const Text(
                'طلباتي:',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_myOrders.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('ما في طلبات مرتبطة فيك حالياً.'),
                )
              else
                ..._myOrders.map((o) {
                  final btnText = _nextStatusButtonText(o);
                  final price = o.technicianOfferPrice ??
                      o.clientPrice;

                  return Card(
                    child: ListTile(
                      title: Text(o.serviceType),
                      subtitle: Text(
                        'عميل: ${o.clientName}\n'
                            'السعر المتفق عليه: ${formatPrice(price)}\n'
                            'الحالة: ${statusToText(o.status)}',
                      ),
                      trailing: btnText != null
                          ? TextButton(
                        onPressed: () => _nextStatus(o),
                        child: Text(btnText),
                      )
                          : null,
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
