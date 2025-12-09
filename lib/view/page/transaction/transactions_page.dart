import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:intl/intl.dart';
import 'package:kas_mini_lite/model/product.dart';
import 'package:kas_mini_lite/utils/colors.dart';
import 'package:kas_mini_lite/utils/null_data_alert.dart';
import 'package:kas_mini_lite/utils/responsif/fsize.dart';
import 'package:kas_mini_lite/view/page/transaction/checkout_page.dart';
import 'package:kas_mini_lite/view/page/transaction/select_product_page.dart';
import 'package:kas_mini_lite/view/widget/antrian.dart';
import 'package:kas_mini_lite/view/widget/back_button.dart';
import 'package:kas_mini_lite/view/widget/card_transaction.dart';
import 'package:kas_mini_lite/view/widget/floating_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionsPage extends StatelessWidget {
  final List<Product> selectedProducts;

  const TransactionsPage({super.key, required this.selectedProducts});

  @override
  Widget build(BuildContext context) {
    return TransactionPage(selectedProducts: selectedProducts);
  }
}

class TransactionPage extends StatefulWidget {
  final List<Product> selectedProducts;

  const TransactionPage({super.key, required this.selectedProducts});

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final Map<int, int> _quantities = {};
  double totalTransaksi = 0;
  int queueNumber = 1;
  bool isAutoReset = false;
  bool nonActivateQueue = false;

  Future<void> _loadQueueAndisAutoResetValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      queueNumber = prefs.getInt('queueNumber') ?? 1;
      isAutoReset = prefs.getBool('isAutoReset') ?? false;
      nonActivateQueue = prefs.getBool('nonActivateQueue') ?? false;

      if (nonActivateQueue == true) {
        queueNumber = 0;
      }
    });

    print('''
      loaded: 
      queueNumber: $queueNumber,
      isAutoReset: $isAutoReset,
      nonActivateQueue: $nonActivateQueue
    ''');
  }

  DateTime? lastTransactionDate;

  @override
  void initState() {
    super.initState();
    _loadQueueAndisAutoResetValue();

    Future.delayed(Duration(milliseconds: 400), () {
      setState(() {});
    });
    for (int i = 0; i < widget.selectedProducts.length; i++) {
      _quantities[i] = 1; // Set default quantity to 1
    }
    _calculateTotalTransaksi();

    // Hitung total transaksi saat inisialisasi
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _calculateTotalTransaksi() {
    double total = 0;
    for (int i = 0; i < widget.selectedProducts.length; i++) {
      total +=
          widget.selectedProducts[i].productSellPrice * (_quantities[i] ?? 1);
    }
    setState(() {
      totalTransaksi = total;
    });
  }

  void _updateTotalPerItem(int index, int quantity) {
    setState(() {
      _quantities[index] = quantity;
      _calculateTotalTransaksi(); // Hitung ulang total transaksi
    });
  }

  void _removeProduct(int index) {
    setState(() {
      widget.selectedProducts.removeAt(index);
      _quantities.remove(index);
      _calculateTotalTransaksi(); // Hitung ulang total transaksi setelah menghapus produk
    });
  }

  void _navigateToSelectProductPage() async {
    final List<Product>? newSelectedProducts = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectProductPage(
          selectedProducts: [...widget.selectedProducts],
        ),
      ),
    );
    if (newSelectedProducts != null) {
      setState(() {
        // Use a Set to automatically remove duplicates based on productId
        final uniqueProductsSet = <int, Product>{};

        // Add existing products to the set
        for (var product in widget.selectedProducts) {
          uniqueProductsSet[product.productId] = product;
        }

        // Add new products to the set (duplicates will be overwritten)
        for (var product in newSelectedProducts) {
          if (uniqueProductsSet.containsKey(product.productId)) {
            print("Produk dengan ID ${product.productId} dipilih!");
          } else {
            uniqueProductsSet[product.productId] = product;
          }
        }

        // Convert the set values back to a list
        widget.selectedProducts.clear();
        widget.selectedProducts.addAll(uniqueProductsSet.values);

        // Recalculate total transaction
        _calculateTotalTransaksi();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: const CustomBackButton(),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () async {
                final result = await showModalQueue(
                    context, queueNumber, isAutoReset, nonActivateQueue);
                if (result != null) {
                  print("queue: $result");

                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setInt('queueNumber', result['queueNumber']);
                  await prefs.setBool('isAutoReset', result['isAutoReset']);
                  setState(() {
                    queueNumber = result['queueNumber'];
                  });

                  _loadQueueAndisAutoResetValue();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [primaryColor, secondaryColor],
                        begin: Alignment(0, 2),
                        end: Alignment(-0, -2)),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Text(
                        "Antrian",
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
        title: Text(
          'TRANSAKSI',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: SizeHelper.Fsize_normalTitle(context),
            color: primaryColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GridView.builder(
                    scrollDirection: Axis.vertical,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2 / 1,
                    ),
                    itemCount: widget.selectedProducts.length,
                    itemBuilder: (BuildContext context, int index) {
                      return CardTransaction(
                        key: ValueKey(widget.selectedProducts[index].productId),
                        initialQuantity: _quantities[index] ?? 1,
                        onQuantityChanged: (quantity) {
                          _updateTotalPerItem(index, quantity);
                        },
                        onDelete: () {
                          _removeProduct(
                              index); // Panggil fungsi untuk menghapus produk
                        },
                        onChange: () {
                          _removeProduct(
                              index); // Panggil fungsi untuk menghapus produk
                          _navigateToSelectProductPage();
                        },
                        product: widget.selectedProducts[index],
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                      begin: Alignment(0, 2),
                      end: Alignment(-0, -2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TOTAL TRANSAKSI',
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            NumberFormat.currency(
                                    locale: 'id_ID',
                                    symbol: 'Rp. ',
                                    decimalDigits: 0)
                                .format(totalTransaksi),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (widget.selectedProducts.isEmpty) {
                            showNullDataAlert(context);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CheckoutPage(
                                  quantities: _quantities,
                                  queueNumber: queueNumber,
                                  lastTranasctionDate: lastTransactionDate,
                                  selectedProducts:
                                      widget.selectedProducts.toList(),
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            'BAYAR',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.width <= 400 ? 120 : 90,
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
                  text: 'Add',
                  icon: MaterialSymbols.shopping_cart,
                  onPressed: _navigateToSelectProductPage,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
