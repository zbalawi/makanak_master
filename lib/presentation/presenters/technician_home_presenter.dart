// presentation/presenters/technician_home_presenter.dart
import '../../core/models/order.dart';
import '../../data/order_repository.dart';

class TechnicianHomePresenter {
  final OrderRepository _repo;

  TechnicianHomePresenter(this._repo);

  Future<List<Order>> loadOpenOrders() =>
      _repo.getOpenOrdersForTechnicians();

  Future<List<Order>> loadTechnicianOrders(String techName) =>
      _repo.getTechnicianOrders(techName);

  Future<void> sendOffer({
    required String orderId,
    required String technicianName,
    required double offerPrice,
  }) =>
      _repo.setTechnicianOffer(
        orderId: orderId,
        technicianName: technicianName,
        offerPrice: offerPrice,
      );

  Future<void> updateStatus({
    required String orderId,
    required OrderStatus newStatus,
  }) =>
      _repo.updateOrderStatus(orderId: orderId, newStatus: newStatus);

  Map<String, double> calculateWallet(String techName, List<Order> orders) {
    double totalGross = 0.0;
    double companyShare = 0.0;
    const commission = 0.15;

    for (final o in orders) {
      if (o.technicianName == techName &&
          o.status == OrderStatus.completed &&
          o.technicianOfferPrice != null) {
        totalGross += o.technicianOfferPrice!;
      }
    }

    companyShare = totalGross * commission;
    final netForTech = totalGross - companyShare;

    return {
      'gross': totalGross,
      'company': companyShare,
      'net': netForTech,
    };
  }
}
