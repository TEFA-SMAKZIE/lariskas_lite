import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:kas_mini_flutter_app/providers/bluetoothProvider.dart';
import 'package:kas_mini_flutter_app/utils/colors.dart';
import 'package:kas_mini_flutter_app/utils/null_data_alert.dart';
import 'package:kas_mini_flutter_app/utils/printer_helper.dart';
import 'package:kas_mini_flutter_app/utils/responsif/fsize.dart';
import 'package:kas_mini_flutter_app/view/page/home/home.dart';
import 'package:kas_mini_flutter_app/view/page/print_resi/select_expedition.dart';
import 'package:kas_mini_flutter_app/view/page/qr_code_scanner.dart';
import 'package:kas_mini_flutter_app/view/widget/back_button.dart';
import 'package:kas_mini_flutter_app/view/widget/custom_textfield.dart';
import 'package:kas_mini_flutter_app/view/widget/expensiveFloatingButton.dart';
import 'package:provider/provider.dart';

class InputResi extends StatefulWidget {
  const InputResi({super.key});

  @override
  State<InputResi> createState() => _InputResiState();
}

class _InputResiState extends State<InputResi> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController _expeditionController = TextEditingController();
  final TextEditingController _expeditionBarcodeController =
      TextEditingController();

  void _checkBarcodeInput() {
    setState(() {});
  }

  Future<void> scanQRCode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QrCodeScanner()),
    );

    if (result != null && mounted) {
      setState(() {
        _expeditionBarcodeController.text = result;
        _checkBarcodeInput();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var bluetoothProvider = Provider.of<BluetoothProvider>(context);

    return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          leading: const CustomBackButton(),
          backgroundColor: Colors.transparent,
          title: Text(
            'CETAK RESI',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: SizeHelper.Fsize_normalTitle(context),
              color: primaryColor,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TextFieldLabel(label: 'Ekspedisi'),
                  ElevatedButton(
                    onPressed: () async {
                      final selectedCategory =
                          await Navigator.of(context).push<String>(
                        PageRouteBuilder(
                          opaque: false,
                          pageBuilder:
                              (context, animation, secondaryAnimation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SelectExpedition(),
                            );
                          },
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 1),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            );
                          },
                        ),
                      );

                      if (selectedCategory != null) {
                        setState(() {
                          _expeditionController.text = selectedCategory;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.grey[800],
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(13)),
                      ),
                      minimumSize: const Size(0, 55),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          _expeditionController.text.isEmpty
                              ? "Pilih Ekspedisi"
                              : _expeditionController.text,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const Gap(10),
                  const TextFieldLabel(label: 'Nomor Resi'),
                  TextField(
                    onChanged: (value) {
                      _checkBarcodeInput();
                    },
                    controller: _expeditionBarcodeController,
                    decoration: InputDecoration(
                      filled: true,
                      hintText: "ABCDEFGHI..1234*#()",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      fillColor: Colors.white,
                      suffixIcon: Container(
                        height: 57,
                        width: 60,
                        decoration: const BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomRight: Radius.circular(8)),
                        ),
                        child: IconButton(
                          icon: const Iconify(
                            MaterialSymbols.barcode_scanner,
                            color: Color(0xffEFEFEF),
                            size: 30,
                          ),
                          onPressed: scanQRCode,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                    ),
                    maxLines: 1,
                  ),
                  const Gap(10),
                  const TextFieldLabel(label: 'Nama Pembeli'),
                  CustomTextField(
                    fillColor: Colors.white,
                    obscureText: false,
                    hintText: "Nama Pembeli...",
                    controller: nameController,
                    maxLines: null,
                    prefixIcon: null,
                    suffixIcon: null,
                    hintStyle: TextStyle(color: Colors.grey[400]),
                  ),
                  const Gap(10),
                  const TextFieldLabel(label: 'Keterangan'),
                  CustomTextField(
                    fillColor: Colors.white,
                    obscureText: false,
                    hintText: "Keterangan ABCD...",
                    controller: noteController,
                    maxLines: 5,
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: null,
                    suffixIcon: null,
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ExpensiveFloatingButton(
            isPositioned: true,
            onPressed: () async {
              if (_expeditionController.text.isEmpty) {
                showNullDataAlert(context,
                    message: "Pilih Ekspedisi terlebih dahulu");
                return;
              }

              if (bluetoothProvider.connectedDevice != null) {
                PrinterHelper.printResi(
                  bluetoothProvider.connectedDevice!,
                  expedition: _expeditionController.text,
                  receipt: _expeditionBarcodeController.text,
                  buyerName: nameController.text,
                  explanation: noteController.text,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No connected device found')),
                );
              }
            },
            text: "CETAK RESI",
          ),
        ));
  }
}

class TextFieldLabel extends StatelessWidget {
  final String label;

  const TextFieldLabel({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
