import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kas_mini_lite/services/database_service.dart';
import 'package:kas_mini_lite/utils/alert.dart';
import 'package:kas_mini_lite/utils/colors.dart';
import 'package:kas_mini_lite/utils/responsif/fsize.dart';
import 'package:kas_mini_lite/view/widget/back_button.dart';
import 'package:kas_mini_lite/view/widget/custom_textfield.dart';
import 'package:intl/intl.dart';

class InputExpensePage extends StatefulWidget {
  const InputExpensePage({super.key});

  @override
  State<InputExpensePage> createState() => _InputExpensePageState();
}

class _InputExpensePageState extends State<InputExpensePage> {
  final DatabaseService _databaseService = DatabaseService.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  Future<void> tambahPengeluaran() async {
    final expenseName = nameController.text.trim();
    final expenseNote = noteController.text.trim();
    final expenseAmount = amountController.text.replaceAll('.', '').trim();

    if (expenseName.isEmpty || expenseNote.isEmpty || expenseAmount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ada input yang harus diisi!')),
      );
      return;
    }

    try {
      await _databaseService.addExpense(
        expenseName,
        selectedDate.toIso8601String(),
        expenseNote,
        selectedDate.toIso8601String(),
        int.parse(expenseAmount),
      );

      Navigator.pop(context, true);
    } catch (e) {
      showErrorDialog(context, 'Gagal menambahkan pengeluaran: $e');
    }
  }

  TextInputFormatter currencyInputFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      final formatter = NumberFormat.currency(
        locale: 'id',
        symbol: '',
        decimalDigits: 0,
      );
      String newText = newValue.text.replaceAll('.', '');
      if (newText.isNotEmpty) {
        newText = formatter.format(int.parse(newText));
      }
      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: const CustomBackButton(),
        title: Text(
          'TAMBAH PENGELUARAN',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
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
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const TextFieldLabel(label: 'Nama Pengeluaran'),
                                CustomTextField(
                                  fillColor: Colors.grey[200],
                                  obscureText: false,
                                  hintText: "Nama Pengeluaran...",
                                  prefixIcon: null,
                                  controller: nameController,
                                  maxLines: null,
                                  suffixIcon: null,
                                ),
                                const Gap(10),
                                const TextFieldLabel(label: 'Catatan'),
                                CustomTextField(
                                  fillColor: Colors.grey[200],
                                  obscureText: false,
                                  hintText:
                                      "Catatan tentang pengeluaran ini...",
                                  prefixIcon: null,
                                  controller: noteController,
                                  maxLines: 5,
                                  suffixIcon: null,
                                ),
                                const Gap(10),
                                const TextFieldLabel(label: 'Nominal'),
                                CustomTextField(
                                  fillColor: Colors.grey[200],
                                  obscureText: false,
                                  hintText: null,
                                  prefixIcon: null,
                                  controller: amountController,
                                  maxLines: null,
                                  suffixIcon: null,
                                  prefixText: "Rp. ",
                                  keyboardType: TextInputType.number,
                                  inputFormatter: [currencyInputFormatter()],
                                ),
                                const Gap(10),
                                const TextFieldLabel(
                                    label: 'Tanggal Pengeluaran'),
                                GestureDetector(
                                  onTap: () async {
                                    final DateTime? picked =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: selectedDate,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2101),
                                    );
                                    if (picked != null &&
                                        picked != selectedDate) {
                                      setState(() {
                                        selectedDate = picked;
                                      });
                                    }
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 15,
              left: 10,
              right: 10,
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
                child: Container(
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: primaryColor),
                          child: TextButton(
                            onPressed: () async {
                              await tambahPengeluaran();
                            },
                            child: const Text(
                              "SIMPAN",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TextFieldLabel extends StatelessWidget {
  final String label;

  const TextFieldLabel({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
