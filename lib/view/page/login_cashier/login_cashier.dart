import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kas_mini_lite/providers/appVersionProvider.dart';
import 'package:kas_mini_lite/providers/cashierProvider.dart';
import 'package:kas_mini_lite/utils/colors.dart';
import 'package:kas_mini_lite/utils/null_data_alert.dart';
import 'package:kas_mini_lite/view/page/cashier/add_cashier_page.dart';
import 'package:kas_mini_lite/view/page/cashier/update_cashier_page.dart';
import 'package:kas_mini_lite/view/page/login_cashier/select_cashier.dart';
import 'package:kas_mini_lite/view/page/print_resi/input_resi.dart';
import 'package:kas_mini_lite/view/widget/back_button.dart';
import 'package:kas_mini_lite/view/widget/custom_textfield.dart';
import 'package:kas_mini_lite/view/widget/pin_input.dart';
import 'package:kas_mini_lite/view/widget/primary_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginCashier extends StatefulWidget {
  const LoginCashier({super.key});

  @override
  _LoginCashierState createState() => _LoginCashierState();
}

class _LoginCashierState extends State<LoginCashier> {
  final TextEditingController _cashierController = TextEditingController();
  final TextEditingController _cashierPinController = TextEditingController();
  final TextEditingController _cashierIdController = TextEditingController();

  List<TextEditingController> pinControllers =
      List.generate(6, (index) => TextEditingController());

  bool? isSelected = false;
  String? appVersion;

  @override
  void initState() {
    var appVersionProvider = AppVersionProvider();
    appVersionProvider.getAppVersion().then((_) {
      setState(() {
        appVersion = appVersionProvider.appVersion;
      });
    });


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var cashierProvider = Provider.of<CashierProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: CustomBackButton(),
      ),
      resizeToAvoidBottomInset: true,
      backgroundColor: bgColor,
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Gap(50),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.poppins(
                          fontSize: 35,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        children: const [
                          TextSpan(text: 'Pilih Kasir'),
                        ],
                      ),
                    ),
                    const Gap(35),
                    Image.asset(
                      'assets/images/Cashier_Icon.png',
                      height: 100,
                    ),
                    const Gap(40),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: TextFieldLabel(label: 'Akun Kasir')),
                    ElevatedButton(
                      onPressed: () async {
                        final selectedCategory =
                            await Navigator.of(context).push(
                          PageRouteBuilder(
                            opaque: false,
                            pageBuilder:
                                (context, animation, secondaryAnimation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SelectCashier(),
                              );
                            },
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 1),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: SelectCashier(),
                              );
                            },
                          ),
                        );
                        print(selectedCategory);

                        if (selectedCategory != null) {
                          setState(() {
                            _cashierController.text =
                                selectedCategory['cashierName'];
                            _cashierPinController.text =
                                selectedCategory['cashierPin'].toString();
                            _cashierIdController.text =
                                selectedCategory['cashierId'];
                            isSelected = true;
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
                            _cashierController.text.isEmpty
                                ? "Pilih Kasir"
                                : _cashierController.text,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected != false) ...[
                      const Gap(10),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: TextFieldLabel(label: "Pin")),
                      PinInputWidget(controllers: pinControllers),
                      const Gap(10),
                      PrimaryButton(
                        onPressed: () {
                          String pin = pinControllers
                              .map((controller) => controller.text)
                              .join();
                          if (pin == _cashierPinController.text) {
                            void _saveCashierData(String cashierName,
                                String cashierPin, String cashierId) async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              Map<String, dynamic> cashierData = {
                                'cashierName': cashierName,
                                'cashierPin': cashierPin,
                                'cashierId': cashierId,
                              };

                              // CASHIER SHARED PREFERENCES
                              await prefs.setString(
                                  'cashierData', jsonEncode(cashierData));

                              print(cashierData);
                            }

                            _saveCashierData(
                                _cashierController.text,
                                _cashierPinController.text,
                                _cashierIdController.text);

                            cashierProvider
                                .loadCashierDataFromSharedPreferences();
                            cashierProvider.getCashierById(
                                int.parse(_cashierIdController.text));

                            Navigator.of(context).pop();
                            Navigator.pop(context);
                          } else {
                            showNullDataAlert(context,
                                message: "Pin Salah, Silahkan coba kembali.");
                          }
                        },
                        text: "Login",
                        widthPercent: 10,
                      ),
                    ] else ...[
                      Gap(0),
                    ],
                    const Gap(10),
                    if (cashierProvider.cashierData?['cashierName'] == 'Owner')
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddCashierPage()),
                          );
                        },
                        child: Text(
                          'Tambah Kasir?',
                          style: TextStyle(
                            color: Colors.blue[400],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              height: 40,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                  begin: Alignment(0, 2),
                  end: Alignment(-0, -2),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Versi $appVersion',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
