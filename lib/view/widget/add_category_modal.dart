import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kas_mini_flutter_app/providers/securityProvider.dart';
import 'package:kas_mini_flutter_app/services/database_service.dart';
import 'package:kas_mini_flutter_app/utils/colors.dart';
import 'package:kas_mini_flutter_app/utils/failedAlert.dart';
import 'package:kas_mini_flutter_app/utils/pinModalWithAnimation.dart';
import 'package:kas_mini_flutter_app/utils/successAlert.dart';
import 'package:kas_mini_flutter_app/view/widget/pinModal.dart';
import 'package:provider/provider.dart';

import 'dart:async';

Future<bool> createCategoryModal({
  required BuildContext context,
  required TextEditingController productCreateCategoryController,
  required FocusNode categoryFocusNode,
  required DatabaseService databaseService,
}) async {
  final completer = Completer<bool>(); // Digunakan untuk menunggu hasil
  var securityProvider = Provider.of<SecurityProvider>(context, listen: false);
  print("Memeriksa SecurityProvider...");
  print(securityProvider.kunciTambahKategori);

  if (securityProvider.kunciTambahKategori) {
    print("SecurityProvider check passed");

    showPinModalWithAnimation(
      context,
      pinModal: PinModal(
        destination: null,
        onTap: () {
          print("Pin modal OK button pressed");
          Navigator.pop(context);

          showDialog(
            context: context,
            builder: (context) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                categoryFocusNode.requestFocus();
              });
              return AlertDialog(
                backgroundColor: Colors.grey[300],
                title: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Tambah Kategori',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: productCreateCategoryController,
                      focusNode: categoryFocusNode,
                      decoration: InputDecoration(
                        labelText: 'Kategori',
                        hintText: 'Nama Kategori',
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const Gap(5),
                    ElevatedButton(
                      onPressed: () async {
                        final categoryName =
                            productCreateCategoryController.text;
                        if (categoryName.isNotEmpty) {
                          final db = await databaseService.database;
                          final data = await db.rawQuery('''
                                SELECT *
                                FROM categories WHERE category_name = ?
                          ''', [categoryName]);

                          if (data.isNotEmpty) {
                            showFailedAlert(context,
                                message: "Kategori sudah ada!");
                          } else {
                            await databaseService.addCategory(
                              categoryName,
                              DateTime.now().toIso8601String(),
                            );
                            showSuccessAlert(context,
                                'Kategori "$categoryName" berhasil ditambahkan! ');
                            Navigator.pop(context, true);
                            completer.complete(true); // Selesaikan dengan true
                          }
                        } else {
                          showFailedAlert(context,
                              message: "Nama Kategori Tidak Boleh Kosong");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Center(
                        child: Text(
                          "SIMPAN",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  } else {
    print("SecurityProvider check failed");
    showDialog(
      context: context,
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          categoryFocusNode.requestFocus();
        });
        return AlertDialog(
          backgroundColor: Colors.grey[300],
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Tambah Kategori',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: productCreateCategoryController,
                focusNode: categoryFocusNode,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  hintText: 'Nama Kategori',
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const Gap(5),
              ElevatedButton(
                onPressed: () async {
                  final categoryName = productCreateCategoryController.text;
                  if (categoryName.isNotEmpty) {
                    final db = await databaseService.database;
                    final data = await db.rawQuery('''
                            SELECT *
                            FROM categories WHERE category_name = ?
                    ''', [categoryName]);

                    if (data.isNotEmpty) {
                      showFailedAlert(context, message: "Kategori sudah ada!");
                    } else {
                      await databaseService.addCategory(
                        categoryName,
                        DateTime.now().toIso8601String(),
                      );
                      showSuccessAlert(context,
                          'Kategori "$categoryName" berhasil ditambahkan! ');
                      Navigator.pop(context, true);
                      completer.complete(true); // Selesaikan dengan true
                    }
                  } else {
                    showFailedAlert(context,
                        message: "Nama Kategori Tidak Boleh Kosong");
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Center(
                  child: Text(
                    "SIMPAN",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
  return completer.future; // Tunggu hingga proses selesai
}