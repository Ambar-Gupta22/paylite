import 'package:flutter/material.dart';
import '../../features/pay/domain/payment.dart';
import '../utils/date_format.dart';
import '../utils/money.dart';

class PaymentTile extends StatelessWidget {
  final Payment payment;
  const PaymentTile({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final isSent = payment.direction == PaymentDirection.sent;
    final color = isSent ? Colors.black87 : Colors.green[700];
    final prefix = isSent ? '-' : '+';
    
    IconData statusIcon;
    Color statusColor;
    
    switch (payment.status) {
      case PaymentStatus.success:
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        break;
      case PaymentStatus.failed:
        statusIcon = Icons.cancel;
        statusColor = Colors.red;
        break;
      case PaymentStatus.pending:
        statusIcon = Icons.access_time;
        statusColor = Colors.orange;
        break;
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.grey[200],
        child: Icon(
          isSent ? Icons.arrow_outward : Icons.arrow_downward,
          color: isSent ? Colors.grey[700] : Colors.green,
        ),
      ),
      title: Text(
        payment.counterparty ?? 'Unknown',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Row(
        children: [
          Icon(statusIcon, size: 14, color: statusColor),
          const SizedBox(width: 4),
          Text(AppDateFormat.format(payment.createdAt)),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '$prefix ${MoneyFormatter.formatPaise(payment.amountPaise)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: payment.status == PaymentStatus.failed ? Colors.grey : color,
              decoration: payment.status == PaymentStatus.failed ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }
}
