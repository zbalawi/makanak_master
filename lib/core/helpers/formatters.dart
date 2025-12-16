import '../models/order.dart';

String statusToText(OrderStatus status) {
  switch (status) {
    case OrderStatus.waitingForOffer:
      return 'بانتظار عرض فني';
    case OrderStatus.waitingForClientConfirm:
      return 'بانتظار موافقة العميل';
    case OrderStatus.onTheWay:
      return 'الفني في الطريق';
    case OrderStatus.arrived:
      return 'الفني وصل';
    case OrderStatus.inProgress:
      return 'قيد العمل';
    case OrderStatus.completed:
      return 'مكتمل';
  }
}

String formatPrice(double value) {
  return value.toStringAsFixed(0);
}
