import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kas_mini_lite/model/cashier.dart';
import 'package:kas_mini_lite/providers/cashierProvider.dart';
import 'package:kas_mini_lite/services/database_service.dart';
import 'package:kas_mini_lite/utils/colors.dart';
import 'package:kas_mini_lite/view/page/transaction/success_transaction_page.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

Future<void> addTransactionToDatabase(
  String formattedDate,
  String cashierName,
  String customerName,
  int totalPrice,
  int transactionModal,
  int jumlahBayar,
  discountAmount,
  String selectedPaymentMethod,
  List<Map<String, dynamic>> products,
  int queueNumber,
) async {
  Future<String> calculateTransactionStatus(
      int jumlahBayar, int totalPrice) async {
    if (jumlahBayar < 1) {
      return 'Belum Dibayar';
    } else if (jumlahBayar >= totalPrice) {
      return 'Selesai';
    } else {
      return 'Belum Lunas';
    }
  }

  final DatabaseService databaseService = DatabaseService.instance;
  void fetchCashierById(int id) async {
    CashierProvider cashierProvider = CashierProvider();
    CashierData? cashier = await cashierProvider.getCashierById(id);

    if (cashier != null) {
      print('ID: ${cashier.cashierId}, Name: ${cashier.cashierName}');
    } else {
      print('Cashier not found!');
    }
  }

  fetchCashierById(1); // Contoh: Ambil kasir dengan ID 1

  int calculateTotalPurchasePrice(List<Map<String, dynamic>> products) {
    int totalPurchasePrice = 0;
    for (var product in products) {
      int purchasePrice = product['product_purchase_price'];
      int quantity = product['quantity'];
      totalPurchasePrice += purchasePrice * quantity;
    }
    return totalPurchasePrice;
  }

  int calculateProfit(
      int totalPrice, int jumlahBayar, List<Map<String, dynamic>> products) {
    int totalPurchasePrice = calculateTotalPurchasePrice(products);
    return (jumlahBayar >= totalPrice)
        ? totalPrice - totalPurchasePrice
        : jumlahBayar - totalPurchasePrice;
  }

  // Create a transaction map
  Map<String, dynamic> transaction = {
    'transaction_date': formattedDate,
    'transaction_cashier': cashierName,
    'transaction_customer_name':
        customerName.isNotEmpty ? customerName : "Pelanggan",
    'transaction_total': totalPrice,
    'transaction_modal': transactionModal,
    'transaction_pay_amount': jumlahBayar,
    'transaction_discount': discountAmount,
    'transaction_method': selectedPaymentMethod,
    'transaction_note': "Beli",
    'transaction_tax': 0,
    'transaction_status':
        await calculateTransactionStatus(jumlahBayar, totalPrice),
    'transaction_products': jsonEncode(products),
    'transaction_quantity':
        products.map((e) => e['quantity']).reduce((a, b) => a + b),
    'transaction_queue_number': queueNumber,
    'transaction_profit': calculateProfit(totalPrice, jumlahBayar, products)
  };

  // Add the transaction to the database
  try {
    await databaseService.addTransaction(transaction);
    print("Transaction added successfully");

    // Update product stock
    for (var product in products) {
      String productName = product['product_name'];
      int quantity = product['quantity'];

      // Fetch current stock from database
      int? currentStock =
          await databaseService.getProductStockByName(productName);

      // Cek apakah currentStock null
      if (currentStock == 0) {
        print(
            " WARNING: Product ID $productName not found in database. Skipping stock update...");
        continue; // Skip update stock untuk produk ini
      }

      // Update stock dengan value yang valid
      int updatedStock = currentStock - quantity;

      await databaseService.updateProductStockByProductName(
          productName, updatedStock);
      print(
          " Stock updated for product ID $productName: $currentStock -> $updatedStock");
    }
  } catch (e, stackTrace) {
    print(" ERROR TO ADD TRANSACTION: $e");
    print(" Stacktrace: $stackTrace");
  }
}

void showModalKonfirmasi(
    BuildContext context,
    int totalPrice,
    int transactionModal,
    totalItems,
    discountAmount,
    List<Map<String, dynamic>> products,
    Map<int, int> quantities,
    String selectedPaymentMethod,
    int queueNumber, // Accept queueNumber
    DateTime? lastTransactionDate) {
  showDialog(
    context: context,
    builder: (context) {
      String customerName = '';
      int jumlahBayar = totalPrice;
      TextEditingController jumlahBayarController =
          TextEditingController(text: jumlahBayar.toString());

      // Convert jumlahBayar to int before sending to the database
      int parseJumlahBayar(String formattedValue) {
        return int.parse(formattedValue.replaceAll(RegExp(r'[^0-9]'), ''));
      }

      // Mendapatkan tanggal dan waktu saat ini
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('EEEE, dd/MM/yyyy HH:mm', 'id_ID')
          .format(now); // Format tanggal dan waktu

      var cashierProvider = Provider.of<CashierProvider>(context);
      String cashierName = cashierProvider.cashierData?['cashierName'];

      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.9,
                    ),
                    child: Container(
                      width: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20.0),
                                  topRight: Radius.circular(20.0),
                                )),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Konfirmasi Pembelian !",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.sp,
                                    color: Colors.white,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: Icon(Icons.close, color: redColor),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8),
                          // Total Harga
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Total Harga :\n ${NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0).format(totalPrice)}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          // TextField: Jumlah Bayar
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
                              padding: EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                    color: Colors.grey[400]!, width: 1.0),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.money, color: Colors.green),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: jumlahBayarController,
                                      style: TextStyle(color: Colors.black),
                                      decoration: InputDecoration(
                                        labelText: "Jumlah Bayar",
                                        prefixText: "Rp. ",
                                        labelStyle:
                                            TextStyle(color: Colors.black),
                                        border: InputBorder.none,
                                      ),
                                      obscureText: false,
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        setState(() {
                                          jumlahBayar = int.parse(
                                              value.replaceAll(
                                                  RegExp(r'[^0-9]'),
                                                  '')); // Update jumlah bayar
                                          jumlahBayarController.text =
                                              NumberFormat.currency(
                                                      locale: 'id_ID',
                                                      decimalDigits: 0,
                                                      symbol: '')
                                                  .format(jumlahBayar);
                                          jumlahBayarController.selection =
                                              TextSelection.fromPosition(
                                                  TextPosition(
                                                      offset:
                                                          jumlahBayarController
                                                              .text.length));
                                        });
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        jumlahBayarController
                                            .clear(); // Reset jumlah bayar
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          // TextField: Nama Customer
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
                              padding: EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                    color: Colors.grey[400]!, width: 1.0),
                              ),
                              child: TextField(
                                onChanged: (value) {
                                  setState(() {
                                    customerName = value;
                                  });
                                },
                                style: TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  labelText: "Nama Customer",
                                  labelStyle: TextStyle(color: Colors.black),
                                  border: InputBorder.none,
                                  prefixIcon:
                                      Icon(Icons.person, color: Colors.green),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          // Card: Tanggal Transaksi
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, ),
                            child: _buildCard(
                              icon: Icons.calendar_today,
                              title: "Tanggal Transaksi",
                              subtitle:
                                  formattedDate, // Tampilkan tanggal dan waktu saat ini
                            ),
                          ),

                          // Tombol Bayar
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                // Tambahkan transaksi ke database
                                addTransactionToDatabase(
                                    formattedDate,
                                    cashierName,
                                    customerName,
                                    totalPrice,
                                    transactionModal,
                                    parseJumlahBayar(jumlahBayarController.text),
                                    discountAmount,
                                    selectedPaymentMethod,
                                    products,
                                    queueNumber);
                            
                                // Increment queue number after successful transaction
                                queueNumber; // Increment queue number
                                lastTransactionDate = DateTime
                                    .now(); // Update last transaction date
                            
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            TransactionSuccessPage(
                                              amountPrice: jumlahBayar,
                                              totalPrice: totalPrice,
                                              products: products,
                                              transactionDate: formattedDate,
                                              discountAmount: discountAmount,
                                              customerName: customerName,
                                              queueNumber:
                                                  queueNumber, // Pass queueNumber
                                            )));
                            
                                // Tampilkan data yang telah diinputkan dalam konsol
                                print("Tanggal: $formattedDate");
                                print("Customer: $customerName");
                                print("Cashier Name: ");
                                print("Total Harga: $totalPrice");
                                print("Modal: $transactionModal");
                                print("Jumlah Pesanan: $totalItems");
                                print("Potongan Harga: $discountAmount");
                                print("Tanggal: $formattedDate");
                                print(
                                    "Metode Pembayaran: $selectedPaymentMethod");
                                print("Jumlah Bayar: $jumlahBayar");
                                print("Jumlah Bayar: $queueNumber");
                                print(
                                    "Jumlah Pesanan: ${products.map((e) => e['quantity']).reduce((a, b) => a + b)}");
                                print("Produk: $products");
                                print("Nama Kasir: $cashierName");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                
                                padding: EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 15),
                              ),
                              child: Text(
                                "BAYAR",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    },
  );
}

Widget _buildCard({
  required IconData icon,
  required String title,
  String? subtitle,
  IconData? trailingIcon,
  Color? trailingColor,
}) {
  return Container(
    padding: EdgeInsets.all(12.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10.0),
      border: Border.all(color: Colors.grey[400]!, width: 1.0),
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.green),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              if (subtitle != null && subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.black),
                ),
            ],
          ),
        ),
        if (trailingIcon != null)
          Icon(trailingIcon, color: trailingColor ?? Colors.white),
      ],
    ),
  );
}
