import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kas_mini_flutter_app/model/transaction.dart';
import 'package:kas_mini_flutter_app/services/database_service.dart';
import 'package:kas_mini_flutter_app/utils/colors.dart';
import 'package:kas_mini_flutter_app/view/widget/card_report_transaction.dart';
import 'package:kas_mini_flutter_app/view/widget/date_from_to/fromTo_v2.dart';
import 'package:intl/intl.dart';
import 'package:kas_mini_flutter_app/view/widget/Notfound.dart';
import 'package:kas_mini_flutter_app/view/widget/refresWidget.dart';
import 'package:sizer/sizer.dart';

class ReportTransaction extends StatefulWidget {
  const ReportTransaction({super.key});

  @override
  _ReportTransactionState createState() => _ReportTransactionState();
}

class _ReportTransactionState extends State<ReportTransaction> {
  DateTime dateFrom = DateTime.now();
  DateTime dateTo = DateTime.now();
  bool test = false;
  final DatabaseService _databaseService = DatabaseService.instance;

  Future<List<TransactionData>> _getTransactions() async {
    try {
      return await _databaseService.getTransaction();
    } catch (e) {
      print('Error fetching transactions: $e');
      return [];
    }
  }

  int _calculateTotalProfit(List<TransactionData> transactions) {
    int totalProfit = 0;
    for (var transaction in transactions) {
      totalProfit += transaction
          .transactionProfit; // Assuming 'profit' is a field in TransactionData
    }
    return totalProfit;
  }

  int _calculateTotalOmzet(List<TransactionData> transactions) {
    int totalOmzet = 0;
    for (var transaction in transactions) {
      totalOmzet += transaction
          .transactionTotal; // Assuming 'omzet' is a field in TransactionData
    }
    return totalOmzet;
  }

  int _countTransactions(List<TransactionData> transactions) {
    return transactions.length;
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
                    colors: [ secondaryColor, primaryColor], // Warna gradient
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
                      initialStartDate: dateFrom,
                      initialEndDate: dateTo,
                      bg: Colors.transparent,
                      title: 'LAPORAN TRANSAKSI',
                      // bg: primaryColor,
                      onDateRangeChanged: (start, end) {
                        setState(() {
                          dateFrom = start;
                          dateTo = end;
                        });
                      },
                    ),
                  ],
                ),
              ),
              
              Expanded(
            child: FutureBuilder<List<TransactionData>>(
                      future: _getTransactions(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: CustomRefreshWidget(child: NotFoundPage()));
                        } else {
            // Filter transactions based on the selected date range
            final transactions = snapshot.data!.where((transaction) {
            try {
              String dateStr = transaction.transactionDate.split(', ')[1];
              DateTime transactionDate = DateFormat("dd/MM/yyyy HH:mm").parse(dateStr).toLocal();
              DateTime startDate = DateTime(dateFrom.year, dateFrom.month, dateFrom.day, 0, 0, 0).toLocal();
              DateTime endDate = DateTime(dateTo.year, dateTo.month, dateTo.day, 23, 59, 59).toLocal();

              // Cek apakah status transaksinya "Selesai" atau "Belum Lunas"
              bool statusValid = transaction.transactionStatus == "Selesai" || transaction.transactionStatus == "Belum Lunas";

              return statusValid &&
                (transactionDate.isAfter(startDate) || transactionDate.isAtSameMomentAs(startDate)) &&
                (transactionDate.isBefore(endDate) || transactionDate.isAtSameMomentAs(endDate));
            } catch (e) {
              print("Error parsing date: ${transaction.transactionDate}, Error: $e");
              return false;
            }
          }).toList();

            // Calculate total profit and count of transactions
            int totalProfit = _calculateTotalProfit(transactions);
            int totalCount = _countTransactions(transactions);
                      
            if (transactions.isEmpty) {
              return Center(child: 
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Gap(10),
                  NotFoundPage(
                    title: 'Tidak ada transaksi yang ditemukan',
                  ),
                ],
              )
              );
            }
            
            return Column(
              children: [
                Gap(10),
                Container(
                  width: double.infinity,
                  height: 10.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    // borderRadius: BorderRadius.circular(12),
                    color: primaryColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Jumlah Transaksi : $totalCount",
                                  style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                                Text("Total Omzet :  ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0).format(_calculateTotalOmzet(transactions))}",
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white)),
                              ],
                            ),
                            Text(
                              "Total Profit : ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0).format(totalProfit)}",
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: CustomRefreshWidget(
                    child: ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return Column(children: [
                          Gap(10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: CardReportTransactions(transaction: transaction),
                          ),
                        ]);
                      },
                    ),
                  ),
                ),
              ],
            );
            }
            },
            ),
          ),
            ],
          ),
        ],
      ),
    );
  }
}

