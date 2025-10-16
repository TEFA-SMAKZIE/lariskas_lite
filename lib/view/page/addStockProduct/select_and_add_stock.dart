import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kas_mini_flutter_app/model/product.dart';
import 'package:kas_mini_flutter_app/services/database_service.dart';
import 'package:kas_mini_flutter_app/utils/colors.dart';
import 'package:kas_mini_flutter_app/view/page/addStockProduct/select_product.dart';
import 'package:kas_mini_flutter_app/view/widget/Notfound.dart';
import 'package:kas_mini_flutter_app/view/widget/add_product_stock_card.dart';
import 'package:kas_mini_flutter_app/view/widget/app_bar_stock.dart';
import 'package:kas_mini_flutter_app/view/widget/expensiveFloatingButton.dart';

class SelectAndAddStockProduct extends StatefulWidget {
  final List<Product>? selectedProductStock;
  const SelectAndAddStockProduct({super.key, this.selectedProductStock});

  @override
  State<SelectAndAddStockProduct> createState() =>
      _SelectAndAddStockProductState();
}

class _SelectAndAddStockProductState extends State<SelectAndAddStockProduct> {
  List<Product> _selectedProductStock = [];
  late List<Product> selectedProductStock;
  Map<String, int> productAmounts = {}; // Store amounts for each product
  Map<String, TextEditingController> noteControllers = {};

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        selectedProductStock = _selectedProductStock;
        refreshPage();
      });
    });
  }

  void refreshPage() {
    setState(() {
      selectedProductStock = _selectedProductStock;
    });
  }

  Future<void> saveSelectedProductStock() async {
  final DatabaseService databaseService = DatabaseService.instance;
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  List<Map<String, dynamic>> stockAdditions = [];

  for (var product in selectedProductStock) {
    int amount = productAmounts[product.productId.toString()] ?? 0;
    String note = noteControllers[product.productId.toString()]?.text ?? '';

    if (amount > 0) {
      stockAdditions.add({
        'stock_addition_name': product.productName,
        'stock_addition_date': formattedDate,
        'stock_addition_amount': amount,
        'stock_addition_note': note.isNotEmpty ? note : 'Penambahan stok otomatis',
        'stock_addition_product_id': product.productId,
      });
    }
  }

  if (stockAdditions.isNotEmpty) {
    for (var stockData in stockAdditions) {
      await databaseService.addProductStock(stockData);
    }
    print('Stok produk berhasil disimpan ke database!');
  } else {
    print('Tidak ada stok yang ditambahkan.');
  }
}


  Future<void> _updateJumlahStockProduct() async {
    final DatabaseService databaseService = DatabaseService.instance;

    for (var product in selectedProductStock) {
      int amount = productAmounts[product.productId.toString()] ?? 0;
      int productStock = product.productStock;
      int newStock = productStock + amount;
      await databaseService.updateProductStock(product.productId, newStock);
    }
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
              appBarText: "TAMBAH STOK PRODUK",
              ),
              Expanded(
              child: selectedProductStock.isEmpty
                ? NotFoundPage(
                  title: "Belum ada produk yang dipilih!",
                )
                : ListView.builder(
                  itemCount: selectedProductStock.length,
                  itemBuilder: (context, index) {
                    final productSelectedList = selectedProductStock[index];
                    return StockCardScreen(
  product: productSelectedList,
  onAmountChanged: (amount) {
    setState(() {
      productAmounts[productSelectedList.productId.toString()] = amount;
    });
  },
  noteController: noteControllers.putIfAbsent(
    productSelectedList.productId.toString(),
    () => TextEditingController(),
  ),
);

                  },
                  ),
              ),
            ],
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: ExpensiveFloatingButton(
                text: "PILIH PRODUK",
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelectProduct(
                          selectedProductStock: selectedProductStock),
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      selectedProductStock = List<Product>.from(result);
                    });
                  }
                },
              ),
            ),
          ),
          Positioned(
            bottom: 15,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: ExpensiveFloatingButton(
                text: "SIMPAN STOK",
                onPressed: () {
                  _updateJumlahStockProduct();
                  saveSelectedProductStock();
                  print(
                      'Menambahkan stok untuk produk: ${selectedProductStock.map((p) => '${p.productName} sebanyak ${productAmounts[p.productId.toString()] ?? 0}').toList().join(', ')}');
                  Navigator.pop(context, true);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
