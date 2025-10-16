import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http; // Tambahkan ini
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:kas_mini_flutter_app/constants/apiConstants.dart';
import 'package:kas_mini_flutter_app/providers/userProvider.dart';
import 'package:kas_mini_flutter_app/utils/checkConnection.dart';
import 'dart:convert'; // Untuk JSON encoding/decoding
import 'package:kas_mini_flutter_app/utils/colors.dart';
import 'package:kas_mini_flutter_app/utils/loadingAlert.dart';
import 'package:kas_mini_flutter_app/utils/null_data_alert.dart';
import 'package:kas_mini_flutter_app/utils/responsif/fsize.dart';
import 'package:kas_mini_flutter_app/utils/successAlert.dart';
import 'package:kas_mini_flutter_app/utils/toast.dart';
import 'package:kas_mini_flutter_app/view/widget/back_button.dart';
import 'package:kas_mini_flutter_app/view/widget/custom_textfield.dart';
import 'package:kas_mini_flutter_app/view/widget/expensiveFloatingButton.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class ChangepasswordPage extends StatefulWidget {
  const ChangepasswordPage({super.key});

  @override
  State<ChangepasswordPage> createState() => _ChangepasswordPageState();
}

class _ChangepasswordPageState extends State<ChangepasswordPage> {
  final storage = FlutterSecureStorage();

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isNewPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  bool _isLoading = false;

  void clearForm() {
    _oldPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  Future<void> _changePassword(String serialNumberId) async {
    showLoadingAlert(context);
    setState(() {
      _isLoading = true;
    });

    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validasi password baru
    if (newPassword != confirmPassword) {
      showNullDataAlert(context,
          message: "Password baru dan konfirmasi password tidak cocok.");
      setState(() {
        _isLoading = false;
      });

      return;
    }
    if (newPassword.length < 8) {
      showNullDataAlert(context,
          message: "Password baru harus memiliki minimal 8 karakter.");
      setState(() {
        _isLoading = false;
      });

      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
            '${ApiConstants.baseUrl}/api/serial-number/$serialNumberId/change-password'),
        headers: {
          'Authorization': 'Bearer ${await storage.read(key: "token") ?? ""}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );

      final userProvider = UserProvider();

      userProvider.getSerialNumberAsUser(context);

      if (response.statusCode == 200) {
        showSuccessAlert(context, "Password berhasil diubah.");
        clearForm();
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context, rootNavigator: true).pop();
      } else {
        final responseBody = jsonDecode(response.body);
         Navigator.of(context, rootNavigator: true).pop();
        showNullDataAlert(context,
            message: responseBody['message'] ?? "Terjadi kesalahan.");
        setState(() {
          _isLoading = false;
        });
      }
    } on SocketException {
      Navigator.of(context, rootNavigator: true).pop();
      connectionToast(
          context, "Koneksi Gagal!", "Anda tidak terhubung ke jaringan.",
          isConnected: false);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: CustomBackButton(),
        backgroundColor: Colors.transparent,
        title: Text(
          'GANTI PASSWORD',
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
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: ClipRRect(
                        child: Image.asset(
                          'assets/images/logo-key.png',
                          width: 152,
                          height: 152,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 21),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Password Lama",
                          style: GoogleFonts.poppins(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                    ),
                    CustomTextField(
                      fillColor: Colors.grey[200],
                      hintText: "Masukan Password Lama",
                      suffixIcon: null,
                      obscureText: true,
                      prefixIcon: const Icon(Icons.password_rounded),
                      controller: _oldPasswordController,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Password Baru",
                          style: GoogleFonts.poppins(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                    ),
                    CustomTextField(
                      fillColor: Colors.grey[200],
                      hintText: "Masukan Password Baru",
                      suffixIcon: IconButton(
                        icon: _isNewPasswordObscured
                            ? const Iconify(Ic.twotone_visibility)
                            : Iconify(Ic.twotone_visibility_off),
                        onPressed: () {
                          setState(() {
                            _isNewPasswordObscured = !_isNewPasswordObscured;
                          });
                        },
                      ),
                      obscureText: _isNewPasswordObscured,
                      prefixIcon: const Icon(Icons.password_rounded),
                      controller: _newPasswordController,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Konfirmasi Password Baru",
                          style: GoogleFonts.poppins(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                    ),
                    CustomTextField(
                      fillColor: Colors.grey[200],
                      hintText: "Konfirmasi Password Baru",
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordObscured =
                                  !_isConfirmPasswordObscured;
                            });
                          },
                          icon: _isConfirmPasswordObscured
                              ? const Iconify(Ic.twotone_visibility)
                              : Iconify(Ic.twotone_visibility_off)),
                      obscureText: _isConfirmPasswordObscured,
                      prefixIcon: const Icon(Icons.password_rounded),
                      controller: _confirmPasswordController,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ExpensiveFloatingButton(
                  child: _isLoading == true
                      ? Lottie.asset(
                          'assets/lottie/loading-2.json',
                          width: 100,
                          height: 100,
                        )
                      : Text(
                          "SIMPAN",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize:
                                  SizeHelper.Fsize_expensiveFloatingButton(
                                      context)),
                        ),
                  onPressed: () async {
                    _changePassword(
                        userProvider.serialNumberData?.serialNumberId ?? '');
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
