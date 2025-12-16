import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../../../core/models/order.dart';
import '../state/order_provider.dart';
import '../widgets/order_cart.dart';
import '../widgets/wallet_card.dart';
import 'settings_screen.dart';

class TechnicianHomeScreen extends StatefulWidget {
  final String technicianName;

  const TechnicianHomeScreen({super.key, required this.technicianName});

  @override
  State<TechnicianHomeScreen> createState() => _TechnicianHomeScreenState();
}

class _TechnicianHomeScreenState extends State<TechnicianHomeScreen> {
  int _currentIndex = 0;
  bool _loadedOnce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadedOnce) {
      _loadedOnce = true;
      context.read<OrderProvider>().loadTechnicianData(widget.technicianName);
    }
  }

  // حسابات مالية بسيطة
  Map<String, double> _calcWallet(List<Order> myOrders) {
    double gross = 0;
    for (final o in myOrders) {
      if (o.status == OrderStatus.completed) {
        gross += (o.technicianOfferPrice ?? o.clientPrice);
      }
    }
    final company = gross * 0.15;
    final net = gross - company;

    return {'gross': gross, 'company': company, 'net': net};
  }

  Future<void> _sendOffer(Order order) async {
    final clientPrice = order.clientPrice;

    final option1 = clientPrice;
    final option2 = (clientPrice * 1.10).clamp(clientPrice, clientPrice * 1.25);
    final option3 = (clientPrice * 1.20).clamp(clientPrice, clientPrice * 1.25);

    final options = <double>[
      option1.toDouble(),
      option2.toDouble(),
      option3.toDouble(),
    ];

    final selected = await showModalBottomSheet<double>(
      context: context,
      builder: (_) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const ListTile(
                title: Text('اختر عرض السعر'),
                subtitle: Text('بحد أقصى 25% فوق سعر العميل'),
              ),
              for (final v in options)
                ListTile(
                  title: Text('عرض: ${v.toStringAsFixed(0)}'),
                  onTap: () => Navigator.pop(context, v),
                ),
            ],
          ),
        );
      },
    );

    if (selected == null) return;

    final orders = context.read<OrderProvider>();
    await orders.sendOffer(
      orderId: order.id,
      technicianName: widget.technicianName,
      offerPrice: selected,
    );

    await orders.loadTechnicianData(widget.technicianName);

    if (!mounted) return;

    if (orders.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(orders.error!)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال العرض ✔')),
      );
    }
  }

  OrderStatus? _nextStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.onTheWay:
        return OrderStatus.arrived;
      case OrderStatus.arrived:
        return OrderStatus.inProgress;
      case OrderStatus.inProgress:
        return OrderStatus.completed;
      default:
        return null;
    }
  }

  String _nextStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.onTheWay:
        return 'وصلت';
      case OrderStatus.arrived:
        return 'بدء العمل';
      case OrderStatus.inProgress:
        return 'إنهاء';
      default:
        return 'تحديث';
    }
  }

  Future<void> _advanceStatus(Order order) async {
    final next = _nextStatus(order.status);
    if (next == null) return;

    final orders = context.read<OrderProvider>();
    await orders.updateStatus(order.id, next);
    await orders.loadTechnicianData(widget.technicianName);

    if (!mounted) return;
    if (orders.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(orders.error!)),
      );
    }
  }

  Future<void> _onNavTap(int index) async {
    setState(() => _currentIndex = index);

    if (index == 2) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
      setState(() => _currentIndex = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>();
    final open = orders.openOrders;
    final mine = orders.techOrders;

    final wallet = _calcWallet(mine);

    final page = _currentIndex == 0
        ? _OpenOrdersView(
      loading: orders.loading,
      openOrders: open,
      onRefresh: () => context.read<OrderProvider>().loadTechnicianData(widget.technicianName),
      onSendOffer: _sendOffer,
    )
        : _MyOrdersView(
      loading: orders.loading,
      myOrders: mine,
      wallet: wallet,
      onRefresh: () => context.read<OrderProvider>().loadTechnicianData(widget.technicianName),
      onAdvanceStatus: _advanceStatus,
      nextStatusText: _nextStatusText,
    );

    return Scaffold(
      appBar: AppBar(title: Text('فني: ${widget.technicianName}')),
      body: page,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => _onNavTap(i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: 'طلبات متاحة'),
          BottomNavigationBarItem(icon: Icon(Icons.checklist), label: 'طلباتي'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'الإعدادات'),
        ],
      ),
    );
  }
}

class _OpenOrdersView extends StatelessWidget {
  final bool loading;
  final List<Order> openOrders;
  final Future<void> Function() onRefresh;
  final Future<void> Function(Order) onSendOffer;

  const _OpenOrdersView({
    required this.loading,
    required this.openOrders,
    required this.onRefresh,
    required this.onSendOffer,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView.builder(
          itemCount: openOrders.length,
          itemBuilder: (context, i) {
            final o = openOrders[i];
            return OrderCard(
              order: o,
              trailing: TextButton(
                onPressed: () => onSendOffer(o),
                child: const Text('قدّم عرض'),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MyOrdersView extends StatelessWidget {
  final bool loading;
  final List<Order> myOrders;
  final Map<String, double> wallet;
  final Future<void> Function() onRefresh;
  final Future<void> Function(Order) onAdvanceStatus;
  final String Function(OrderStatus) nextStatusText;

  const _MyOrdersView({
    required this.loading,
    required this.myOrders,
    required this.wallet,
    required this.onRefresh,
    required this.onAdvanceStatus,
    required this.nextStatusText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          WalletCard(
            title: 'الملخص المالي',
            rows: [
              MapEntry('إجمالي الإيراد', wallet['gross'] ?? 0),
              MapEntry('عمولة الشركة (15%)', wallet['company'] ?? 0),
              MapEntry('صافي الفني', wallet['net'] ?? 0),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView.builder(
                itemCount: myOrders.length,
                itemBuilder: (context, i) {
                  final o = myOrders[i];
                  final canAdvance = o.status == OrderStatus.onTheWay ||
                      o.status == OrderStatus.arrived ||
                      o.status == OrderStatus.inProgress;

                  return OrderCard(
                    order: o,
                    trailing: canAdvance
                        ? TextButton(
                      onPressed: () => onAdvanceStatus(o),
                      child: Text(nextStatusText(o.status)),
                    )
                        : null,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
