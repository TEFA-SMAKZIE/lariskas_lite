import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kas_mini_lite/model/cashier.dart';
import 'package:kas_mini_lite/model/expenceModel.dart';
import 'package:kas_mini_lite/model/expense.dart';
import 'package:kas_mini_lite/model/paymentMethod.dart';
import 'package:kas_mini_lite/model/product.dart';
import 'package:kas_mini_lite/model/report_cashier.dart';
import 'package:kas_mini_lite/model/report_payment_model.dart';
import 'package:kas_mini_lite/model/report_sold_product.dart';
import 'package:kas_mini_lite/model/transaction.dart';
import 'package:kas_mini_lite/services/database_service.dart';
import 'package:kas_mini_lite/utils/colors.dart';
import 'package:kas_mini_lite/utils/failedAlert.dart';
import 'package:kas_mini_lite/utils/successAlert.dart';
import 'package:kas_mini_lite/view/page/report/report_payment_method.dart';
import 'package:kas_mini_lite/view/widget/custom_textfield.dart';
import 'package:kas_mini_lite/view/widget/dateFrom-To.dart';
import 'package:kas_mini_lite/view/widget/date_from_to/fromTo_v2.dart';
import 'package:kas_mini_lite/view/widget/date_from_to/from_to_v3.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:excel/excel.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

// Controller
TextEditingController fileNameController = TextEditingController();
TextEditingController profitController = TextEditingController();
TextEditingController statusController = TextEditingController();
TextEditingController dateFromController = TextEditingController();
TextEditingController dateToController = TextEditingController();

void clearTextFields() {
  fileNameController.clear();
  dateFromController.clear();
  dateToController.clear();
  statusController.clear();
}

DateTime toDate = DateTime.now();
DateTime fromDate = DateTime.now();

String fileName = fileNameController.text.trim();

final DatabaseService databaseService = DatabaseService.instance;

class CustomModals {
  static Future<void> saveExcelFile(String fileName) async {
    Future<List<TransactionData>> _getTransactionData() async {
      try {
        return await databaseService.getTransaction();
      } catch (e) {
        print('Error fetching transactions: $e');
        return [];
      }
    }

    if (fileName.isEmpty) {
      print('Nama file tidak boleh kosong');
    } else {
      // Membuat file Excel
      var excel = Excel.createExcel();
      var sheet = excel['Sheet1'];

      // Menambahkan header ke sheet
      sheet.cell(CellIndex.indexByString('A1')).value = 'Transaction ID';
      sheet.cell(CellIndex.indexByString('B1')).value = 'Transaction Date';
      sheet.cell(CellIndex.indexByString('C1')).value = 'Transaction Status';
      sheet.cell(CellIndex.indexByString('D1')).value =
          'Transaction Customer Name';
      sheet.cell(CellIndex.indexByString('E1')).value = 'Transaction Product';
      sheet.cell(CellIndex.indexByString('F1')).value = 'Transaction Profit';

      List<TransactionData> transactions = await _getTransactionData();

      int rowIndex =
          2; // Mulai dari baris kedua (karena baris pertama adalah header)

      // for (TransactionData transaction in transactions) {
      //   List<String> products = transaction.transactionProduct.split(', '); // Pisahkan produk dengan koma (sesuai format database)

      //   for (int j = 0; j < products.length; j++) {
      //     if (j == 0) {
      //       // Baris pertama dari transaksi, isi semua kolom
      //       sheet.cell(CellIndex.indexByString('A$rowIndex')).value = transaction.transactionId;
      //       sheet.cell(CellIndex.indexByString('B$rowIndex')).value = transaction.transactionDate;
      //       sheet.cell(CellIndex.indexByString('C$rowIndex')).value = transaction.transactionStatus;
      //       sheet.cell(CellIndex.indexByString('D$rowIndex')).value = transaction.transactionCustomerName;
      //       sheet.cell(CellIndex.indexByString('E$rowIndex')).value = products[j];
      //       sheet.cell(CellIndex.indexByString('F$rowIndex')).value = transaction.transactionTotal;
      //     } else {
      //       // Baris tambahan hanya menampilkan produk (gunakan whitespace pada kolom lain)
      //       sheet.cell(CellIndex.indexByString('E$rowIndex')).value = products[j];
      //     }
      //     rowIndex++; // Pindah ke baris berikutnya
      //   }
      // }

      List<int>? fileBytes = excel.save();
      if (fileBytes != null) {
        // Simpan file ke direktori eksternal
        final directory = await getExternalStorageDirectory();
        final filePath = join(directory!.path, '$fileName.xlsx');
        final file = File(filePath);

        await file.writeAsBytes(fileBytes);

        print('File berhasil disimpan di $filePath');
      }
    }
  }

  // Fungsi untuk menampilkan dialog export Excel
  static Future<void> modalexportexel(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Spacer(),
                    Text(
                      'Export Excel',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        clearTextFields();
                      },
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Gap(20),
                CustomTextField(
                    obscureText: false,
                    hintText: "Nama File",
                    prefixIcon: null,
                    controller: fileNameController,
                    maxLines: 1,
                    suffixIcon: null,
                    fillColor: Colors.white),
                const Gap(30),
                InkWell(
                  onTap: () async {
                    final fileName = fileNameController.text.trim();
                    if (fileName.isEmpty) {
                      clearTextFields();
                      Navigator.pop(context);
                      showFailedAlert(context);
                    } else {
                      clearTextFields();
                      Navigator.pop(context);
                      showSuccessAlert(context, 'Berhasil');
                      await saveExcelFile(fileName);
                    }
                  },
                  child: Container(
                    height: 40,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: greenColor,
                    ),
                    child: Center(
                      child: Text(
                        'Simpan',
                        style: GoogleFonts.poppins(color: whiteMerona),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> modalExportPaymentMethodData(
      BuildContext context, List<Map<String, dynamic>> paymentData) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Spacer(),
                    Text(
                      'Export Excel',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        clearTextFields();
                      },
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Gap(20),
                CustomTextField(
                    obscureText: false,
                    hintText: "Nama File",
                    prefixIcon: null,
                    controller: fileNameController,
                    maxLines: 1,
                    suffixIcon: null,
                    fillColor: Colors.white),
                const Gap(30),
                InkWell(
                  onTap: () async {
                    final fileName = fileNameController.text.trim();
                    if (fileName.isEmpty) {
                      clearTextFields();
                      Navigator.pop(context);
                      showFailedAlert(context);
                    } else {
                      clearTextFields();
                      Navigator.pop(context);
                      showSuccessAlert(context, 'Berhasil');
                      await saveExcelPaymentMethodData(fileName, paymentData);
                    }
                  },
                  child: Container(
                    height: 40,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: greenColor,
                    ),
                    child: Center(
                      child: Text(
                        'Simpan',
                        style: GoogleFonts.poppins(color: whiteMerona),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> saveExcelPaymentMethodData(
      String fileName, List<Map<String, dynamic>> paymentData) async {
    if (fileName.isEmpty) {
      print('Nama file tidak boleh kosong');
    } else {
      // Membuat file Excel
      var excel = Excel.createExcel();
      var sheet = excel['Sheet1'];

      // Menambahkan header ke sheet
      sheet.cell(CellIndex.indexByString('A1')).value = 'Payment Method Name';
      sheet.cell(CellIndex.indexByString('B1')).value = 'Profit';
      sheet.cell(CellIndex.indexByString('C1')).value = 'Date Range';

      int rowIndex =
          2; // Mulai dari baris kedua (karena baris pertama adalah header)

      for (var data in paymentData) {
        sheet.cell(CellIndex.indexByString('A$rowIndex')).value =
            data['paymentMethod'];
        sheet.cell(CellIndex.indexByString('B$rowIndex')).value =
            data['totalAmount'];
        sheet.cell(CellIndex.indexByString('C$rowIndex')).value =
            '${data['paymentDateFrom']} - ${data['paymentDateTo']}';
        rowIndex++; // Move to the next row for the next data entry
      }

      List<int>? fileBytes = excel.save();
      if (fileBytes != null) {
        // Simpan file ke direktori eksternal
        final directory = await getExternalStorageDirectory();
        final filePath = join(directory!.path, '$fileName.xlsx');
        final file = File(filePath);

        await file.writeAsBytes(fileBytes);

        print('File berhasil disimpan di $filePath');
        print('Data $paymentData.');
      }
    }
  }

  static Future<void> saveExcelStockProductReport(
      String fileName, List<Product> productStock) async {
    if (fileName.isEmpty) {
      print('Nama file tidak boleh kosong');
    } else {
      // Membuat file Excel
      var excel = Excel.createExcel();
      var sheet = excel['Sheet1'];

      // Menambahkan header ke sheet
      sheet.cell(CellIndex.indexByString('A1')).value = 'Product ID';
      sheet.cell(CellIndex.indexByString('B1')).value = 'Product Name';
      sheet.cell(CellIndex.indexByString('C1')).value = 'Category Product';
      sheet.cell(CellIndex.indexByString('D1')).value = 'Product Unit';
      sheet.cell(CellIndex.indexByString('E1')).value = 'Product Capital Price';
      sheet.cell(CellIndex.indexByString('F1')).value = 'Product Sell Price';
      sheet.cell(CellIndex.indexByString('G1')).value = 'Total Stock Value';

      int rowIndex =
          2; // Mulai dari baris kedua (karena baris pertama adalah header)

      for (var data in productStock) {
        sheet.cell(CellIndex.indexByString('A$rowIndex')).value =
            data.productId;
        sheet.cell(CellIndex.indexByString('B$rowIndex')).value =
            data.productName;
        sheet.cell(CellIndex.indexByString('C$rowIndex')).value =
            data.categoryName;
        sheet.cell(CellIndex.indexByString('D$rowIndex')).value =
            data.productUnit;
        sheet.cell(CellIndex.indexByString('E$rowIndex')).value =
            data.productPurchasePrice;
        sheet.cell(CellIndex.indexByString('F$rowIndex')).value =
            data.productSellPrice;
        sheet.cell(CellIndex.indexByString('G$rowIndex')).value =
            data.productPurchasePrice * data.productStock;

        rowIndex++; // Move to the next row for the next data entry
      }

      List<int>? fileBytes = excel.save();
      if (fileBytes != null) {
        // Simpan file ke direktori eksternal
        final directory = await getExternalStorageDirectory();
        final filePath = join(directory!.path, '$fileName.xlsx');
        final file = File(filePath);

        await file.writeAsBytes(fileBytes);

        print('File berhasil disimpan di $filePath');
        print('Data $productStock.');
        // Bagikan file menggunakan package Share_plus
        // await Share.share(filePath);
      }
    }
  }

  static Future<void> modalExportStockProduct(
      BuildContext context, List<Product> productStock) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Spacer(),
                    Text(
                      'Export Excel',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        clearTextFields();
                      },
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Gap(20),
                CustomTextField(
                    obscureText: false,
                    hintText: "Nama File",
                    prefixIcon: null,
                    controller: fileNameController,
                    maxLines: 1,
                    suffixIcon: null,
                    fillColor: Colors.white),
                const Gap(30),
                InkWell(
                  onTap: () async {
                    final fileName = fileNameController.text.trim();
                    if (fileName.isEmpty) {
                      clearTextFields();
                      Navigator.pop(context);
                      showFailedAlert(context);
                    } else {
                      clearTextFields();
                      Navigator.pop(context);
                      showSuccessAlert(context, 'Berhasil');
                      await saveExcelStockProductReport(fileName, productStock);
                    }
                  },
                  child: Container(
                    height: 40,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: greenColor,
                    ),
                    child: Center(
                      child: Text(
                        'Simpan',
                        style: GoogleFonts.poppins(color: whiteMerona),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> modalExportExpenseData(
      BuildContext context, List<Expensemodel> expenseData) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xffD9D9D9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Spacer(),
                    Text(
                      'Export Excel',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        clearTextFields();
                      },
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Gap(20),
                CustomTextField(
                    obscureText: false,
                    hintText: "Nama File",
                    prefixIcon: null,
                    controller: fileNameController,
                    maxLines: 1,
                    suffixIcon: null,
                    fillColor: Colors.white),
                const Gap(30),
                InkWell(
                  onTap: () async {
                    final fileName = fileNameController.text.trim();
                    if (fileName.isEmpty) {
                      clearTextFields();
                      Navigator.pop(context);
                      showFailedAlert(context);
                    } else {
                      clearTextFields();
                      Navigator.pop(context);
                      showSuccessAlert(context, 'Berhasil');
                      await saveExcelExpenseData(fileName, expenseData);
                    }
                  },
                  child: Container(
                    height: 40,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: greenColor,
                    ),
                    child: Center(
                      child: Text(
                        'Simpan',
                        style: GoogleFonts.poppins(color: whiteMerona),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> saveExcelExpenseData(
      String fileName, List<Expensemodel> expenseData) async {
    if (fileName.isEmpty) {
      print('Nama file tidak boleh kosong');
    } else {
      // Membuat file Excel
      var excel = Excel.createExcel();
      var sheet = excel['Sheet1'];

      // Menambahkan header ke sheet
      sheet.cell(CellIndex.indexByString('A1')).value = 'Expense ID';
      sheet.cell(CellIndex.indexByString('B1')).value = 'Expense Name';
      sheet.cell(CellIndex.indexByString('C1')).value = 'Date';
      sheet.cell(CellIndex.indexByString('D1')).value = 'Date Added';
      sheet.cell(CellIndex.indexByString('E1')).value = 'Note';
      sheet.cell(CellIndex.indexByString('F1')).value = 'Amount';

      int rowIndex =
          2; // Mulai dari baris kedua (karena baris pertama adalah header)

      for (var data in expenseData) {
        final formattedDate = data.date != null
            ? DateFormat('dd/MM/yyyy').format(DateTime.parse(data.date!))
            : 'Invalid Date';
        final formattedDateAdded = data.dateAdded != null
            ? DateFormat('dd/MM/yyyy').format(DateTime.parse(data.dateAdded!))
            : 'Invalid Date';

        sheet.cell(CellIndex.indexByString('A$rowIndex')).value = data.id;
        sheet.cell(CellIndex.indexByString('B$rowIndex')).value = data.name;
        sheet.cell(CellIndex.indexByString('C$rowIndex')).value = formattedDate;
        sheet.cell(CellIndex.indexByString('D$rowIndex')).value =
            formattedDateAdded;
        sheet.cell(CellIndex.indexByString('E$rowIndex')).value = data.note;
        sheet.cell(CellIndex.indexByString('F$rowIndex')).value = data.amount;

        rowIndex++; // Move to the next row for the next data entry
      }

      List<int>? fileBytes = excel.save();
      if (fileBytes != null) {
        // Simpan file ke direktori eksternal
        final directory = await getExternalStorageDirectory();
        final filePath = join(directory!.path, '$fileName.xlsx');
        final file = File(filePath);

        await file.writeAsBytes(fileBytes);

        print('File berhasil disimpan di $filePath');
        print('Data $expenseData.');
        // Bagikan file menggunakan package Share_plus
        // await Share.share(filePath);
      }
    }
  }

  static Future<void> modalExportCashierDataExcel(
      BuildContext context, List<ReportCashierData> dataToExport) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Spacer(),
                    Text(
                      'Export Excel',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        clearTextFields();
                      },
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Gap(20),
                CustomTextField(
                    obscureText: false,
                    hintText: "Nama File",
                    prefixIcon: null,
                    controller: fileNameController,
                    maxLines: 1,
                    suffixIcon: null,
                    fillColor: Colors.white),
                const Gap(30),
                InkWell(
                  onTap: () async {
                    final fileName = fileNameController.text.trim();
                    if (fileName.isEmpty) {
                      clearTextFields();
                      Navigator.pop(context);
                      showFailedAlert(context);
                    } else {
                      clearTextFields();
                      Navigator.pop(context);
                      showSuccessAlert(context, 'Berhasil');
                      await saveExcelFileCashierReport(fileName, dataToExport);
                    }
                  },
                  child: Container(
                    height: 40,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: greenColor,
                    ),
                    child: Center(
                      child: Text(
                        'Simpan',
                        style: GoogleFonts.poppins(color: whiteMerona),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> saveExcelFileCashierReport(
      String fileName, List<ReportCashierData> dataToExport) async {
    if (fileName.isEmpty) {
      print('Nama file tidak boleh kosong');
    } else {
      // Membuat file Excel
      var excel = Excel.createExcel();
      var sheet = excel['Sheet1'];

      // Menambahkan header ke sheet
      sheet.cell(CellIndex.indexByString('A1')).value = 'Cashier ID';
      sheet.cell(CellIndex.indexByString('B1')).value = 'Cashier Name';
      sheet.cell(CellIndex.indexByString('C1')).value =
          'Transaction Date Range';
      sheet.cell(CellIndex.indexByString('D1')).value = 'Transaction Quantity';
      sheet.cell(CellIndex.indexByString('E1')).value = 'Transaction Money';
      sheet.cell(CellIndex.indexByString('F1')).value = 'Selesai';
      sheet.cell(CellIndex.indexByString('G1')).value = 'Belum Lunas';
      sheet.cell(CellIndex.indexByString('H1')).value = 'Belum Bayar';
      sheet.cell(CellIndex.indexByString('I1')).value = 'Dibatalkan';

      int rowIndex =
          2; // Mulai dari baris kedua (karena baris pertama adalah header)

      for (var data in dataToExport) {
        sheet.cell(CellIndex.indexByString('A$rowIndex')).value =
            data.cashierId;
        sheet.cell(CellIndex.indexByString('B$rowIndex')).value =
            data.cashierName;
        sheet.cell(CellIndex.indexByString('C$rowIndex')).value =
            data.transactionDateRange;
        sheet.cell(CellIndex.indexByString('D$rowIndex')).value =
            data.cashierTotalTransaction;
        sheet.cell(CellIndex.indexByString('E$rowIndex')).value =
            data.cashierTotalTransactionMoney;
        sheet.cell(CellIndex.indexByString('F$rowIndex')).value = data.selesai;
        sheet.cell(CellIndex.indexByString('G$rowIndex')).value = data.proses;
        sheet.cell(CellIndex.indexByString('H$rowIndex')).value = data.pending;
        sheet.cell(CellIndex.indexByString('I$rowIndex')).value = data.batal;
        rowIndex++; // Move to the next row for the next data entry
      }

      List<int>? fileBytes = excel.save();
      if (fileBytes != null) {
        // Simpan file ke direktori eksternal
        final directory = await getExternalStorageDirectory();
        final filePath = join(directory!.path, '$fileName.xlsx');
        final file = File(filePath);

        await file.writeAsBytes(fileBytes);

        print('File berhasil disimpan di $filePath');
        print('Data $dataToExport.');
      }
    }
  }

// Fungsi untuk menampilkan dialog export Excel
  static Future<void> modalExportSoldProduct(
      BuildContext context, List<ReportSoldProduct> dataSoldProduct) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Spacer(),
                    Text(
                      'Export Excel',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        clearTextFields();
                      },
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Gap(20),
                CustomTextField(
                    obscureText: false,
                    hintText: "Nama File",
                    prefixIcon: null,
                    controller: fileNameController,
                    maxLines: 1,
                    suffixIcon: null,
                    fillColor: Colors.white),
                const Gap(30),
                InkWell(
                  onTap: () async {
                    final fileName = fileNameController.text.trim();
                    if (fileName.isEmpty) {
                      clearTextFields();
                      Navigator.pop(context);
                      showFailedAlert(context);
                    } else {
                      clearTextFields();
                      Navigator.pop(context);
                      showSuccessAlert(context, 'Berhasil');
                      await saveExcelReportSoldProduct(
                          fileName, dataSoldProduct);
                    }
                  },
                  child: Container(
                    height: 40,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: greenColor,
                    ),
                    child: Center(
                      child: Text(
                        'Simpan',
                        style: GoogleFonts.poppins(color: whiteMerona),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> saveExcelReportSoldProduct(
      String fileName, List<ReportSoldProduct> dataSoldProduct) async {
    if (fileName.isEmpty) {
      print('Nama file tidak boleh kosong');
    } else {
      // Membuat file Excel
      var excel = Excel.createExcel();
      var sheet = excel['Sheet1'];

      // Menambahkan header ke sheet
      sheet.cell(CellIndex.indexByString('A1')).value = 'Product ID';
      sheet.cell(CellIndex.indexByString('B1')).value = 'Product Name';
      sheet.cell(CellIndex.indexByString('C1')).value = 'Category Product';
      sheet.cell(CellIndex.indexByString('D1')).value = 'Dete Range';
      sheet.cell(CellIndex.indexByString('E1')).value = 'Product Sold Quantity';

      int rowIndex =
          2; // Mulai dari baris kedua (karena baris pertama adalah header)

      for (var data in dataSoldProduct) {
        sheet.cell(CellIndex.indexByString('A$rowIndex')).value =
            data.productId;
        sheet.cell(CellIndex.indexByString('B$rowIndex')).value =
            data.productName;
        sheet.cell(CellIndex.indexByString('C$rowIndex')).value =
            data.productCategory;
        sheet.cell(CellIndex.indexByString('D$rowIndex')).value =
            data.dateRange;
        sheet.cell(CellIndex.indexByString('E$rowIndex')).value =
            data.productSold;
        rowIndex++; // Move to the next row for the next data entry
      }

      List<int>? fileBytes = excel.save();
      if (fileBytes != null) {
        // Simpan file ke direktori eksternal
        final directory = await getExternalStorageDirectory();
        final filePath = join(directory!.path, '$fileName.xlsx');
        final file = File(filePath);

        await file.writeAsBytes(fileBytes);

        print('File berhasil disimpan di $filePath');
        print('Data $dataSoldProduct.');
      }
    }
  }

  static Future<void> modalExportExcelDropdown(BuildContext context) async {
    final TextEditingController fileNameController = TextEditingController();
    final TextEditingController statusController = TextEditingController();
    DateTime fromDate = DateTime.now();
    DateTime toDate = DateTime.now();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        final mediaQuery = MediaQuery.of(context);
        final maxWidth = mediaQuery.size.width * 0.9;
        final heightsdf = MediaQuery.of(context).orientation == Orientation.portrait? mediaQuery.size.height * 0.5: mediaQuery.size.height * 0.8;

        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: heightsdf,
            ),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20), bottom: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                      const Gap(10),
                      StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return WidgetDateFromTo_v2(
                            title: 'Export Excel',
                            initialStartDate: fromDate,
                            initialEndDate: toDate,
                            onDateRangeChanged: (start, end) {
                              setState(() {
                                fromDate = start;
                                toDate = end;
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        CustomTextField(
                          obscureText: false,
                          hintText: "Nama File",
                          prefixIcon: null,
                          controller: fileNameController,
                          maxLines: 1,
                          suffixIcon: null,
                          fillColor: Colors.white,
                        ),
                        const Gap(20),
                        GestureDetector(
                          onTap: () async {
                            final selectedStatus =
                                await showModalBottomSheet<String>(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20)),
                              ),
                              builder: (BuildContext context) {
                                return Container(
                                  height: 300,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        height: 5,
                                        width: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[400],
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      ListTile(
                                        title: const Text('Semua'),
                                        onTap: () =>
                                            Navigator.pop(context, 'Semua'),
                                      ),
                                      ListTile(
                                        title: const Text('Selesai'),
                                        onTap: () =>
                                            Navigator.pop(context, 'Selesai'),
                                      ),
                                      ListTile(
                                        title: const Text('Belum Lunas'),
                                        onTap: () => Navigator.pop(
                                            context, 'Belum Lunas'),
                                      ),
                                      ListTile(
                                        title: const Text('Di Batalkan'),
                                        onTap: () => Navigator.pop(
                                            context, 'Di Batalkan'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );

                            if (selectedStatus != null) {
                              statusController.text = selectedStatus;
                              (context as Element).markNeedsBuild();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    statusController.text.isEmpty
                                        ? 'Pilih Status Transaksi'
                                        : statusController.text,
                                    style: GoogleFonts.poppins(fontSize: 15),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ),
                        const Gap(30),
                        InkWell(
                          onTap: () async {
                            final fileName = fileNameController.text.trim();
                            final status = statusController.text.trim();
                            if (fileName.isEmpty) {
                              clearTextFields();
                              Navigator.pop(context);
                              showFailedAlert(context);
                            } else {
                              clearTextFields();
                              Navigator.pop(context);
                              showSuccessAlert(context, 'Berhasil');
                              await saveExcelFileWithDateRange(
                                  fileName, status);
                            }
                          },
                          child: Container(
                            height: 40,
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: greenColor,
                            ),
                            child: Center(
                              child: Text(
                                'Simpan',
                                style: GoogleFonts.poppins(color: whiteMerona),
                              ),
                            ),
                          ),
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
    );
  }

  static Future<void> saveExcelFileWithDateRange(
      String fileName, String status) async {
    Future<List<TransactionData>> getTransactionData() async {
      try {
        return await databaseService.getTransactionsByStatus(status);
      } catch (e) {
        debugPrint('Error fetching transactions: $e');
        return [];
      }
    }

    if (fileName.isEmpty) {
      debugPrint('Nama file tidak boleh kosong');
    } else {
      var excel = Excel.createExcel();
      var sheet = excel['Sheet1'];

      // Header Excel
      sheet.cell(CellIndex.indexByString('A1')).value = 'Transaction ID';
      sheet.cell(CellIndex.indexByString('B1')).value = 'Transaction Date';
      sheet.cell(CellIndex.indexByString('C1')).value = 'Transaction Status';
      sheet.cell(CellIndex.indexByString('D1')).value = 'Customer Name';
      sheet.cell(CellIndex.indexByString('E1')).value = 'Transaction Product';
      sheet.cell(CellIndex.indexByString('F1')).value = 'Transaction Total';
      sheet.cell(CellIndex.indexByString('G1')).value = 'Discount';
      sheet.cell(CellIndex.indexByString('H1')).value = 'Pay Amount';
      sheet.cell(CellIndex.indexByString('I1')).value = 'Profit';

      List<TransactionData> transactions = await getTransactionData();

      // Filter by date range
      transactions = transactions.where((transaction) {
        String dateStr = transaction.transactionDate.split(', ')[1];
        DateTime transactionDate =
            DateFormat("dd/MM/yyyy HH:mm").parse(dateStr).toLocal();
        DateTime startDate =
            DateTime(fromDate.year, fromDate.month, fromDate.day, 0, 0, 0)
                .toLocal();
        DateTime endDate =
            DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59)
                .toLocal();
        return (transactionDate.isAfter(startDate) ||
                transactionDate.isAtSameMomentAs(startDate)) &&
            (transactionDate.isBefore(endDate) ||
                transactionDate.isAtSameMomentAs(endDate));
      }).toList();

      int rowIndex = 2;

      for (TransactionData transaction in transactions) {
        // Ensure transactionProduct is processed correctly
        debugPrint(
            'Processing transaction product for transaction ID: ${transaction.transactionId}');

        List<String> products = (transaction.transactionProduct as List)
            .map((e) => e['product_name'].toString())
            .toList();

        for (int j = 0; j < products.length; j++) {
          if (j == 0) {
            sheet.cell(CellIndex.indexByString('A$rowIndex')).value =
                transaction.transactionId;
            sheet.cell(CellIndex.indexByString('B$rowIndex')).value =
                transaction.transactionDate;
            sheet.cell(CellIndex.indexByString('C$rowIndex')).value =
                transaction.transactionStatus;
            sheet.cell(CellIndex.indexByString('D$rowIndex')).value =
                transaction.transactionCustomerName;
            sheet.cell(CellIndex.indexByString('E$rowIndex')).value =
                transaction.transactionProduct.toString();
            sheet.cell(CellIndex.indexByString('F$rowIndex')).value =
                transaction.transactionTotal;
            sheet.cell(CellIndex.indexByString('G$rowIndex')).value =
                transaction.transactionDiscount;
            sheet.cell(CellIndex.indexByString('H$rowIndex')).value =
                transaction.transactionPayAmount;
            sheet.cell(CellIndex.indexByString('I$rowIndex')).value =
                transaction.transactionProfit;
          }
          rowIndex++;
        }
      }

      List<int>? fileBytes = excel.save();
      if (fileBytes != null) {
        final directory = await getExternalStorageDirectory();
        final filePath = join(directory!.path, '$fileName.xlsx');
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);
        debugPrint('File berhasil disimpan di $filePath');
      }
    }
  }

  static Future<void> modalsDeleteHistoryTransaksi(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Spacer(),
                      Text(
                        'Hapus Transaksi',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Gap(30),
                  StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return WidgetDateFromTo(
                        initialStartDate: fromDate,
                        initialEndDate: toDate,
                        onDateRangeChanged: (start, end) {
                          setState(() {
                            fromDate = start;
                            toDate = end;
                          });
                        },
                      );
                    },
                  ),
                  const Gap(20),
                  Container(
                    height: 40,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: greenColor,
                    ),
                    child: Center(
                      child: Text(
                        'Hapus',
                        style: GoogleFonts.poppins(color: whiteMerona),
                      ),
                    ),
                  ),
                  Gap(10),
                  Container(
                    height: 40,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: redColor,
                    ),
                    child: Center(
                      child: Text(
                        'Hapus Semua Transaksi',
                        style: GoogleFonts.poppins(color: whiteMerona),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Fungsi untuk menampilkan dialog setting profit
  static Future<void> modalSettingProfit(BuildContext context) async {
    int selectedOption = 0;
    bool isExpanded = false;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Spacer(),
                        Text(
                          'Setting Profit',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const Gap(20),
                    InkWell(
                      onTap: () {
                        setState(() {
                          selectedOption = 1;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: selectedOption == 1
                              ? secondaryColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            if (selectedOption == 1)
                              const Icon(Icons.check, color: Colors.white),
                            const Gap(10),
                            Text(
                              'Profit = Omzet - modal',
                              style: GoogleFonts.poppins(
                                color: selectedOption == 1
                                    ? Colors.white
                                    : secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(10),
                    InkWell(
                      onTap: () {
                        setState(() {
                          selectedOption = 2;
                          isExpanded = !isExpanded;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: selectedOption == 2
                              ? secondaryColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            if (selectedOption == 2)
                              const Icon(Icons.check, color: Colors.white),
                            const Gap(10),
                            Flexible(
                              child: Text(
                                'Profit = Omzet - modal - pengeluaran',
                                style: GoogleFonts.poppins(
                                  color: selectedOption == 2
                                      ? Colors.white
                                      : secondaryColor,
                                ),
                                overflow: isExpanded
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                                maxLines: isExpanded ? null : 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(30),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        showSuccessAlert(context, 'Berhasil');
                      },
                      child: Container(
                        height: 40,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: greenColor,
                        ),
                        child: Center(
                          child: Text(
                            'Simpan',
                            style: GoogleFonts.poppins(color: whiteMerona),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static void modalSettingProfitSettingPage(
      BuildContext context, String? selectedProfit) async {
    bool isExpanded = false;

    final DatabaseService databaseService = DatabaseService.instance;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Spacer(),
                        Text(
                          'Setting Profit',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const Gap(20),
                    InkWell(
                      onTap: () {
                        setState(() {
                          selectedProfit = "omzetModal";
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: selectedProfit == "omzetModal"
                              ? secondaryColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            if (selectedProfit == "omzetModal")
                              const Icon(Icons.check, color: Colors.white),
                            const Gap(10),
                            Text(
                              'Profit = Omzet - modal',
                              style: GoogleFonts.poppins(
                                color: selectedProfit == "omzetModal"
                                    ? Colors.white
                                    : secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(10),
                    InkWell(
                      onTap: () {
                        setState(() {
                          selectedProfit = "omzetModalPengeluaran";
                          isExpanded = !isExpanded;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: selectedProfit == "omzetModalPengeluaran"
                              ? secondaryColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            if (selectedProfit == "omzetModalPengeluaran")
                              const Icon(Icons.check, color: Colors.white),
                            const Gap(10),
                            Flexible(
                              child: Text(
                                'Profit = Omzet - modal - pengeluaran',
                                style: GoogleFonts.poppins(
                                  color:
                                      selectedProfit == "omzetModalPengeluaran"
                                          ? Colors.white
                                          : secondaryColor,
                                ),
                                overflow: isExpanded
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                                maxLines: isExpanded ? null : 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(30),
                    InkWell(
                      onTap: () {
                        try {
                          if (selectedProfit == "omzetModal") {
                            databaseService.updateSettingProfit('omzetModal');
                          } else if (selectedProfit ==
                              "omzetModalPengeluaran") {
                            databaseService
                                .updateSettingProfit('omzetModalPengeluaran');
                          }

                          Navigator.pop(context, true);
                          showSuccessAlert(context, 'Berhasil');
                        } catch (e) {
                          showFailedAlert(context,
                              message: "Gagal menyimpan pengaturan profit");
                          return;
                        }
                      },
                      child: Container(
                        height: 40,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: greenColor,
                        ),
                        child: Center(
                          child: Text(
                            'Simpan',
                            style: GoogleFonts.poppins(color: whiteMerona),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Future<void> modalSort(BuildContext context) async {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
          child: Column(
            children: [
              const Gap(20),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: const BoxDecoration(),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sort_by_alpha_outlined),
                        Gap(5),
                        Text("Name A-Z"),
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: const BoxDecoration(),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sort_by_alpha_outlined),
                        Gap(5),
                        Text("Name Z-A"),
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: const BoxDecoration(),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_drop_up_sharp),
                        Gap(5),
                        Text("Terjual"),
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: const BoxDecoration(),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_drop_down_sharp),
                        Gap(5),
                        Text("Terjual"),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
