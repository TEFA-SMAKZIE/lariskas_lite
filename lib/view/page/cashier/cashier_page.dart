import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/uil.dart';
import 'package:kas_mini_flutter_app/model/cashier.dart';
import 'package:kas_mini_flutter_app/providers/cashierProvider.dart';
import 'package:kas_mini_flutter_app/utils/colors.dart';
import 'package:kas_mini_flutter_app/utils/responsif/fsize.dart';
import 'package:kas_mini_flutter_app/view/page/cashier/add_cashier_page.dart';
import 'package:kas_mini_flutter_app/view/widget/Notfound.dart';
import 'package:kas_mini_flutter_app/view/widget/back_button.dart';
import 'package:kas_mini_flutter_app/view/widget/card_cashier.dart';
import 'package:kas_mini_flutter_app/view/widget/expensiveFloatingButton.dart';
import 'package:kas_mini_flutter_app/view/widget/search.dart';
import 'package:provider/provider.dart';

/// Halaman Manajemen Kasir
/// Menampilkan daftar kasir dan memungkinkan penambahan kasir baru
class CashierPage extends StatefulWidget {
  const CashierPage({super.key});

  @override
  State<CashierPage> createState() => _CashierPageState();
}

class _CashierPageState extends State<CashierPage> {
  TextEditingController _searchController = TextEditingController();
  String _sortOrder = 'asc';

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        scrolledUnderElevation: 0,
        title: Text(
          "KELOLA KASIR",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: SizeHelper.Fsize_normalTitle(context),
            color: primaryColor,
          ),
        ),
        centerTitle: true,
        leading: CustomBackButton(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              _buildSearchAndSortSection(),
        
                SizedBox(
                height: MediaQuery.of(context).size.height * 0.65,
                child: _buildCashierGridView(),
                )
              // Tombol Tambah Kasir
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.0),
        child: ExpensiveFloatingButton(
          isPositioned: true,
          onPressed: () {
            _navigateToAddCashierPage();
          },
          text: "TAMBAH KASIR",
        ),
      ),
    );
  }

  /// Widget untuk section pencarian dan sorting
  Widget _buildSearchAndSortSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Expanded(
              child: SearchTextField(
                prefixIcon: const Icon(Icons.search, size: 24),
                obscureText: false,
                hintText: "Cari Kasir",
                controller: _searchController,
                maxLines: 1,
                suffixIcon: null,
                color: Colors.white,
              ),
            ),
            const Gap(10),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.sort_by_alpha),
                            title: const Text("A-Z"),
                            onTap: () {
                              setState(() {
                                _sortOrder = 'asc';
                              });
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.sort),
                            title: const Text("Z-A"),
                            onTap: () {
                              setState(() {
                                _sortOrder = 'desc';
                              });
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.sort_by_alpha),
                            title: const Text("Terbaru"),
                            onTap: () {
                              setState(() {
                                _sortOrder = 'newest';
                              });
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.sort_by_alpha),
                            title: const Text("Terlama"),
                            onTap: () {
                              setState(() {
                                _sortOrder = 'oldest';
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: const Column(
                children: [
                  Iconify(Uil.sort, size: 24),
                  Text("Sort"),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Widget untuk menampilkan daftar kasir dalam GridView
  Widget _buildCashierGridView() {
    return Consumer<CashierProvider>(
      builder: (context, cashierProvider, child) {
        return FutureBuilder<List<CashierData>>(
          future: cashierProvider.getCashiers(
              query: _searchController.text, sortOrder: _sortOrder),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                  child: NotFoundPage(
                title: _searchController.text == ""
                    ? "Tidak ada Kasir yang ditemukan"
                    : 'Tidak ada Kasir dengan nama "${_searchController.text}"',
              ));
            } else {
              final cashiers = snapshot.data!;
              return ListView.builder(
                padding: EdgeInsets.only(top: 10),
                // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                //   crossAxisCount: 1, // 1 card per baris
                //   childAspectRatio: 4, // rasio
                //   mainAxisSpacing: 2,
                // ),
                itemCount: cashiers.length,
                itemBuilder: (context, index) {
                  final result = cashiers[index];
                  return CardCashier(cashier: result);
                },
              );
            }
          },
        );
      },
    );
  }

  /// Widget untuk tombol tambah kasir
  Widget _buildAddCashierButton() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: ExpensiveFloatingButton(
        onPressed: () {
          _navigateToAddCashierPage();
        },
        text: "TAMBAH KASIR",
      ),
    );
  }

  /// Metode untuk navigasi dengan animasi slide
  void _navigateToAddCashierPage() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AddCashierPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween<Offset>(begin: begin, end: end)
              .chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 300), // Durasi transisi
      ),
    );
  }
}
