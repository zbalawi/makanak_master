import 'package:flutter/foundation.dart';

import '../../../core/models/order.dart';
import '../../../data/order_repository.dart';


class OrderProvider extends ChangeNotifier {
  final OrderRepository _repo;

  OrderProvider(this._repo);

  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  List<Order> _clientOrders = [];
  List<Order> get clientOrders => _clientOrders;

  List<Order> _openOrders = [];
  List<Order> get openOrders => _openOrders;

  List<Order> _techOrders = [];
  List<Order> get techOrders => _techOrders;

  Future<void> loadClientOrders(String clientName) async {
    await _run(() async {
      _clientOrders = await _repo.getClientOrders(clientName);
    });
  }

  Future<void> loadTechnicianData(String technicianName) async {
    await _run(() async {
      _openOrders = await _repo.getOpenOrdersForTechnicians();
      _techOrders = await _repo.getTechnicianOrders(technicianName);
    });
  }

  Future<void> createOrder(Order order) async {
    await _run(() async {
      await _repo.createOrder(order);
    });
  }

  Future<void> sendOffer({
    required String orderId,
    required String technicianName,
    required double offerPrice,
  }) async {
    await _run(() async {
      await _repo.setTechnicianOffer(
        orderId: orderId,
        technicianName: technicianName,
        offerPrice: offerPrice,
      );
    });
  }

  Future<void> confirmOffer(String orderId) async {
    await _run(() async {
      await _repo.clientConfirmOffer(orderId: orderId);
    });
  }

  Future<void> updateStatus(String orderId, OrderStatus status) async {
    await _run(() async {
      await _repo.updateOrderStatus(orderId: orderId, newStatus: status);
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await action();
    } catch (_) {
      _error = 'حدث خطأ أثناء تنفيذ العملية';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
