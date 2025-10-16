import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kas_mini_flutter_app/model/cashier.dart';
import 'package:kas_mini_flutter_app/providers/cashierProvider.dart';
import 'package:kas_mini_flutter_app/services/database_service.dart';
import 'package:kas_mini_flutter_app/utils/colors.dart';
import 'package:kas_mini_flutter_app/utils/responsif/fsize.dart';
import 'package:kas_mini_flutter_app/view/widget/Notfound.dart';
import 'package:kas_mini_flutter_app/view/widget/back_button.dart';
import 'package:kas_mini_flutter_app/view/widget/refresWidget.dart';
import 'package:kas_mini_flutter_app/view/widget/search.dart';
import 'package:provider/provider.dart';

class SelectCashier extends StatefulWidget {
  const SelectCashier({super.key});

  @override
  State<SelectCashier> createState() => _SelectCashierState();
}

class _SelectCashierState extends State<SelectCashier> {
  final DatabaseService _databaseService = DatabaseService.instance;

  final TextEditingController _searchController = TextEditingController();
  List<CashierData> _filteredCashier = [];

  @override
  void initState() {
    super.initState();
    _loadCashiers();
    _searchController.addListener(_filterCashiers);
  }

  Future _loadCashiers() async {
    final cashiers = await _databaseService.getCashiers();
    setState(() {
      _filteredCashier = cashiers;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCashiers);
    _searchController.dispose();
    super.dispose();
  }

  void _filterCashiers() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      _loadCashiers();
    } else {
      setState(() {
        _filteredCashier = _filteredCashier.where((cashier) {
          return cashier.cashierName.toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "PILIH KASIR",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: SizeHelper.Fsize_normalTitle(context),
            color: primaryColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: CustomBackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
        ),
        child: Column(
          children: [
            const Gap(20),
            SearchTextField(
              prefixIcon: const Icon(Icons.search, size: 24),
              obscureText: false,
              hintText: "Search",
              controller: _searchController,
              maxLines: 1,
              suffixIcon: null,
              color: Colors.white,
            ),
            const Gap(5),
            Expanded(
              child: _filteredCashier.isEmpty
                  ? CustomRefreshWidget(
                      onRefresh: null,
                      child: Center(
                          child: NotFoundPage(
                        title: _searchController.text == ""
                            ? "Tidak ada Kasir yang ditemukan"
                            : 'Tidak ada Kasir dengan nama "${_searchController.text}"',
                      )),
                    )
                  : ListView.builder(
                      itemBuilder: (context, index) {
                        final cashier = _filteredCashier[index];
                        var cashierProvider = Provider.of<CashierProvider>(
                            context,
                            listen: false);
                        return Column(
                          children: [
                            const Gap(5),
                            Container(
                              decoration: BoxDecoration(
                                color: cashierProvider
                                            .cashierData?['cashierName'] ==
                                        cashier.cashierName
                                    ? Colors.white
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                title: Row(
                                  children: [
                                    ClipOval(
                                      child: Image.asset(
                                        cashier.cashierImage,
                                        width: 30,
                                        height: 30,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Gap(10),
                                    Text(cashierProvider
                                                .cashierData?['cashierName'] ==
                                            cashier.cashierName
                                        ? "${cashier.cashierName} (Sedang digunakan)"
                                        : cashier.cashierName),
                                  ],
                                ),
                                onTap: cashierProvider
                                            .cashierData?['cashierName'] ==
                                        cashier.cashierName
                                    ? null
                                    : () {
                                        print(
                                            'cashir id: ${cashier.cashierId}');

                                        Navigator.pop(context, {
                                          'cashierName': cashier.cashierName,
                                          'cashierPin': cashier.cashierPin,
                                          'cashierId':
                                              cashier.cashierId.toString()
                                        });
                                      },
                              ),
                            ),
                            const Gap(5),
                          ],
                        );
                      },
                      itemCount: _filteredCashier.length,
                    ),
            )
          ],
        ),
      ),
    );
  }
}
