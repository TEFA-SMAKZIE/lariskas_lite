import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kas_mini_lite/providers/securityProvider.dart';
import 'package:kas_mini_lite/utils/colors.dart';
import 'package:kas_mini_lite/utils/responsif/fsize.dart';
import 'package:kas_mini_lite/view/page/report/report_StokProduct.dart';
import 'package:kas_mini_lite/view/page/report/report_category.dart';
import 'package:kas_mini_lite/view/page/report/report_expense.dart';
import 'package:kas_mini_lite/view/page/report/report_kasir.dart';
import 'package:kas_mini_lite/view/page/report/report_payment_method.dart';
import 'package:kas_mini_lite/view/page/report/report_product.dart';
import 'package:kas_mini_lite/view/page/report/report_profit.dart';
import 'package:kas_mini_lite/view/page/report/report_transaction.dart';
import 'package:kas_mini_lite/view/widget/back_button.dart';
import 'package:kas_mini_lite/view/widget/menu_card.dart';
import 'package:kas_mini_lite/view/widget/modals.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  @override
  Widget build(BuildContext context) {
    var securityProvider = Provider.of<SecurityProvider>(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: const CustomBackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'LAPORAN',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: SizeHelper.Fsize_normalTitle(context),
            color: primaryColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(2.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                "Laporan Transaksi",
                [
                  _buildMainCard(
                    title: "Transaksi",
                    imagePath: 'assets/images/report_transaction.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReportTransaction(),
                        ),
                      );
                    },
                  ),
                  const Gap(20),
                  _buildMainCard(
                    title: "Produk Terjual",
                    imagePath: 'assets/images/report_selling_product.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReportProduct(),
                        ),
                      );
                    },
                  ),
                  // _buildMainCard(
                  //   title: "Stok Produk",
                  //   imagePath: 'assets/images/report_stock_product.png',
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (_) => const ReportStokproduct(),
                  //       ),
                  //     );
                  //   },
                  // ),
                  _buildMainCard(
                    title: "Kategori",
                    imagePath: 'assets/images/report_category.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReportCategory(),
                        ),
                      );
                    },
                  ),
                  _buildMainCard(
                    title: "Pengeluaran",
                    imagePath: 'assets/images/report_expense.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReportExpense(),
                        ),
                      );
                    },
                  ),
                  _buildMainCard(
                    title: "Export Data Excel",
                    imagePath: 'assets/images/report_export.png',
                    onTap: ()
                    {
                      CustomModals.modalExportExcelDropdown(context);
                    },
                  ),
                  _buildMainCard(
                    title: "Kasir",
                    imagePath: 'assets/images/report_cashier.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReportKasir(),
                        ),
                      );
                    },
                  ),
                  _buildMainCard(
                    title: "Metode Pembayaran",
                    imagePath: 'assets/images/report_payment_methode.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReportPaymentMethod(),
                        ),
                      );
                    },
                  ),
                  _buildMainCard(
                      title: "Laporan Profit",
                      imagePath: 'assets/images/report_expense.png',
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => ReportProfit()));
                      })
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<Widget> children,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 4.w,
        right: 4.w,
        top: 3.h,
        bottom: 4.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 0.w,
            runSpacing: 2.h,
            children: children,
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard({
    required String title,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return MainCard(
      onTap: onTap,
      title: title,
      color: Colors.black,
      imagePath: imagePath,
    );
  }
}
