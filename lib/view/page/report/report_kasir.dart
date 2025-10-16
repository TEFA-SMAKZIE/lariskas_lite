import 'package:flutter/material.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:intl/intl.dart';
import 'package:kas_mini_flutter_app/model/report_cashier.dart';
import 'package:kas_mini_flutter_app/model/transaction.dart';
import 'package:kas_mini_flutter_app/providers/cashierProvider.dart';
import 'package:kas_mini_flutter_app/services/database_service.dart';
import 'package:kas_mini_flutter_app/utils/colors.dart';
import 'package:kas_mini_flutter_app/view/widget/Notfound.dart';
import 'package:kas_mini_flutter_app/view/widget/date_from_to/fromTo_v2.dart';
import 'package:kas_mini_flutter_app/view/widget/floating_button.dart';
import 'package:kas_mini_flutter_app/view/widget/kasir.dart';
import 'package:kas_mini_flutter_app/view/widget/modals.dart';
import 'package:kas_mini_flutter_app/view/widget/refresWidget.dart';
import 'package:provider/provider.dart';

class ReportKasir extends StatefulWidget {
  const ReportKasir({super.key});

  @override
  State<ReportKasir> createState() => _ReportKasirState();
}

class _ReportKasirState extends State<ReportKasir> {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  Future<List<TransactionData>> fetchTransactions(String cashierName) async {
    try {
      return await DatabaseService.instance
          .getTransactionsByCashierAndStatus(cashierName);
    } catch (e) {
      print('Error fetching transactions: $e');
      return [];
    }
  }

  String? selectedCashier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          Column(
            children: [
                Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                  colors: [secondaryColor, primaryColor], // Warna gradient
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                  AppBar(
                    leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                  WidgetDateFromTo_v2(
                    title: 'LAPORAN KASIR',
                    initialStartDate: startDate,
                    initialEndDate: endDate,
                    bg: Colors.transparent,
                    onDateRangeChanged: (start, end) {
                    setState(() {
                      startDate = start;
                      endDate = end;
                    });
                    },
                  ),
                  ],
                ),
                ),
                Expanded(
                child: CustomRefreshWidget(
                  child: FutureBuilder<List<ReportCashierData>>(
                  future: Provider.of<CashierProvider>(context, listen: false)
                    .fetchCashiers()
                    .then((cashiers) async {
                    List<ReportCashierData> reportDataList = [];
                    for (var cashierName in cashiers) {
                    final transactions =
                      await fetchTransactions(cashierName);
                    final filteredTransactions = transactions.where((t) {
                      try {
                      String dateStr =
                        t.transactionDate.split(', ')[1];
                      DateTime transactionDate =
                        DateFormat("dd/MM/yyyy HH:mm")
                          .parse(dateStr)
                          .toLocal();
                      DateTime startDateLocal = DateTime(
                          startDate.year,
                          startDate.month,
                          startDate.day,
                          0,
                          0,
                          0)
                        .toLocal();
                      DateTime endDateLocal = DateTime(
                          endDate.year,
                          endDate.month,
                          endDate.day,
                          23,
                          59,
                          59)
                        .toLocal();

                      return (transactionDate.isAfter(startDateLocal) ||
                          transactionDate.isAtSameMomentAs(
                            startDateLocal)) &&
                        (transactionDate.isBefore(endDateLocal) ||
                          transactionDate.isAtSameMomentAs(
                            endDateLocal));
                      } catch (e) {
                      print(
                        "Error parsing date: ${t.transactionDate}, Error: $e");
                      return false;
                      }
                    }).toList();

                    if (filteredTransactions.isNotEmpty) {
                      final selesaiCount = filteredTransactions
                        .where((t) => t.transactionStatus == 'Selesai')
                        .length;
                      final prosesCount = filteredTransactions
                        .where((t) =>
                          t.transactionStatus == 'Belum Lunas')
                        .length;
                      final pendingCount = filteredTransactions
                        .where((t) =>
                          t.transactionStatus == 'Belum Dibayar')
                        .length;
                      final batalCount = filteredTransactions
                        .where((t) =>
                          t.transactionStatus == 'Dibatalkan')
                        .length;

                      reportDataList.add(ReportCashierData(
                      cashierId: 0,
                      cashierName: cashierName,
                      selesai: selesaiCount,
                      proses: prosesCount,
                      pending: pendingCount,
                      batal: batalCount,
                      cashierTotalTransactionMoney: filteredTransactions.fold(
                        0, (sum, t) => sum! + t.transactionTotal),
                      cashierTotalTransaction: filteredTransactions.length,
                      transactionProfit: filteredTransactions.fold(
                        0, (sum, t) => sum + t.transactionProfit),
                      ));
                    }
                    }
                    return reportDataList;
                  }),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return Center(child: NotFoundPage());
                    } else {
                    return ListView(
                      children: snapshot.data!
                        .map((data) => ReportCashierCard(
                          name: data.cashierName,
                          selesai: data.selesai ?? 0,
                          Blunas: data.proses ?? 0,
                          Bbayar: data.pending ?? 0,
                          batal: data.batal ?? 0,
                          totalPrice: data.cashierTotalTransactionMoney ?? 0,
                          total: data.cashierTotalTransaction ?? 0,
                          ))
                        .toList(),
                    );
                    }
                  },
                  ),
                ),
                )
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 150.0, end: 0.0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, value),
                  child: child,
                );
              },
              child: CustomButton(
                text: 'Export',
                icon: MaterialSymbols.file_copy,
                onPressed: () async {
                  final reportDataList = await Provider.of<CashierProvider>(context, listen: false)
                    .fetchCashiers()
                    .then((cashiers) async {
                  List<ReportCashierData> reportDataList = [];
                  for (var cashierName in cashiers) {
                    final transactions = await fetchTransactions(cashierName);
                    final filteredTransactions = transactions.where((t) {
                    try {
                      String dateStr = t.transactionDate.split(', ')[1];
                      DateTime transactionDate = DateFormat("dd/MM/yyyy HH:mm")
                        .parse(dateStr)
                        .toLocal();
                      DateTime startDateLocal = DateTime(
                          startDate.year, startDate.month, startDate.day, 0, 0, 0)
                        .toLocal();
                      DateTime endDateLocal = DateTime(
                          endDate.year, endDate.month, endDate.day, 23, 59, 59)
                        .toLocal();

                      return (transactionDate.isAfter(startDateLocal) ||
                          transactionDate.isAtSameMomentAs(startDateLocal)) &&
                        (transactionDate.isBefore(endDateLocal) ||
                          transactionDate.isAtSameMomentAs(endDateLocal));
                    } catch (e) {
                      print("Error parsing date: ${t.transactionDate}, Error: $e");
                      return false;
                    }
                    }).toList();

                    if (filteredTransactions.isNotEmpty) {
                    final selesaiCount = filteredTransactions
                      .where((t) => t.transactionStatus == 'Selesai')
                      .length;
                    final prosesCount = filteredTransactions
                      .where((t) => t.transactionStatus == 'Belum Lunas')
                      .length;
                    final pendingCount = filteredTransactions
                      .where((t) => t.transactionStatus == 'Belum Dibayar')
                      .length;
                    final batalCount = filteredTransactions
                      .where((t) => t.transactionStatus == 'Dibatalkan')
                      .length;

                    reportDataList.add(ReportCashierData(
                        cashierId: cashiers.indexOf(cashierName) + 1,
                      cashierName: cashierName,
                      selesai: selesaiCount,
                      proses: prosesCount,
                      pending: pendingCount,
                      batal: batalCount,
                      cashierTotalTransactionMoney: filteredTransactions.fold(
                      0, (sum, t) => sum! + t.transactionTotal),
                      cashierTotalTransaction: filteredTransactions.length,
                      transactionProfit: filteredTransactions.fold(
                      0, (sum, t) => sum + t.transactionProfit),
                      transactionDateRange: '${DateFormat("dd/MM/yyyy").format(startDate.toLocal())} - ${DateFormat("dd/MM/yyyy").format(endDate.toLocal())}',
                    ));
                    }
                  }
                  return reportDataList;
                  });

                  CustomModals.modalExportCashierDataExcel(context, reportDataList);
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
