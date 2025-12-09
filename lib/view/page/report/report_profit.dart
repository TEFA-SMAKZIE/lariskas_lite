import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:intl/intl.dart';
import 'package:kas_mini_lite/model/expenceModel.dart';
import 'package:kas_mini_lite/model/transaction.dart';
import 'package:kas_mini_lite/services/database_service.dart';
import 'package:kas_mini_lite/utils/colors.dart';
import 'package:kas_mini_lite/utils/responsif/fsize.dart';
import 'package:kas_mini_lite/view/widget/Notfound.dart';
import 'package:kas_mini_lite/view/widget/date_from_to/fromTo_v2.dart';
import 'package:kas_mini_lite/view/widget/floating_button.dart';
import 'package:kas_mini_lite/view/widget/formatter/Rupiah.dart';
import 'package:kas_mini_lite/view/widget/modals.dart';
import 'package:kas_mini_lite/view/widget/refresWidget.dart';
import 'package:sizer/sizer.dart';

// ... (semua import tetap sama)

class ReportProfit extends StatefulWidget {
  const ReportProfit({super.key});

  @override
  State<ReportProfit> createState() => _ReportProfitState();
}

class _ReportProfitState extends State<ReportProfit> {
  DateTime dateFrom = DateTime.now();
  DateTime dateTo = DateTime.now();

  Future<List<TransactionData>> _getTransactions() async {
    try {
      return await DatabaseService.instance.getTransaction();
    } catch (e) {
      print('Error fetching transactions: $e');
      return [];
    }
  }

  Future<List<Expensemodel>> _getExpenseList() async {
    try {
      return await DatabaseService.instance.getExpenseList();
    } catch (e) {
      print('Error fetching expense list: $e');
      return [];
    }
  }

  int _calculateTotalOmzet(List<TransactionData> transactions) {
    int totalOmzet = 0;
    for (var transaction in transactions) {
      totalOmzet += transaction
          .transactionProfit; // Assuming 'omzet' is a field in TransactionData
    }
    return totalOmzet;
  }

  int _calculateTotalProductPurchasePrice(List<TransactionData> transactions) {
    int totalModalProduct = 0;
    for (var transaction in transactions) {
      // transactionProduct diasumsikan List<Map<String, dynamic>>
      for (var product in transaction.transactionProduct) {
        if (product.containsKey('product_purchase_price') && product.containsKey('quantity')) {
          int purchasePrice = int.tryParse(product['product_purchase_price'].toString()) ?? 0;
          int quantity = int.tryParse(product['quantity'].toString()) ?? 0;
          totalModalProduct += purchasePrice * quantity;
        }
      }
    }
    return totalModalProduct;
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
                    colors: [secondaryColor, primaryColor],
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
                      title: 'LAPORAN PROFIT',
                      initialStartDate: dateFrom,
                      initialEndDate: dateTo,
                      bg: Colors.transparent,
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
                  builder: (context, transactionSnapshot) {
                  if (transactionSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (transactionSnapshot.hasError) {
                    return Center(child: Text('Error: ${transactionSnapshot.error}'));
                  } else if (!transactionSnapshot.hasData || transactionSnapshot.data!.isEmpty) {
                    return Center(child: CustomRefreshWidget(child: NotFoundPage()));
                  } else {
                    // Filter transactions based on the selected date range
                    final transactions = transactionSnapshot.data!.where((transaction) {
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

                    int totalOmzet = _calculateTotalOmzet(transactions);
                    int totalModalProduct = _calculateTotalProductPurchasePrice(transactions);

                    return FutureBuilder<List<Expensemodel>>(
                    future: _getExpenseList(),
                    builder: (context, expenseSnapshot) {
                      if (expenseSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                      } else if (expenseSnapshot.hasError) {
                      return Center(child: Text('Error: ${expenseSnapshot.error}'));
                      } else if (!expenseSnapshot.hasData) {
                      return Center(child: CustomRefreshWidget(child: NotFoundPage()));
                      } else {
                      // Filter expenses based on the selected date range
                      final expenses = expenseSnapshot.data!.where((expense) {
                        try {
                        DateTime expenseDate = DateFormat("yyyy-MM-dd").parse(expense.date!).toLocal();
                        DateTime startDate = DateTime(dateFrom.year, dateFrom.month, dateFrom.day, 0, 0, 0).toLocal();
                        DateTime endDate = DateTime(dateTo.year, dateTo.month, dateTo.day, 23, 59, 59).toLocal();
                        return (expenseDate.isAfter(startDate) || expenseDate.isAtSameMomentAs(startDate)) &&
                          (expenseDate.isBefore(endDate) || expenseDate.isAtSameMomentAs(endDate));
                        } catch (e) {
                        print("Error parsing expense date: ${expense.date}, Error: $e");
                        return false;
                        }
                      }).toList();

                      int totalExpense = expenses.fold(0, (sum, expense) => sum + expense.amount!);

                      if (transactions.isEmpty && expenses.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                            NotFoundPage(
                              title: 'Tidak ada transaksi atau pengeluaran yang ditemukan',
                            ),
                              // Gap(10),
                              // ReportProfitCard(name: "OMZET", total: 0),
                              // Gap(10),
                              // ReportProfitCard(name: "MODAL PRODUK", total: 0),
                              // Gap(10),
                              // ReportProfitCard(name: "TOTAL PENGELUARAN", total: 0),
                              // Gap(10),
                              // ReportProfitCard(name: "PROFIT KOTOR", total: 0),
                              // Gap(10),
                              // ReportProfitCard(name: "PROFIT BERSIH", total: 0),
                              // Gap(10),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: [
                        Expanded(
                          child: CustomRefreshWidget(
                          child: ListView(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            children: [
                            Gap(10),
                            ReportProfitCard(name: "Omzet", total: totalOmzet),
                            Gap(10),
                            ReportProfitCard(name: "Modal Produk", total: totalModalProduct),
                            Gap(10),
                            ReportProfitCard(name: "Profit Kotor", total: totalOmzet - totalModalProduct),
                            Gap(10),
                            ReportProfitCard(name: "Total Pengeluaran", total: totalExpense),
                            Gap(10),
                            ReportProfitCard(name: "Profit Bersih", total: totalOmzet - totalModalProduct - totalExpense),
                            Gap(10),
                            ],
                          ),
                          ),
                        ),
                        ],
                      );
                      }
                    },
                  );
                  }
                  },
                ),
                ),
        ]
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
                onPressed: () {
                  CustomModals.modalexportexel(context);
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ReportProfitCard extends StatelessWidget {
  final String name;
  final int total;
  // final int id;
  const ReportProfitCard({
    super.key,
    required this.name,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 7.h,
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.only(left: 40, right: 20),
            child: Row(
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: SizeHelper.Fsize_mainTextCard(context)),
                ),
                const Spacer(),
                Text(
                  CurrencyFormat.convertToIdr(total, 0),
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: SizeHelper.Fsize_mainTextCard(context)),
                )
              ],
            ),
          ),
        ),
        Container(
          height: 7.h,
          width: 6.w,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  topLeft: Radius.circular(15)),
              color: primaryColor),
        )
      ],
    );
  }
}
