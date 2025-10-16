import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kas_mini_flutter_app/services/database_service.dart';
import 'package:kas_mini_flutter_app/utils/colors.dart';
import 'package:kas_mini_flutter_app/utils/responsif/fsize.dart';
import 'package:kas_mini_flutter_app/view/widget/Notfound.dart';
import 'package:kas_mini_flutter_app/view/widget/refresWidget.dart';
import 'package:kas_mini_flutter_app/view/widget/date_from_to/fromTo_v2.dart';
import 'package:sizer/sizer.dart';

class ReportCategory extends StatefulWidget {
  const ReportCategory({super.key});

  @override
  State<ReportCategory> createState() => _ReportCategoryState();
}

class _ReportCategoryState extends State<ReportCategory> {
  DateTime dateFrom = DateTime.now();
  DateTime dateTo = DateTime.now();
  late Future<List<Map<String, dynamic>>> categoryData;

  @override
  void initState() {
    super.initState();
    categoryData = DatabaseService.instance.getCategoryNameAndCount();
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
                      initialStartDate: dateFrom,
                      initialEndDate: dateTo,
                      bg: Colors.transparent,
                      title: 'LAPORAN KATEGORI',
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
                      future: categoryData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text("Error: ${snapshot.error}"));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                              child:
                                  CustomRefreshWidget(child: NotFoundPage()));
                        } else {
                          final products = snapshot.data!;
                          return CustomRefreshWidget(
                            child: ListView.builder(
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                final product = products[index];
                                return Column(
                                  children: [
                                    Gap(5),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: LaporanKategoriWidget(
                                        categoryName: product['categoryName'],
                                        count: product['count'],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          );
                        }
                      }))
            ],
          ),
        ],
      ),
    );
  }
}

class LaporanKategoriWidget extends StatelessWidget {
  final String categoryName;
  final int count;
  const LaporanKategoriWidget({
    super.key,
    required this.categoryName,
    required this.count,
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
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    categoryName,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: SizeHelper.Fsize_mainTextCard(context)),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.only(right: 15),
                  child: Text(
                    count.toString(),
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: SizeHelper.Fsize_mainTextCard(context)),
                  ),
                )
              ],
            ),
          ),
        ),
        Container(
          height: 7.h,
          width: 5.w,
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
