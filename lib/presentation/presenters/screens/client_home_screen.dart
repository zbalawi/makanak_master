import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/order.dart';
import '../state/order_provider.dart';
import '../widgets/order_cart.dart';
import '../widgets/wallet_card.dart';
import 'new_order_screen.dart';
import 'settings_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  final String clientName;

  const ClientHomeScreen({super.key, required this.clientName});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _currentIndex = 0;
  bool _loadedOnce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadedOnce) {
      _loadedOnce = true;
      context.read<OrderProvider>().loadClientOrders(widget.clientName);
    }
  }

  double _totalSpent(List<Order> orders) {
    double sum = 0;
    for (final o in orders) {
      if (o.clientName == widget.clientName && o.status == OrderStatus.completed) {
        sum += (o.technicianOfferPrice ?? o.clientPrice);
      }
    }
    return sum;
  }

  Future<void> _confirmOffer(String orderId) async {
    final orders = context.read<OrderProvider>();
    await orders.confirmOffer(orderId);
    await orders.loadClientOrders(widget.clientName);
  }

  Future<void> _onNavTap(int index) async {
    if (index == 0) {
      setState(() => _currentIndex = 0);
      return;
    }

    if (index == 1) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NewOrderScreen(clientName: widget.clientName),
        ),
      );
      await context.read<OrderProvider>().loadClientOrders(widget.clientName);
      setState(() => _currentIndex = 0);
      return;
    }

    if (index == 2) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
      setState(() => _currentIndex = 0);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>();
    final list = orders.clientOrders;

    return Scaffold(
      appBar: AppBar(title: Text('عميل: ${widget.clientName}')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            WalletCard(
              title: 'المحفظة',
              rows: [
                MapEntry('إجمالي الصرف', _totalSpent(list)),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: orders.loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                onRefresh: () => context.read<OrderProvider>().loadClientOrders(widget.clientName),
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final o = list[i];
                    final canConfirm = o.status == OrderStatus.waitingForClientConfirm;

                    return OrderCard(
                      order: o,
                      trailing: canConfirm
                          ? TextButton(
                        onPressed: () => _confirmOffer(o.id),
                        child: const Text('موافقة'),
                      )
                          : null,
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
        onTap: (i) => _onNavTap(i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'طلباتي'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'طلب جديد'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'الإعدادات'),
        ],
      ),
    );
  }
}
