import '../core/models/order.dart';

abstract class OrderRepository {
  Future<void> createOrder(Order order);

  Future<List<Order>> getClientOrders(String clientName);

  Future<List<Order>> getOpenOrdersForTechnicians();

  Future<List<Order>> getTechnicianOrders(String technicianName);

  Future<void> setTechnicianOffer({
    required String orderId,
    required String technicianName,
    required double offerPrice,
  });

  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
  });

  Future<void> clientConfirmOffer({
    required String orderId,
  });
}

class InMemoryOrderRepository implements OrderRepository {
  final List<Order> _orders = [];

  @override
  Future<void> createOrder(Order order) async {
    _orders.add(order);
  }

  @override
  Future<List<Order>> getClientOrders(String clientName) async {
    final result =
    _orders.where((o) => o.clientName == clientName).toList();
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  @override
  Future<List<Order>> getOpenOrdersForTechnicians() async {
    final result = _orders
        .where((o) => o.status == OrderStatus.waitingForOffer)
        .toList();
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  @override
  Future<List<Order>> getTechnicianOrders(String technicianName) async {
    final result = _orders
        .where((o) => o.technicianName == technicianName)
        .toList();
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  @override
  Future<void> setTechnicianOffer({
    required String orderId,
    required String technicianName,
    required double offerPrice,
  }) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index].technicianName = technicianName;
      _orders[index].technicianOfferPrice = offerPrice;
      _orders[index].status = OrderStatus.waitingForClientConfirm;
    }
  }

  @override
  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
  }) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index].status = newStatus;
    }
  }

  @override
  Future<void> clientConfirmOffer({
    required String orderId,
  }) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1 &&
        _orders[index].status == OrderStatus.waitingForClientConfirm) {
      _orders[index].status = OrderStatus.onTheWay;
    }
  }
}
