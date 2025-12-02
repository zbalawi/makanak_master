import 'package:flutter/material.dart';
import '../../core/models/order.dart';
import '../../core/helpers/formatters.dart';
import '../../core/di.dart';
import '../presenters/client_home_presenter.dart';
import 'new_order_screen.dart';
import 'settings_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  final String clientName;

  const ClientHomeScreen({super.key, required this.clientName});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  late final ClientHomePresenter _presenter;
  List<Order> _orders = [];
  bool _isLoading = true;

  int _currentIndex = 0; // للـ BottomNavigationBar

  @override
  void initState() {
    super.initState();
    _presenter = ClientHomePresenter(orderRepository);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final result = await _presenter.loadClientOrders(widget.clientName);
    setState(() {
      _orders = result;
      _isLoading = false;
    });
  }

  Future<void> _confirmOffer(Order order) async {
    await _presenter.confirmOffer(order.id);
    await _loadData();
  }

  void _onNavTap(int index) async {
    if (index == 0) {
      setState(() => _currentIndex = 0);
    } else if (index == 1) {
      // طلب جديد
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NewOrderScreen(clientName: widget.clientName),
        ),
      );
      await _loadData();
      setState(() => _currentIndex = 0);
    } else if (index == 2) {
      // الإعدادات
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
        ),
      );
      setState(() => _currentIndex = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSpent =
    _presenter.calculateClientTotalSpent(widget.clientName, _orders);

    return Scaffold(
      appBar: AppBar(
        title: Text('أهلاً يا ${widget.clientName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.blue.shade50,
              child: ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: const Text('المحفظة'),
                subtitle: Text('إجمالي الصرف: ${formatPrice(totalSpent)}'),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'طلباتك:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _orders.isEmpty
                  ? const Center(
                child: Text('ما في طلبات حالياً. اعمل طلب جديد ✨'),
              )
                  : RefreshIndicator(
                onRefresh: _loadData,
                child: ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final o = _orders[index];
                    final priceText =
                        'سعر العميل: ${formatPrice(o.clientPrice)}'
                        '${o.technicianOfferPrice != null ? '\nسعر الفني: ${formatPrice(o.technicianOfferPrice!)}' : ''}';

                    final canConfirm = o.status ==
                        OrderStatus.waitingForClientConfirm;

                    return Card(
                      child: ListTile(
                        title: Text(o.serviceType),
                        subtitle: Text(
                          '$priceText\nالحالة: ${statusToText(o.status)}',
                        ),
                        trailing: canConfirm
                            ? TextButton(
                          onPressed: () => _confirmOffer(o),
                          child: const Text('موافقة'),
                        )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'طلباتي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'طلب جديد',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}
