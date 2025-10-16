import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:intl/intl.dart';
import 'package:kas_mini_flutter_app/model/report_sold_product.dart';
import 'package:kas_mini_flutter_app/model/transaction.dart';
import 'package:kas_mini_flutter_app/services/database_service.dart';
import 'package:kas_mini_flutter_app/utils/colors.dart';
import 'package:kas_mini_flutter_app/utils/responsif/fsize.dart';
import 'package:kas_mini_flutter_app/view/widget/Notfound.dart';
import 'package:kas_mini_flutter_app/view/widget/date_from_to/fromTo_v2.dart';
import 'package:kas_mini_flutter_app/view/widget/floating_button.dart';
import 'package:kas_mini_flutter_app/view/widget/modal_status.dart';
import 'package:kas_mini_flutter_app/view/widget/modals.dart';
import 'package:kas_mini_flutter_app/view/widget/refresWidget.dart';

class ReportProduct extends StatefulWidget {
  const ReportProduct({super.key});

  @override
  State<ReportProduct> createState() => _ReportProductState();
}

class _ReportProductState extends State<ReportProduct> {
  late Future<List<TransactionData>> Dateproductterjual;
  final DatabaseService _databaseService = DatabaseService.instance;

  Future<List<TransactionData>> _getTransactions() async {
    try {
      return await _databaseService.getTransaction();
    } catch (e) {
      print('Error fetching transactions: $e');
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    Dateproductterjual = DatabaseService.instance.getproductsell();
  }

  final TextEditingController _searchController = TextEditingController();

  List<TransactionData> _filterTransactions(
      List<TransactionData> transactions) {
    String query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      return transactions;
    } else {
      return transactions.where((transaction) {
        return transaction.transactionProduct.any((product) {
          return product['product_name'].toLowerCase().contains(query);
        });
      }).toList();
    }
  }

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
                      title: "LAPORAN PRODUK",
                      initialStartDate: fromDate,
                      bg: Colors.transparent,
                      initialEndDate: toDate,
                      onDateRangeChanged: (start, end) {
                        setState(() {
                          fromDate = start;
                          toDate = end;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const Gap(10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        obscureText: false,
                        controller: _searchController,
                        maxLines: null,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Cari Produk',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: SizeHelper.Fsize_mainTextCard(context),
                          ),
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(color: primaryColor),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {}); // Trigger rebuild saat user mengetik
                        },
                      ),
                    ),
                    const Gap(10),
                    InkWell(
                      onTap: () {
                        ModalStatusTransaksi.modalstaturstransaksi(context);
                      },
                      child: Container(
                        child: Row(
                          children: const [
                            Icon(Icons.filter_alt_outlined),
                            Text('Semua'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Gap(10),
              Expanded(
                child: CustomRefreshWidget(
                  child: FutureBuilder<List<TransactionData>>(
                    future: _getTransactions(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_outlined,
                                  size: 60, color: Colors.black),
                              Text('Tidak ada transaksi!',
                                  style: GoogleFonts.poppins(
                                      fontSize: 16, color: Colors.black)),
                            ],
                          ),
                        );
                      } else {
                        // Get the list of transactions
                        final transactions = snapshot.data!;

                        // Filter transactions based on the selected date range and search query
                        final filteredTransactions =
                            _filterTransactions(transactions)
                                .where((transaction) {
                          try {
                            String dateStr =
                                transaction.transactionDate.split(', ')[1];
                            DateTime transactionDate =
                                DateFormat("dd/MM/yyyy HH:mm")
                                    .parse(dateStr)
                                    .toLocal();
                            DateTime startDate = DateTime(fromDate.year,
                                    fromDate.month, fromDate.day, 0, 0, 0)
                                .toLocal();
                            DateTime endDate = DateTime(toDate.year,
                                    toDate.month, toDate.day, 23, 59, 59)
                                .toLocal();

                            return (transactionDate.isAfter(startDate) ||
                                    transactionDate
                                        .isAtSameMomentAs(startDate)) &&
                                (transactionDate.isBefore(endDate) ||
                                    transactionDate.isAtSameMomentAs(endDate));
                          } catch (e) {
                            print(
                                "Error parsing date: ${transaction.transactionDate}, Error: $e");
                            return false;
                          }
                        }).toList();

                        Map<String, int> productQuantity = {};

                        for (var transaction in filteredTransactions) {
                          for (var product in transaction.transactionProduct) {
                            if (productQuantity
                                .containsKey(product['product_name'])) {
                              productQuantity[product['product_name']] =
                                  productQuantity[product['product_name']]! +
                                      (product['quantity'] as int);
                            } else {
                              productQuantity[product['product_name']] =
                                  product['quantity'] ?? 0;
                            }
                          }
                        }

                        List<MapEntry<String, int>> sortedProductQuantity =
                            productQuantity.entries.toList()
                              ..sort((a, b) => b.value.compareTo(a.value));

                        List<ReportSoldProduct> reportSoldProducts =
                            sortedProductQuantity.map((entry) {
                          String productUnit = '';
                          String productImage = '';
                          int productId = 0;
                          String productCategory = '';
                          for (var transaction in filteredTransactions) {
                            for (var product
                                in transaction.transactionProduct) {
                              if (product['product_name'] == entry.key) {
                                productUnit = product['product_unit'] ?? 'pcs';
                                productImage = product['product_image'] ??
                                    'assets/products/no-image.png';
                                productId = product['product_id'] ?? 0;
                                productCategory =
                                    product['product_category'] ?? '';
                                break;
                              }
                            }
                            if (productUnit.isNotEmpty) break;
                          }
                          return ReportSoldProduct(
                            productId: productId,
                            productName: entry.key,
                            productUnit: productUnit,
                            productImage: productImage,
                            productSold: entry.value,
                            productCategory: productCategory,
                            dateRange: DateFormat('dd/MM/yyyy').format(fromDate) +
                                ' - ' +
                                DateFormat('dd/MM/yyyy').format(toDate),
                          );
                        }).toList();

                        if (filteredTransactions.isEmpty) {
                          return Center(
                              child: Column(   
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              NotFoundPage(
                                title: 'Tidak ada transaksi!',
                              ),
                            ],
                          ));
                        }
                        return Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 80),
                              child: Column(
                                children: [
                                  product_terlarisCard(
                                      context,
                                      sortedProductQuantity.first.key,
                                      sortedProductQuantity.first.value),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: reportSoldProducts.length,
                                      itemBuilder: (context, index) {
                                        final report = reportSoldProducts[index];
                                        return Column(children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: cardmain(
                                              product: report.productName,
                                              satuan: report.productUnit,
                                              image: report.productImage,
                                              total: report.productSold,
                                            ),
                                          ),
                                        ]);
                                      },
                                    ),
                                  ),
                                ],
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
                  CustomModals.modalExportSoldProduct(context, reportSoldProducts);
                },
              ),
            ),
          )
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          
        ],
      ),
    );
  }

  Container product_terlarisCard(
      BuildContext context, String productName, int quantity) {
    return Container(
      padding: EdgeInsets.all(SizeHelper.Size_headerStockProduct(context)),
      width: double.infinity,
      decoration: BoxDecoration(
        color: primaryColor,
        // borderRadius: BorderRadius.circular(0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                'Produk Terlaris:',
                style: GoogleFonts.poppins(
                  color: whiteMerona,
                  fontSize: SizeHelper.Fsize_textdate(context),
                ),
              ),
              Text(
                '${productName.length > 15 ? productName.substring(0, 10) : productName}',
                style: GoogleFonts.poppins(
                  color: whiteMerona,
                  fontWeight: FontWeight.bold,
                  fontSize: SizeHelper.Fsize_textdate(context),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              print(Dateproductterjual);
            },
            child: Column(
              children: [
                Text(
                  'Jumlah Terjual:',
                  style: GoogleFonts.poppins(
                    color: whiteMerona,
                    fontSize: SizeHelper.Fsize_textdate(context),
                  ),
                ),
                Text(
                  quantity.toString(),
                  style: GoogleFonts.poppins(
                    color: whiteMerona,
                    fontWeight: FontWeight.bold,
                    fontSize: SizeHelper.Fsize_textdate(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class cardmain extends StatelessWidget {
  final product;
  final satuan;
  final String image;
  final int total;

  const cardmain({
    super.key,
    required this.product,
    required this.satuan,
    required this.image,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(image),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/products/no-image.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: SizeHelper.Fsize_mainTextCard(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      satuan.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: SizeHelper.Fsize_mainTextCard(context),
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              total.toString(),
              style: GoogleFonts.poppins(
                fontSize: SizeHelper.Fsize_mainTextCard(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
