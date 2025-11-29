// presentation/presenters/client_home_presenter.dart
import '../../core/models/order.dart';
import '../../data/order_repository.dart';

class ClientHomePresenter {
  final OrderRepository _repo;

  ClientHomePresenter(this._repo);

  Future<List<Order>> loadClientOrders(String name) =>
      _repo.getClientOrders(name);

  Future<void> createOrder({
    required String clientName,
    required String serviceType,
    required String description,
    required double clientPrice,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final order = Order(
      id: id,
      serviceType: serviceType,
      description: description,
      clientName: clientName,
      clientPrice: clientPrice,
    );
    await _repo.createOrder(order);
  }

  Future<void> confirmOffer(String orderId) =>
      _repo.clientConfirmOffer(orderId: orderId);

  double calculateClientTotalSpent(String clientName, List<Order> orders) {
    double total = 0.0;
    for (final o in orders) {
      if (o.clientName == clientName &&
          o.status == OrderStatus.completed &&
          o.technicianOfferPrice != null) {
        total += o.technicianOfferPrice!;
      }
    }
    return total;
  }
}
