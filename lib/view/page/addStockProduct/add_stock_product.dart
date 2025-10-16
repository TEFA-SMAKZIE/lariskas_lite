import 'dart:async'; // Import Timer
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kas_mini_flutter_app/model/stock_addition.dart';
import 'package:kas_mini_flutter_app/services/database_service.dart';
import 'package:kas_mini_flutter_app/utils/colors.dart';
import 'package:kas_mini_flutter_app/utils/responsif/fsize.dart';
import 'package:kas_mini_flutter_app/view/page/addStockProduct/select_and_add_stock.dart';
import 'package:kas_mini_flutter_app/view/widget/date_from_to/fromTo_v2.dart';
import 'package:kas_mini_flutter_app/view/widget/refresWidget.dart';
import 'package:kas_mini_flutter_app/view/widget/stock_addition_card.dart';

class AddStockProductPage extends StatefulWidget {
  const AddStockProductPage({super.key});

  @override
  State<AddStockProductPage> createState() => _AddStockProductPageState();
}

class _AddStockProductPageState extends State<AddStockProductPage> {
  DateTime dateFrom = DateTime.now();
  DateTime dateTo = DateTime.now();
  Future<List<StockAdditionData>> _stockAdditionList = Future.value([]);
  Timer? _timer; // Timer untuk refresh otomatis

  @override
  void initState() {
    super.initState();
    _loadStockAddition();
    // _startAutoRefresh(); // Mulai timer untuk refresh otomatis
  }

  @override
  void dispose() {
    _timer?.cancel(); // Hentikan timer saat widget dibuang
    super.dispose();
  }

  Future<void> _loadStockAddition() async {
    setState(() {
      _stockAdditionList = DatabaseService.instance.getStockAddition();
    });
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
                      title: "Penambahan Stok Produk",
                      initialStartDate: dateFrom,
                      initialEndDate: dateTo,
                      bg: Colors.transparent,
                      onDateRangeChanged: (startDate, endDate) {
                        setState(() {
                          dateFrom = startDate;
                          dateTo = endDate;
                        });
                        _loadStockAddition(); // Memuat ulang data saat rentang tanggal berubah
                      },
                    ),
                    Gap(8),
                  ],
                ),
              ),
              Expanded(
                child: CustomRefreshWidget(
                  onRefresh: _loadStockAddition,
                  child: FutureBuilder<List<StockAdditionData>>(
                    future: _stockAdditionList,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_outlined,
                                size: 50, color: Colors.black),
                            Text("Tidak ada data penambahan stok produk",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                )),
                          ],
                        ));
                      } else {
                        final DateFormat dateFormat = DateFormat("yyyy-MM-dd");
                        // Set dateFrom ke awal hari dan dateTo ke akhir hari
                        DateTime startDate = DateTime(dateFrom.year,
                            dateFrom.month, dateFrom.day, 0, 0, 0);
                        DateTime endDate = DateTime(
                            dateTo.year, dateTo.month, dateTo.day, 23, 59, 59);

                        final filteredStock = snapshot.data!.where((stock) {
                          try {
                            // Hapus nama hari sebelum parsing
                            String stockDateStr = stock
                                .stockAdditionDate; // Misalkan formatnya "yyyy-MM-dd"
                            final DateTime stockDate =
                                dateFormat.parse(stockDateStr);

                            // Pastikan stockDate berada dalam rentang tanggal yang benar
                            bool isWithinRange = (stockDate
                                        .isAfter(startDate) ||
                                    stockDate.isAtSameMomentAs(startDate)) &&
                                (stockDate.isBefore(endDate) ||
                                    stockDate.isAtSameMomentAs(endDate));

                            return isWithinRange;
                          } catch (e) {
                            debugPrint(
                                "Error parsing date: ${stock.stockAdditionDate} - $e");
                            return false; // Jika terjadi error, abaikan data ini
                          }
                        }).toList();

                        // Tambahkan log untuk memeriksa hasil filter
                        debugPrint(
                            "Filtered stock count: ${filteredStock.length}");

                        return filteredStock.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off_outlined,
                                      size: 50, color: Colors.black),
                                  Text("Tidak ada data dalam rentang tanggal!", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                ],
                              ))
                            : CustomRefreshWidget(
                                child: ListView.builder(
                                  itemCount: filteredStock.length,
                                  itemBuilder: (context, index) {
                                    final stock = filteredStock[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Column(children: [
                                        Gap(10),
                                        StockAdditionCard(stock: stock)
                                      ]),
                                    );
                                  },
                                ),
                              );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          Positioned(
      bottom: 15,
      left:  0,
      right:  0,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  // color: primaryColor
                  gradient: LinearGradient(
                      colors: const [primaryColor, secondaryColor],
                      begin: Alignment(0, 2),
                      end: Alignment(-0, -2)),
                ),
                child: 
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SelectAndAddStockProduct(),
                          ),
                        );
                      },
                      child: Text(
                        "TAMBAH STOK",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: SizeHelper.Fsize_expensiveFloatingButton(
                                context)
                      )
                    ),
              )),
            )
          ],
        ),
      ),
    )
        ],
      ),
      
    );
  }
}