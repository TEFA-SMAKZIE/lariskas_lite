import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kas_mini_lite/model/transaction.dart';

class CardReportTransactions extends StatelessWidget {
  const CardReportTransactions({
    super.key,
    required this.transaction,
  });

  final TransactionData transaction;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(11.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID : #${transaction.transactionId} | ${transaction.transactionCustomerName} ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Status : ${transaction.transactionStatus}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Divider(
              thickness: 1,
              color: Colors.blue.shade900,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 16, color: Colors.blue.shade900),
                    SizedBox(width: 4),
                    Text(
                      transaction.transactionDate,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Text(
                  'Jumlah Pesanan : ${transaction.transactionQuantity}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Profit : ${NumberFormat.currency(symbol: 'Rp. ', decimalDigits: 0).format(transaction.transactionProfit)}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Total Harga : ${NumberFormat.currency(symbol: '', decimalDigits: 0).format(transaction.transactionTotal)}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
