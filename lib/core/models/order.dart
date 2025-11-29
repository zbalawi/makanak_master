enum UserType { client, technician }

enum OrderStatus {
  waitingForOffer,        // العميل أنشأ الطلب، بانتظار عرض من فني
  waitingForClientConfirm,// الفني قدّم عرض، بانتظار موافقة العميل
  onTheWay,               // الفني في الطريق
  arrived,                // الفني وصل
  inProgress,             // قيد العمل
  completed,              // مكتمل
}

class Order {
  final String id;
  final String serviceType;
  final String description;
  final String clientName;
  String? technicianName;

  final double clientPrice;      // السعر اللي طلبه العميل
  double? technicianOfferPrice;  // السعر اللي اتفقوا عليه

  OrderStatus status;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.serviceType,
    required this.description,
    required this.clientName,
    this.technicianName,
    required this.clientPrice,
    this.technicianOfferPrice,
    this.status = OrderStatus.waitingForOffer,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}