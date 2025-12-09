import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:kas_mini_lite/model/product.dart';
import 'package:kas_mini_lite/utils/not_enough_stock_alert.dart';
import 'package:sizer/sizer.dart';

class CardTransaction extends StatefulWidget {
  final Product product;
  final int initialQuantity;
  final Function(int)? onQuantityChanged;
  final VoidCallback? onDelete;
  final Function(Product)? onEdit; // Fungsi baru untuk memicu edit
  final VoidCallback? onChange; // Fungsi baru untuk memicu perubahan

  const CardTransaction({
    super.key,
    required this.product,
    this.initialQuantity = 1,
    this.onQuantityChanged,
    this.onDelete,
    this.onChange,
    this.onEdit, // Menambahkan parameter onEdit
  });

  @override
  _CardTransactionState createState() => _CardTransactionState();
}

class _CardTransactionState extends State<CardTransaction> {
  late int quantity;

  @override
  void initState() {
    super.initState();
    quantity = widget.initialQuantity;
  }

  void decrement() {
    if (quantity > 1) {
      setState(() {
        quantity--;
        widget.onQuantityChanged?.call(quantity);
      });
    }
  }

  void increment() {
    setState(() {
      quantity++;
      widget.onQuantityChanged?.call(quantity);
      if (quantity > widget.product.productStock) {
        // Menampilkan pesan peringatan
        showNotEnoughStock(context);
        return decrement();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dapatkan ukuran layar dan responsif
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    // Atur ukuran dan gaya secara dinamis
    double totalHarga = (widget.product.productSellPrice.toDouble() * quantity);

    return AspectRatio(
      aspectRatio: isSmallScreen ? 3 / 1.5 : 3 / 1.2,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Card(
            color: Colors.white,
            margin: EdgeInsets.symmetric(horizontal: 2.h, vertical: 1.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 10 : 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      // Gambar Produk
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(widget.product.productImage.toString()),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              "assets/products/no-image.png",
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.productName,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: isSmallScreen ? 12 : 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Rp. ${widget.product.productSellPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: isSmallScreen ? 12 : 14),
                            ),
                          ],
                        ),
                      ),
                      // Tombol Hapus
                      IconButton(
                        icon:
                            const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: widget.onDelete, // Panggil fungsi hapus
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        // Panggil fungsi untuk memilih produk baru
                        onPressed: () {
                          widget.onChange?.call();
                        },
                        child: Text(
                          'Ubah',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: decrement,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              minimumSize: const Size(40, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: const Iconify(
                              Ic.outline_minus,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                          SizedBox(
                            width: 50,
                            child: TextField(
                              controller: TextEditingController.fromValue(
                                TextEditingValue(
                                  text: quantity.toString(),
                                  selection: TextSelection.collapsed(
                                      offset: quantity.toString().length),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                              onChanged: (value) {
                                final newQuantity =
                                    int.tryParse(value) ?? quantity;
                                if (newQuantity > 0 &&
                                    newQuantity <=
                                        widget.product.productStock) {
                                  setState(() {
                                    quantity = newQuantity;
                                    widget.onQuantityChanged?.call(quantity);
                                  });
                                } else {
                                  // Handle invalid input or stock limit
                                  debugPrint(
                                      "Invalid quantity or exceeds stock limit");
                                }
                              },
                            ),
                          ),
                          ElevatedButton(
                            onPressed: increment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              minimumSize: const Size(40, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: const Iconify(
                              Ic.outline_plus,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Gap(10),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.blueGrey[100],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text(
                            'Total :',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: isSmallScreen ? 12 : 14),
                          ),
                          const Spacer(),
                          Text(
                            'Rp. ${totalHarga.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: isSmallScreen ? 12 : 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
