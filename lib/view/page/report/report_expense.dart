import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:intl/intl.dart';
import 'package:kas_mini_lite/model/expenceModel.dart';
import 'package:kas_mini_lite/services/database_service.dart';
import 'package:kas_mini_lite/utils/colors.dart';
import 'package:kas_mini_lite/view/widget/Notfound.dart';
import 'package:kas_mini_lite/view/widget/date_from_to/fromTo_v2.dart';
import 'package:kas_mini_lite/view/widget/floating_button.dart';
import 'package:kas_mini_lite/view/widget/formatter/Rupiah.dart';
import 'package:kas_mini_lite/view/widget/modals.dart';
import 'package:kas_mini_lite/view/widget/refresWidget.dart';
import 'package:sizer/sizer.dart';

class ReportExpense extends StatefulWidget {
  const ReportExpense({super.key});

  @override
  State<ReportExpense> createState() => _ReportExpenseState();
}

class _ReportExpenseState extends State<ReportExpense> {
  DatabaseService db = DatabaseService.instance;
  DateTime dateFrom = DateTime.now();
  DateTime dateTo = DateTime.now();

  @override
  void initState() {
    super.initState();
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
                      title: "LAPORAN PENGELUARAN",
                      initialStartDate: dateFrom,
                      initialEndDate: dateTo,
                      bg: Colors.transparent,
                      onDateRangeChanged: (startDate, endDate) {
                        setState(() {
                          dateFrom = startDate;
                          dateTo = endDate;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Expensemodel>>(
                  future: db.getExpenseList(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: NotFoundPage(
                          title: 'Tidak ada Pengeluaran yang ditemukan',
                        ),
                      );
                    } else {
                      final filteredExpenses = snapshot.data!.where((expense) {
                        try {
                          String dateStr = expense.date.toString();
                          DateTime expenseDate =
                              DateFormat("yyyy-MM-dd").parse(dateStr).toLocal();
                          DateTime startDate = DateTime(dateFrom.year,
                                  dateFrom.month, dateFrom.day, 0, 0, 0)
                              .toLocal();
                          DateTime endDate = DateTime(dateTo.year, dateTo.month,
                                  dateTo.day, 23, 59, 59)
                              .toLocal();

                          return (expenseDate.isAfter(startDate) ||
                                  expenseDate.isAtSameMomentAs(startDate)) &&
                              (expenseDate.isBefore(endDate) ||
                                  expenseDate.isAtSameMomentAs(endDate));
                        } catch (e) {
                          print(
                              "Error parsing date: ${expense.date}, Error: $e");
                          return false;
                        }
                      }).toList();

                      int totalExpense = filteredExpenses.fold(
                          0, (sum, expense) => sum + (expense.amount ?? 0));

                      if (filteredExpenses.isEmpty) {
                        return Center(child: NotFoundPage(
                          title: "Tidak ada pengeluaran!",
                        ));
                      }

                      return Column(
                        children: [
                          Gap(10),
                          Expanded(
                            child: CustomRefreshWidget(
                              child: ListView.builder(
                                itemCount: filteredExpenses.length,
                                itemBuilder: (context, index) {
                                  final expense = filteredExpenses[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    child: Column(
                                      children: [
                                        cardpengeluaran(
                                          title: expense.name.toString(),
                                          date: expense.date.toString(),
                                          amount: expense.amount!,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 65,
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
                                  CustomModals.modalExportExpenseData(context, filteredExpenses);
                                },
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: GestureDetector(
                              onTap: () {},
                              child: Container(
                                width: double.infinity,
                                color: primaryColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Total Pengeluaran:",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 50),
                                    Text(
                                      CurrencyFormat.convertToIdr(
                                          totalExpense, 0),
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
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

class cardpengeluaran extends StatelessWidget {
  final String title;
  final int amount;
  final String date;
  const cardpengeluaran({
    required this.title,
    required this.amount,
    required this.date,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade500, width: 1),
            ),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title),
                  SizedBox(
                    width: 100,
                    child: Divider(
                      color: primaryColor,
                      height: 1,
                    ),
                  ),
                  Text(date.substring(0, 10)),
                ],
              ),
              Spacer(),
              Text(CurrencyFormat.convertToIdr(amount, 0)),
            ],
          ),
        ),
      ],
    );
  }
}
