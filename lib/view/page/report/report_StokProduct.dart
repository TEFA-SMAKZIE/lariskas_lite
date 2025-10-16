import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:kas_mini_flutter_app/model/product.dart';
import 'package:kas_mini_flutter_app/utils/colors.dart';
import 'package:kas_mini_flutter_app/utils/responsif/fsize.dart';
import 'package:kas_mini_flutter_app/view/widget/Notfound.dart';
import 'package:kas_mini_flutter_app/view/widget/floating_button.dart';
import 'package:kas_mini_flutter_app/view/widget/formatter/Rupiah.dart';
import 'package:kas_mini_flutter_app/view/widget/modals.dart';
import 'package:kas_mini_flutter_app/view/widget/refresWidget.dart';
import 'package:kas_mini_flutter_app/services/database_service.dart';
import 'package:sizer/sizer.dart';

class ReportStokproduct extends StatefulWidget {
  const ReportStokproduct({super.key});

  @override
  State<ReportStokproduct> createState() => _ReportStokproductState();
}

class _ReportStokproductState extends State<ReportStokproduct> {
  late Future<List<Product>> _DataallProduct;
  Map<String, int> _totalStockData = {
    'totalStock': 0,
    'totalNilaiStock': 0
  }; // Default value
  int finaltotalnilai = 0;
  @override
  void initState() {
    super.initState();
    _DataallProduct = DatabaseService.instance.getallProductsandSUM();
    fetchData();
  }

  void fetchData() async {
    final data = await DatabaseService.instance.getTotalStock();
    print('data: $data');
    setState(() {
      _totalStockData = data;
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
              Stack(
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
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          leading: BackButton(
                            color: Colors.white,
                          ),
                        ),
                        Center(
                          child: Text(
                        "LAPORAN STOK PRODUK",
                        style: GoogleFonts.poppins(
                            fontSize: SizeHelper.Fsize_title(context),
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      )),
                      Gap(15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: stockProductCard(
                          totalStock: _totalStockData['totalStock'],
                          totalNilaiStock: _totalStockData['totalNilaiStock'],
                        ),
                      ),
                      Gap(10),
                    ]
                    ),
                  )
                ],
              ),
              Expanded(
                child: FutureBuilder<List<Product>>(
                  future: _DataallProduct,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return CustomRefreshWidget(
                          child: Center(child: NotFoundPage()));
                    } else {
                      final products = snapshot.data!;

                      return Stack(
                        children: [
                          Column(
                            children: [
                              Expanded(
                                child: CustomRefreshWidget(
                                  child: ListView.builder(
                                    itemCount: products.length,
                                    itemBuilder: (context, index) {
                                      final product = products[index];
                                
                                      return Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: cardproductinreportstokproduck(
                                              namaProduk: product.productName,
                                              kategori: product.categoryName,
                                              stock: product.productStock,
                                              nilaiStock: product.productPurchasePrice *
                                                  product.productStock,
                                              image: product.productImage,
                                              hargamodal: product.productPurchasePrice,
                                              hargajual: product.productSellPrice,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
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
                onPressed: () {
                  CustomModals.modalExportStockProduct(context, products);
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
            ],
          ),
          
        ],
      ),
    );
  }
}

class cardproductinreportstokproduck extends StatelessWidget {
  final String? namaProduk;
  final String? kategori;
  final int? stock;
  final int? nilaiStock;
  final String? image;
  final int? hargamodal;
  final int? hargajual;
  const cardproductinreportstokproduck({
    super.key,
    this.namaProduk,
    this.kategori,
    this.stock,
    this.nilaiStock,
    this.image,
    this.hargamodal,
    this.hargajual,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: 20.h,
          width: double.infinity,
          margin: EdgeInsets.only(top: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    // Bagian kiri (Gambar)
                    Container(
                      height: 10.h,
                      width: 20.w,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: image == "assets/products/no-image.png"
                            ? Image.asset("assets/products/no-image.png")
                            : Image.file(
                                File('$image'),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    SizedBox(width: 10),
                    // Bagian kanan (Teks)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$namaProduk',
                            style: GoogleFonts.poppins(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Kategori : $kategori',
                            style: GoogleFonts.poppins(
                              fontSize: 15.sp,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Gap(5),
                          Container(
                            width: double.infinity,
                            height: 1,
                            color: primaryColor,
                          ),
                          Gap(5),
                          Text(
                            'Harga Jual : ${CurrencyFormat.convertToIdr(hargajual, 2)}',
                            style: GoogleFonts.poppins(
                              fontSize: 15.sp,
                            ),
                          ),
                          Text(
                            'Harga Modal : ${CurrencyFormat.convertToIdr(hargamodal, 2)}',
                            style: GoogleFonts.poppins(
                              fontSize: 15.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 5.h,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(15)),
                ),
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Stock : $stock',
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                            color: (stock ?? 0) < 1 ? Colors.red : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Nilai Stock : ${CurrencyFormat.convertToIdr(nilaiStock, 0)}',
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class stockProductCard extends StatelessWidget {
  final int? totalStock;
  final int? totalNilaiStock;
  const stockProductCard({
    super.key,
    this.totalStock,
    this.totalNilaiStock,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          flex: 8,
          child: Container(
            padding:
                EdgeInsets.all(SizeHelper.Size_headerStockProduct(context)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Total Stok',
                      style: GoogleFonts.poppins(
                          fontSize: SizeHelper.Fsize_mainTextCard(context),
                          color: Colors.black),
                    ),
                    SizedBox(height: 4),
                    Text(
                      (totalStock ?? 0).toString(),
                      style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Total Nilai Stok',
                      style: GoogleFonts.poppins(
                          fontSize: SizeHelper.Fsize_mainTextCard(context),
                          color: Colors.black),
                    ),
                    SizedBox(height: 4),
                    Text(
                      (CurrencyFormat.convertToIdr(totalNilaiStock, 2))
                          .toString(),
                      style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
