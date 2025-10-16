import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kas_mini_flutter_app/model/transaction.dart';
import 'package:kas_mini_flutter_app/providers/bluetoothProvider.dart';
import 'package:kas_mini_flutter_app/providers/securityProvider.dart';
import 'package:kas_mini_flutter_app/services/database_service.dart';
import 'package:kas_mini_flutter_app/utils/bluetoothAlert.dart';
import 'package:kas_mini_flutter_app/utils/colors.dart';
import 'package:kas_mini_flutter_app/utils/modal_animation.dart';
import 'package:kas_mini_flutter_app/utils/pinModalWithAnimation.dart';
import 'package:kas_mini_flutter_app/utils/printer_helper.dart';
import 'package:kas_mini_flutter_app/utils/responsif/fsize.dart';
import 'package:kas_mini_flutter_app/utils/successAlert.dart';
import 'package:kas_mini_flutter_app/view/page/share_detail_transacttion.dart';
import 'package:kas_mini_flutter_app/view/page/transaction/transactions_page.dart';
import 'package:kas_mini_flutter_app/view/widget/pinModal.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailHistoryTransaction extends StatefulWidget {
  final TransactionData? transactionDetail;
  const DetailHistoryTransaction({super.key, this.transactionDetail});

  @override
  State<DetailHistoryTransaction> createState() =>
      _DetailHistoryTransactionState();
}

class _DetailHistoryTransactionState extends State<DetailHistoryTransaction> {
  @override
  Widget build(BuildContext context) {
    var bluetoothProvider = Provider.of<BluetoothProvider>(context);
    var securityProvider = Provider.of<SecurityProvider>(context);
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header section
            Container(
              width: double.infinity,
              height: 80,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [secondaryColor, primaryColor],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20))),
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back_outlined),
                      color: Colors.white),
                  Text("DETAIL TRANSAKSI",
                      style: GoogleFonts.poppins(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w600))
                ],
              ),
            ),

            // Transaction info section
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              child: Column(
                children: [
                  Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "ID Transaksi: # ${widget.transactionDetail!.transactionId}",
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                Icon(Icons.person_2_outlined,
                                    size: 20, color: secondaryColor),
                              ],
                            ),
                            Divider(
                              color: secondaryColor,
                              thickness: 1,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                    "Jumlah Pesanan: ${widget.transactionDetail!.transactionQuantity}",
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            Gap(2),
                            Row(
                              children: [
                                Text("Total Harga: ",
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            Gap(2),
                            Row(
                              children: [
                                Text(
                                    NumberFormat.currency(
                                            locale: 'id',
                                            symbol: 'Rp. ',
                                            decimalDigits: 0)
                                        .format(widget.transactionDetail!
                                            .transactionTotal),
                                    style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(Icons.calendar_today,
                                      size: 14, color: secondaryColor),
                                  Text(
                                      " ${widget.transactionDetail!.transactionDate}",
                                      style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                  Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12))),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              "Status: ${widget.transactionDetail!.transactionStatus}",
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                          Text(
                              "Antrian: ${widget.transactionDetail!.transactionQueueNumber}",
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  Gap(10),
                  Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                ClipRect(
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: secondaryColor,
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: Icon(Icons.person,
                                        color: Colors.white, size: 24),
                                  ),
                                ),
                                Gap(10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "Nama Kasir : ${widget.transactionDetail!.transactionCashier}",
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600)),
                                    Text(
                                        "Metode Bayar : ${widget.transactionDetail!.transactionPaymentMethod}",
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ),
                            Divider(
                              color: secondaryColor,
                              thickness: 1,
                            ),
                            Row(
                              children: [
                                Text(
                                    "Jumlah Bayar : ${NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0).format(widget.transactionDetail!.transactionPayAmount)}",
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700)),
                              ],
                            )
                          ],
                        ),
                      )),
                  Gap(8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      children: [
                        Text("Detail Pesanan",
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        Spacer(),
                        
                        InkWell(
                              onTap: () {},
                              child: Container(
                                width: 80,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(padding: const EdgeInsets.all(4.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text("Edit Pesanan",
                                          style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white)),
                                    ],
                                  ),
                              ),
                            )),
                            Gap(8),
                        InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TransactionPage(
                                            selectedProducts: []
                                          )));
                            },
                            child: Container(
                              width: 80,
                              height: 40,
                              decoration: BoxDecoration(
                                  color: secondaryColor,
                                  borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text("Pesan Ulang",
                                        style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white)),
                                  ],
                                ),
                              ),
                            )),
                            
                        // Gap(6),
                        // InkWell(
                        //     onTap: () {},
                        //     child: Container(
                        //       width: 80,
                        //       height: 40,
                        //       decoration: BoxDecoration(
                        //           color: primaryColor,
                        //           borderRadius: BorderRadius.circular(12)),
                        //       child: Padding(
                        //         padding: const EdgeInsets.all(4.0),
                        //         child: Column(
                        //           mainAxisAlignment: MainAxisAlignment.center,
                        //           crossAxisAlignment: CrossAxisAlignment.center,
                        //           children: [
                        //             Text("Edit Pesanan",
                        //                 style: GoogleFonts.poppins(
                        //                     fontSize: 10,
                        //                     fontWeight: FontWeight.w600,
                        //                     color: Colors.white)),
                        //           ],
                        //         ),
                        //       ),
                        //     ))
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Product list section
            Expanded(
              child: ListView.builder(
                itemCount: widget.transactionDetail!.transactionProduct.length,
                itemBuilder: (context, index) {
                  var product =
                      widget.transactionDetail!.transactionProduct[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['product_name'],
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Divider(
                            color: secondaryColor,
                            thickness: 1,
                          ),
                          Text(
                            "${product['quantity']} x ${NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0).format(product['product_sell_price'])}",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Subtotal: ',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            NumberFormat.currency(
                                    locale: 'id_ID',
                                    symbol: 'Rp. ',
                                    decimalDigits: 0)
                                .format(product['product_sell_price']),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Action buttons section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          if (securityProvider.kunciCetakStruk) {
                            showPinModalWithAnimation(context,
                                pinModal: PinModal(onTap: () {
                              if (bluetoothProvider.isConnected) {
                                PrinterHelper.printDetailTransaction(
                                    transaction: widget.transactionDetail!,
                                    context,
                                    bluetoothProvider.connectedDevice!,
                                    products: widget
                                        .transactionDetail!.transactionProduct);
                                showSuccessAlert(context,
                                    "Berhasil mencetak, silahkan tunggu sebentar!.");
                              }
                            }));
                          } else {
                            if (bluetoothProvider.isConnected) {
                              PrinterHelper.printDetailTransaction(
                                  products: widget
                                      .transactionDetail!.transactionProduct,
                                  context,
                                  bluetoothProvider.connectedDevice!,
                                  transaction: widget.transactionDetail!);
                              showSuccessAlert(context,
                                  "Berhasil mencetak, silahkan tunggu sebentar!.");
                            } else {
                              showBluetoothAlert2(context);
                            }
                          }
                        },
                        child: Container(
                          width: 120,
                          height: 50,
                          decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.print_outlined,
                                    color: Colors.white, size: 24),
                                Gap(4),
                                Text("Cetak",
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600))
                              ],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (securityProvider.kunciCetakStruk) {
                            showPinModalWithAnimation(context,
                                pinModal: PinModal(onTap: () {
                              if (bluetoothProvider.isConnected) {
                                PrinterHelper.printDetailTransaction(
                                    transaction: widget.transactionDetail!,
                                    context,
                                    bluetoothProvider.connectedDevice!,
                                    products: widget
                                        .transactionDetail!.transactionProduct);
                                showSuccessAlert(context,
                                    "Berhasil mencetak, silahkan tunggu sebentar!.");
                              }
                            }));
                          } else {
                            if (bluetoothProvider.isConnected) {
                              PrinterHelper.printDetailTransaction(
                                  products: widget
                                      .transactionDetail!.transactionProduct,
                                  context,
                                  bluetoothProvider.connectedDevice!,
                                  transaction: widget.transactionDetail!);
                              showSuccessAlert(context,
                                  "Berhasil mencetak, silahkan tunggu sebentar!.");
                            } else {
                              showBluetoothAlert2(context);
                            }
                          }
                        },
                        child: Container(
                          width: 120,
                          height: 50,
                          decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.print_outlined,
                                    color: Colors.white, size: 24),
                                Gap(4),
                                Text("Antrian",
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600))
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ShareDetailTransaction(
                                        transactionDetail:
                                            widget.transactionDetail,
                                      )));
                        },
                        child: Container(
                          width: 120,
                          height: 50,
                          decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.share_outlined,
                                    color: Colors.white, size: 24),
                                Gap(4),
                                Text("Bagikan",
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600))
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            DatabaseService.instance.updateTransactionStatus(
                                widget.transactionDetail!.transactionId,
                                "Dibatalkan");
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: EdgeInsets.all(4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.close_outlined,
                                      color: Colors.white, size: 24),
                                  Gap(4),
                                  Text("Batalkan Pesanan",
                                      style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600))
                                ],
                              ),
                            ),
                          ),
                        ),
                        Gap(4),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                      child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(40),
                                        bottomRight: Radius.circular(40),
                                        topLeft: Radius.circular(40),
                                        topRight: Radius.circular(40),
                                      ),
                                    ),
                                    width: 300,
                                    height: 300,
                                    padding: const EdgeInsets.all(16.0),
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxWidth: 300,
                                              maxHeight: 300,
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Lottie.asset(
                                                  'assets/lottie/warning-2.json',
                                                  width: 120,
                                                  height: 120,
                                                  repeat: false,
                                                ),
                                                const Gap(10),
                                                Text(
                                                  'Yakin Ingin Hapus Transaksi Ini!',
                                                  style: GoogleFonts.poppins(
                                                    fontSize:
                                                        SizeHelper.Fsize_alert(
                                                            context),
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black,
                                                    decoration:
                                                        TextDecoration.none,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                const Gap(20),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Container(
                                                        width: 120,
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                            color: primaryColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12)),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4.0),
                                                          child: Center(
                                                            child: Text(
                                                                "Batalkan",
                                                                style: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600)),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                        DatabaseService.instance
                                                            .deleteTransaction(widget
                                                                .transactionDetail!
                                                                .transactionId);
                                                        Navigator.pop(context);
                                                        showSuccessModal(
                                                            context,
                                                            "Berhasil menghapus transaksi, silahkan tunggu sebentar!.");
                                                      },
                                                      child: Container(
                                                        width: 120,
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                            color: redColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12)),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4.0),
                                                          child: Center(
                                                            child: Text("Hapus",
                                                                style: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600)),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                            child: Image.asset(
                                              "assets/images/close.png",
                                              height: 40,
                                              width: 40,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ));
                                });
                          },
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: EdgeInsets.all(4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.delete_outline_outlined,
                                      color: primaryColor, size: 24),
                                  Gap(4),
                                  Text("Hapus Pesanan",
                                      style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: primaryColor,
                                          fontWeight: FontWeight.w600))
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

void showSuccessModal(BuildContext context, String message) async {
  final prefs = await SharedPreferences.getInstance();
  bool isSoundOn = prefs.getBool('isSoundOn') ?? false;
  if (isSoundOn) {
    playSuccessSound();
  }
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Center(
        child: ModalAnimation(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            width: 300,
            height: 300,
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 300,
                      maxHeight: 300,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Lottie.asset(
                          'assets/lottie/success-blue.json',
                          width: 150,
                          height: 150,
                        ),
                        const Gap(10),
                        Text(
                          message,
                          style: GoogleFonts.poppins(
                            fontSize: SizeHelper.Fsize_alert(context),
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            decoration: TextDecoration.none,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      "assets/images/close.png",
                      height: 40,
                      width: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
