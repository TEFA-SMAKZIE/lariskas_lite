import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kas_mini_lite/model/transaction.dart';
import 'package:kas_mini_lite/services/database_service.dart';
import 'package:kas_mini_lite/view/widget/formatter/Rupiah.dart';

class RiwayatTransaksi_list extends StatefulWidget {
const RiwayatTransaksi_list({super.key});

@override
State<RiwayatTransaksi_list> createState() => _RiwayatTransaksi_listState();
}

class _RiwayatTransaksi_listState extends State<RiwayatTransaksi_list> {
  DatabaseService db = DatabaseService.instance;
  List<TransactionData> transactionData = [];
  @override
  void initState() {
    super.initState();
    getTransaction();

  }
  void getTransaction() async {
    List<TransactionData> data = await db.getTransaction();
    setState(() {
        transactionData = data;
  });
}

@override
Widget build(BuildContext context) {
return ListView.builder(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemCount: transactionData.length,
    itemBuilder: (context, index) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
        children: [
            Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                    'Antrian' + transactionData[index].transactionQueueNumber.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ],
            ),
            ),
            Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
                Text(
                CurrencyFormat.convertToIdr(transactionData[index].transactionTotal, 2),
                style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                transactionData[index].transactionDate.toString(),
                style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
            ],
            ),
        ],
        ),
    );
    },
);
}
}
