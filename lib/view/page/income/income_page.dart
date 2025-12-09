import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:intl/intl.dart';
import 'package:kas_mini_lite/model/income.dart';
import 'package:kas_mini_lite/services/database_service.dart';
import 'package:kas_mini_lite/utils/colors.dart';
import 'package:kas_mini_lite/utils/search_utils.dart';
import 'package:kas_mini_lite/view/page/Income/Income_detail.dart';
import 'package:kas_mini_lite/view/page/income/input_expense_page.dart';
import 'package:kas_mini_lite/view/page/product/product.dart';
import 'package:kas_mini_lite/view/widget/Income_card.dart';
import 'package:kas_mini_lite/view/widget/Notfound.dart';
import 'package:kas_mini_lite/view/widget/date_from_to/fromTo_v2.dart';
import 'package:kas_mini_lite/view/widget/floating_button.dart';
import 'package:kas_mini_lite/view/widget/modals.dart';
import 'package:kas_mini_lite/view/widget/refresWidget.dart';
import 'package:kas_mini_lite/view/widget/search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class IncomePage extends StatefulWidget {
  const IncomePage({super.key});

  @override
  State<IncomePage> createState() => IncomePageState();
}

class IncomePageState extends State<IncomePage> {
  final DatabaseService _databaseService = DatabaseService.instance;

  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  final TextEditingController _searchController = TextEditingController();

  void _filterSearch(String query) {
    setState(() {
      _futureIncome = fetchIncomes().then((incomes) {
        return filterItems(
            incomes, _searchController.text, (income) => income.incomeName);
      });
    });
  }

  late Future<List<Income>> _futureIncome;

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _futureIncome = fetchIncomes();
      _fromDate = DateTime.now();
      _toDate = DateTime.now();
    });
  }

  Future<List<Income>> fetchIncomes() async {
    return await _databaseService.getIncome();
  }

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _searchController.addListener(() {
      _filterSearch(_searchController.text);
    });
    _futureIncome = fetchIncomes();
  }

  //! SECURITY
  bool? _isAddIncomeOn;
  Future<void> _loadPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAddIncomeOn = prefs.getBool('tambahPemasukan') ?? false;
    });
  }

  Future<List<Income>> fetchincomesDate() async {
    final incomes = await _databaseService.getIncome();
    // Memfilter data Pemasukan berdasarkan tanggal
    return incomes.where((income) {
      // Mengubah string tanggal Pemasukan menjadi objek DateTime
      final incomeDate = DateTime.parse(income.incomeDate);
      // Memeriksa apakah tanggal Pemasukan berada dalam rentang tanggal yang ditentukan (_fromDate hingga _toDate)
      return (incomeDate.isAtSameMomentAs(_fromDate) ||
              incomeDate.isAfter(_fromDate)) &&
          (_toDate == null ||
              incomeDate.isAtSameMomentAs(_toDate!) ||
              incomeDate.isBefore(_toDate!.add(const Duration(days: 1))));
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
                  child: Column(children: [
                    AppBar(
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                    WidgetDateFromTo_v2(
                      title: "DATA PEMASUKAN",
                      initialStartDate: _fromDate,
                      initialEndDate: _toDate,
                      bg: Colors.transparent,
                      onDateRangeChanged: (fromDate, toDate) {
                        setState(() {
                          _futureIncome = fetchincomesDate();
                          _fromDate = fromDate;
                          _toDate = toDate;
                        });
                      },
                    ),
                  ])),
              Gap(10),
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
                  future: _futureIncome,
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
                      // Filter transactions based on the selected date range
                      final incomes = snapshot.data!.where((income) {
                        try {
                          String dateStr = income.incomeDate;
                          DateTime incomeDate =
                              DateFormat("yyyy-MM-dd").parse(dateStr).toLocal();
                          DateTime startDate = DateTime(fromDate.year,
                                  fromDate.month, fromDate.day, 0, 0, 0)
                              .toLocal();
                          DateTime endDate = DateTime(toDate.year, toDate.month,
                                  toDate.day, 23, 59, 59)
                              .toLocal();

                          return (incomeDate.isAfter(startDate) ||
                                  incomeDate.isAtSameMomentAs(startDate)) &&
                              (incomeDate.isBefore(endDate) ||
                                  incomeDate.isAtSameMomentAs(endDate));
                        } catch (e) {
                          print(
                              "Error parsing date: ${income.incomeDate}, Error: $e");
                          return false;
                        }
                      }).toList();
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: CustomRefreshWidget(
                          onRefresh: _onRefresh,
                          child: ListView.builder(
                            itemCount: incomes.length,
                            itemBuilder: (context, index) {
                              final income = incomes[index];
                              final formattedAmount =
                                  ProductPage.formatCurrency(
                                      income.incomeAmount);
                              return ZoomTapAnimation(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => IncomeDetailPage(
                                                income: income,
                                              )));
                                },
                                child: Column(
                                  children: [
                                    if (index == 0) const Gap(5),
                                    IncomeCard(
                                      title: income.incomeName,
                                      date: DateTime.parse(income.incomeDate)
                                          .toLocal()
                                          .toString()
                                          .split(' ')[0],
                                      amount: formattedAmount,
                                      dateAdded: income.incomeDateAdded,
                                      note: income.incomeNote,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),

              // Expanded(
              //   child: incomes.isEmpty
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
              //           itemCount: incomes.length,
              //           itemBuilder: (context, index) {
              //             return incomeCard(
              //               title: incomes[index]["title"]!,
              //               date: incomes[index]["date"]!,
              //               amount: incomes[index]["amount"]!,
              //             );
              //           },
              //         ),
              // ),
            ],
          ),
          if (_isAddIncomeOn != true)
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
                  text: 'Pemasukan',
                  icon: MaterialSymbols.add,
                  onPressed: () async {
                    final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const InputIncomePage()));

                    if (result != null) {
                      setState(() {
                        _futureIncome = fetchIncomes();
                        _fromDate = DateTime.now();
                        _toDate = DateTime.now();
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
