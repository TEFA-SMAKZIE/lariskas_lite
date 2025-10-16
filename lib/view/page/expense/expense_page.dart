import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:kas_mini_flutter_app/model/expense.dart';
import 'package:kas_mini_flutter_app/services/database_service.dart';
import 'package:kas_mini_flutter_app/utils/colors.dart';
import 'package:kas_mini_flutter_app/utils/search_utils.dart';
import 'package:kas_mini_flutter_app/view/page/expense/expense_detail.dart';
import 'package:kas_mini_flutter_app/view/page/expense/input_expense_page.dart';
import 'package:kas_mini_flutter_app/view/page/product/product.dart';
import 'package:kas_mini_flutter_app/view/widget/Notfound.dart';
import 'package:kas_mini_flutter_app/view/widget/date_from_to/fromTo_v2.dart';
import 'package:kas_mini_flutter_app/view/widget/floating_button.dart';
import 'package:kas_mini_flutter_app/view/widget/refresWidget.dart';
import 'package:kas_mini_flutter_app/view/widget/search.dart';
import 'package:kas_mini_flutter_app/view/widget/expense_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  final DatabaseService _databaseService = DatabaseService.instance;

  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  final TextEditingController _searchController = TextEditingController();

  void _filterSearch(String query) {
    setState(() {
      _futureExpense = fetchExpenses().then((expenses) {
        return filterItems(
            expenses, _searchController.text, (expense) => expense.expenseName);
      });
    });
  }

  late Future<List<Expense>> _futureExpense;

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _futureExpense = fetchExpenses();
      _fromDate = DateTime.now();
      _toDate = DateTime.now();
    });
  }

  Future<List<Expense>> fetchExpenses() async {
    final expenses = await _databaseService.getExpense();
    expenses.sort((a, b) => DateTime.parse(b.expenseDateAdded)
        .compareTo(DateTime.parse(a.expenseDateAdded)));
    return expenses;
  }

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _searchController.addListener(() {
      _filterSearch(_searchController.text);
    });
    _futureExpense = fetchExpenses();
  }

  //! SECURITY
  bool? _isAddExpenseOn;
  Future<void> _loadPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAddExpenseOn = prefs.getBool('tambahPengeluaran');
    });
  }

  Future<List<Expense>> fetchExpensesDate() async {
    final expenses = await _databaseService.getExpense();
    // Memfilter data pengeluaran berdasarkan tanggal
    return expenses.where((expense) {
      // Mengubah string tanggal pengeluaran menjadi objek DateTime
      final expenseDate = DateTime.parse(expense.expenseDate);
      // Memeriksa apakah tanggal pengeluaran berada dalam rentang tanggal yang ditentukan (_fromDate hingga _toDate)
      return (expenseDate.isAtSameMomentAs(_fromDate) ||
              expenseDate.isAfter(_fromDate)) &&
          (_toDate == null ||
              expenseDate.isAtSameMomentAs(_toDate!) ||
              expenseDate.isBefore(_toDate!.add(const Duration(days: 1))));
    }).toList();
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
                      title: 'DATA PENGELUARAN',
                      initialStartDate: _fromDate,
                      initialEndDate: _toDate,
                      bg: Colors.transparent,
                      onDateRangeChanged: (start, end) {
                        setState(() {
                          _futureExpense = fetchExpensesDate();
                          _fromDate = start;
                          _toDate = end;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const Gap(10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: SearchTextField(
                  prefixIcon: const Icon(Icons.search, size: 24),
                  obscureText: false,
                  hintText: "Search Data",
                  controller: _searchController,
                  maxLines: 1,
                  suffixIcon: null,
                  color: Colors.white,
                ),
              ),

              Expanded(
                child: FutureBuilder(
                  future: _futureExpense,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return CustomRefreshWidget(
                          child: Center(child: NotFoundPage()));
                    } else {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: CustomRefreshWidget(
                            onRefresh: _onRefresh,
                            child: ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                final expense = snapshot.data![index];

                                final formattedAmount =
                                    ProductPage.formatCurrency(
                                        expense.expenseAmount);
                                return ZoomTapAnimation(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => ExpenseDetailPage(
                                                  expense: expense,
                                                )));
                                  },
                                  child: Column(
                                    children: [
                                      if (index == 0) const Gap(5),
                                      ExpenseCard(
                                        title: expense.expenseName,
                                        date:
                                            DateTime.parse(expense.expenseDate)
                                                .toLocal()
                                                .toString()
                                                .split(' ')[0],
                                        amount: formattedAmount,
                                        dateAdded: expense.expenseDateAdded,
                                        note: expense.expenseNote,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),

              // Expanded(
              //   child: expenses.isEmpty
              //       ? Column(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: [
              //             const Icon(Icons.search_off,
              //                 color: primaryColor, size: 80),
              //             const SizedBox(height: 16),
              //             Text(
              //               'Tidak ada Produk di kategori ini !!',
              //               textAlign: TextAlign.center,
              //               style: GoogleFonts.poppins(
              //                 fontSize: 16,
              //                 fontWeight: FontWeight.w500,
              //                 color: primaryColor,
              //               ),
              //             ),
              //           ],
              //         )
              //       : ListView.builder(
              //           itemCount: expenses.length,
              //           itemBuilder: (context, index) {
              //             return ExpenseCard(
              //               title: expenses[index]["title"]!,
              //               date: expenses[index]["date"]!,
              //               amount: expenses[index]["amount"]!,
              //             );
              //           },
              //         ),
              // ),
            ],
          ),
          //! SECURITY
          if (_isAddExpenseOn != true)
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
                  text: 'Pengeluaran',
                  icon: MaterialSymbols.add,
                  onPressed: () async {
                    final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const InputExpensePage()));

                    if (result != null) {
                      setState(() {
                        _futureExpense = fetchExpenses();
                      });
                    }
                  },
                ),
              ),
            )
        ],
      ),
    );
  }
}
