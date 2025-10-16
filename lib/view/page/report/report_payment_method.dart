import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:intl/intl.dart';
import 'package:kas_mini_flutter_app/model/transaction.dart';
import 'package:kas_mini_flutter_app/services/database_service.dart';
import 'package:kas_mini_flutter_app/utils/colors.dart';
import 'package:kas_mini_flutter_app/utils/responsif/fsize.dart';
import 'package:kas_mini_flutter_app/view/widget/Notfound.dart';
import 'package:kas_mini_flutter_app/view/widget/date_from_to/fromTo_v2.dart';
import 'package:kas_mini_flutter_app/view/widget/floating_button.dart';
import 'package:kas_mini_flutter_app/view/widget/modals.dart';
import 'package:kas_mini_flutter_app/view/widget/formatter/Rupiah.dart';
import 'package:sizer/sizer.dart';

// ... (semua import tetap sama)

class ReportPaymentMethod extends StatefulWidget {
  const ReportPaymentMethod({super.key});

  @override
  State<ReportPaymentMethod> createState() => _ReportPaymentMethodState();
}

class _ReportPaymentMethodState extends State<ReportPaymentMethod> {
  DateTime dateFrom = DateTime.now();
  DateTime dateTo = DateTime.now();

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
                      title: 'LAPORAN METODE BAYAR',
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
                child: FutureBuilder(
                  future: Future.wait([
                    DatabaseService.instance.getTransaction(),
                    DatabaseService.instance.getPaymentMethods(),
                  ]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (!snapshot.hasData || snapshot.data![0].isEmpty) {
                      return NotFoundPage(
                        title: 'Tidak ada transaksi!',
                      );
                    } else {
                      final transactions =
                          (snapshot.data![0] as List<TransactionData>)
                              .where((transaction) {
                        try {
                          String dateStr =
                              transaction.transactionDate.split(', ')[1];
                          DateTime transactionDate =
                              DateFormat("dd/MM/yyyy HH:mm")
                                  .parse(dateStr)
                                  .toLocal();
                          DateTime startDate = DateTime(dateFrom.year,
                                  dateFrom.month, dateFrom.day, 0, 0, 0)
                              .toLocal();
                          DateTime endDate = DateTime(dateTo.year,
                                  dateTo.month, dateTo.day, 23, 59, 59)
                              .toLocal();

                          return (transactionDate.isAfter(startDate) ||
                                  transactionDate
                                      .isAtSameMomentAs(startDate)) &&
                              (transactionDate.isBefore(endDate) ||
                                  transactionDate
                                      .isAtSameMomentAs(endDate));
                        } catch (e) {
                          print(
                              "Error parsing date: ${transaction.transactionDate}, Error: $e");
                          return false;
                        }
                      }).toList();

                      final groupedTransactions = <String, int>{};
                      for (var transaction in transactions) {
                        final method = transaction.transactionPaymentMethod;
                        groupedTransactions[method] =
                            (groupedTransactions[method] ?? 0) +
                                transaction.transactionPayAmount.toInt();
                      }

                      //  Tambahan: kalau hasil akhir kosong, tampilkan NotFoundPage
                      if (groupedTransactions.isEmpty) {
                        return NotFoundPage(
                          title: 'Tidak ada transaksi !',
                        );
                      }

                      return Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: groupedTransactions.entries.map((entry) {
                                return Column(
                                  children: [
                                    MetodePembayaran(
                                      name: entry.key,
                                      total: entry.value,
                                    ),
                                    Gap(10),
                                  ],
                                );
                              }).toList(),
                            ),
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
                                  final paymentData =
                                      groupedTransactions.entries.map((entry) {
                                    return {
                                      'paymentMethod': entry.key,
                                      'totalAmount': entry.value,
                                      'paymentDateFrom':
                                          DateFormat("dd/MM/yyyy").format(dateFrom),
                                      'paymentDateTo':
                                          DateFormat("dd/MM/yyyy").format(dateTo),
                                    };
                                  }).toList();
                                  CustomModals.modalExportPaymentMethodData(
                                      context, paymentData);
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

class MetodePembayaran extends StatelessWidget {
  final String name;
  final int total;
  // final int id;
  const MetodePembayaran({
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
            padding: const EdgeInsets.only(left: 50, right: 10),
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
