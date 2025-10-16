import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kas_mini_flutter_app/providers/cashierProvider.dart';
import 'package:kas_mini_flutter_app/providers/securityProvider.dart';
import 'package:kas_mini_flutter_app/utils/colors.dart';
import 'package:kas_mini_flutter_app/utils/pinModalWithAnimation.dart';
import 'package:kas_mini_flutter_app/utils/responsif/fsize.dart';
import 'package:kas_mini_flutter_app/view/page/History_transaksi.dart';
import 'package:kas_mini_flutter_app/view/page/addStockProduct/add_stock_product.dart';
import 'package:kas_mini_flutter_app/view/page/cashier/cashier_page.dart';
import 'package:kas_mini_flutter_app/view/page/change_password/changePassword.dart';
import 'package:kas_mini_flutter_app/view/page/expense/expense_page.dart';
import 'package:kas_mini_flutter_app/view/page/income/income_page.dart';
import 'package:kas_mini_flutter_app/view/page/print_resi/input_resi.dart';
import 'package:kas_mini_flutter_app/view/page/product/product.dart';
import 'package:kas_mini_flutter_app/view/page/report/report_page.dart';
import 'package:kas_mini_flutter_app/view/page/settings/scanDevicePrinter.dart';
import 'package:kas_mini_flutter_app/view/page/settings/securityPage.dart';
import 'package:kas_mini_flutter_app/view/page/settings/setting.dart';
import 'package:kas_mini_flutter_app/view/widget/back_button.dart';
import 'package:kas_mini_flutter_app/view/widget/menu_card.dart';
import 'package:kas_mini_flutter_app/view/widget/pinModal.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class AllIconPage extends StatefulWidget {
  const AllIconPage({super.key});

  @override
  State<AllIconPage> createState() => _AllIconPageState();
}

class _AllIconPageState extends State<AllIconPage> {
  @override
  Widget build(BuildContext context) {
    var securityProvider = Provider.of<SecurityProvider>(context);
    var cashierProvider = Provider.of<CashierProvider>(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: const CustomBackButton(),
        backgroundColor: Colors.transparent,
        title: Text(
          'SELENGKAPNYA',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: SizeHelper.Fsize_normalTitle(context),
            color: primaryColor,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 3.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection("Transaksi", [
                if (cashierProvider.cashierData?['cashierName'] == "Owner")
                  _buildMainCard("Kasir", 'assets/images/cashier.png', () {
                    if (securityProvider.kunciPengaturanToko) {
                      showPinModalWithAnimation(
                        context,
                        pinModal: PinModal(
                          destination: SettingPage(),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SettingPage()),
                      );
                    }
                  }),
                _buildMainCard("Cetak Resi", 'assets/images/printer.png', () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const InputResi()));
                }),
                _buildMainCard("Pengeluaran", 'assets/images/expense.png', () {
                  if (securityProvider.kunciPengeluaran) {
                    showPinModalWithAnimation(
                      context,
                      pinModal: PinModal(
                        destination: ExpensePage(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ExpensePage()),
                    );
                  }
                }),
                _buildMainCard("Riwayat", 'assets/images/history.png', () {
                  if (securityProvider.kunciRiwayatTransaksi) {
                    showPinModalWithAnimation(
                      context,
                      pinModal: PinModal(
                        destination: RiwayatTransaksi(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RiwayatTransaksi()),
                    );
                  }
                }),
                _buildMainCard("Laporan", 'assets/images/report.png', () {
                  if (securityProvider.kunciLaporan) {
                    showPinModalWithAnimation(
                      context,
                      pinModal: PinModal(
                        destination: ReportPage(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReportPage()),
                    );
                  }
                }),
                _buildMainCard("Pemasukan", 'assets/images/income.png', () {
                  if (securityProvider.kunciPemasukan) {
                    showPinModalWithAnimation(
                      context,
                      pinModal: PinModal(
                        destination: IncomePage(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => IncomePage()),
                    );
                  }
                }),
              ]),
              Gap(2.h),
              _buildSection("Produk", [
                _buildMainCard("Produk", 'assets/images/product.png', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProductPage()),
                  );
                }),
                _buildMainCard("Tambah Stok", 'assets/images/add.png', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AddStockProductPage()),
                  );
                }),
              ]),
              Gap(2.h),
              _buildSection("Pengaturan", [
                _buildMainCard("Pengaturan", 'assets/images/setting.png', () {
                  if (securityProvider.kunciPengaturanToko) {
                    showPinModalWithAnimation(
                      context,
                      pinModal: PinModal(
                        destination: SettingPage(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingPage()),
                    );
                  }
                }),
                if (cashierProvider.cashierData?['cashierName'] == "Owner")
                  _buildMainCard("Keamanan", 'assets/images/keamanan.png', () {
                    showPinModalWithAnimation(
                      context,
                      pinModal: PinModal(
                        destination: SecuritySettingsPage(),
                      ),
                    );
                  }),
                _buildMainCard("Ganti Password", 'assets/images/Password.png',
                    () {
                  if (securityProvider.kunciGantiPassword) {
                    showPinModalWithAnimation(
                      context,
                      pinModal: PinModal(
                        destination: ChangepasswordPage(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChangepasswordPage()),
                    );
                  }
                }),
                _buildMainCard(
                    "Koneksi Bluetooth", 'assets/images/Bluetooth.png', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ScanDevicePrinter()),
                  );
                }),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Gap(1.h),
          Wrap(
            spacing: 0.w,
            runSpacing: 2.h,
            children: children,
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard(String title, String imagePath, VoidCallback onTap) {
    return MainCard(
      onTap: onTap,
      title: title,
      color: Colors.black,
      imagePath: imagePath,
    );
  }
}
