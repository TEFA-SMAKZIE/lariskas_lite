import 'package:flutter/material.dart';
import 'package:kas_mini_flutter_app/model/product.dart';
import 'package:kas_mini_flutter_app/services/database_service.dart';
import 'package:kas_mini_flutter_app/utils/colors.dart';
import 'package:kas_mini_flutter_app/view/widget/Notfound.dart';
import 'package:kas_mini_flutter_app/view/widget/app_bar_stock.dart';
import 'package:kas_mini_flutter_app/view/widget/expensiveFloatingButton.dart';
import 'package:kas_mini_flutter_app/view/widget/select_product_stock.dart'; // Import halaman baru

class SelectProduct extends StatefulWidget {
  final List<Product>? selectedProductStock;
  const SelectProduct({super.key, this.selectedProductStock});

  @override
  State<SelectProduct> createState() => _SelectProductState();
}

class _SelectProductState extends State<SelectProduct> {
  final DatabaseService _databaseService = DatabaseService.instance;
  late List<Product> selectedProductStock;

  @override
  void initState() {
    super.initState();
    selectedProductStock = widget.selectedProductStock ?? [];
  }

  Future<List<Product>> _getProductData() async {
    final List<Product> products = await _databaseService.getProducts();
    return products;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          Column(
            children: [
              AppBarStock(
                appBarText: "PILIH PRODUK",
              ),
              Expanded(
                child: FutureBuilder<List<Product>>(
                  future: _getProductData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      final data = snapshot.data!;
                      return ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final product = data[index];
                          final isSelected =
                              selectedProductStock.contains(product);
                          return SelectStockProductCard(
                            product: product,
                            isSelected: isSelected,
                            onSelect: () {
                              setState(() {
                                if (isSelected) {
                                  selectedProductStock.remove(product);
                                } else {
                                  selectedProductStock.add(product);
                                }
                              });
                            },
                            selectedProductStock: selectedProductStock,
                          );
                        },
                      );
                    } else {
                      return const Center(child: NotFoundPage(
                        title: "Tidak ada produk!",
                      ));
                    }
                  },
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 15,
            left: 0,
            right: 0,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: ExpensiveFloatingButton(
                    text: "TAMBAH STOK",
                    onPressed: () {
                      // Navigasi ke halaman SelectAndAddStockProduct dan kirim selectedProductStock
                      Navigator.pop(context, selectedProductStock);
                    })),
          ),
        ],
      ),
    );
  }
}
