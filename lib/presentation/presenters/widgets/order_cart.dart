import 'package:flutter/material.dart';

import '../../../core/helpers/formatters.dart';
import '../../../core/models/order.dart';


class OrderCard extends StatelessWidget {
  final Order order;
  final Widget? trailing;
  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.order,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final clientPriceText = formatPrice(order.clientPrice);
    final techPriceText = order.technicianOfferPrice != null
        ? formatPrice(order.technicianOfferPrice!)
        : '-';

    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(order.serviceType),
        subtitle: Text(
          'سعر العميل: $clientPriceText\n'
              'سعر الفني: $techPriceText\n'
              'الحالة: ${statusToText(order.status)}',
        ),
        trailing: trailing,
      ),
    );
  }
}
