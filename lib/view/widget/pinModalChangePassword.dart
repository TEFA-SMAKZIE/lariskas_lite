import 'package:flutter/material.dart';
import 'package:kas_mini_lite/utils/colors.dart';
import 'package:kas_mini_lite/utils/failedAlert.dart';
import 'package:kas_mini_lite/utils/null_data_alert.dart';
import 'package:kas_mini_lite/utils/successAlert.dart';
import 'package:kas_mini_lite/view/widget/pin_input.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinModalChangePassword extends StatefulWidget {
  final Widget? destination;
  final Function? onTap;

  const PinModalChangePassword({
    super.key,
    this.destination,
    this.onTap,
  });

  @override
  State<PinModalChangePassword> createState() => _PinModalChangePasswordState();
}

class _PinModalChangePasswordState extends State<PinModalChangePassword> {
  List<TextEditingController> pinControllers =
      List.generate(6, (index) => TextEditingController());

  int? securityPassword;
  int _step =
      0; // 0: masukkan PIN lama, 1: masukkan PIN baru, 2: konfirmasi PIN baru
  String _newPin = '';
  String _title = 'Masukkan PIN Lama';

  @override
  void initState() {
    super.initState();
    _loadSecurityPassword();
  }

  void _loadSecurityPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    securityPassword = prefs.getInt('securityPassword');

    // Jika belum ada PIN, langsung ke step buat PIN baru
    if (securityPassword == null) {
      setState(() {
        _step = 1;
        _title = 'Buat PIN Baru';
      });
    }
  }

  void _clearPinFields() {
    for (var controller in pinControllers) {
      controller.clear();
    }
  }

  String _getCurrentPin() {
    return pinControllers.map((controller) => controller.text).join();
  }

  Future<void> _saveNewPin(String pin) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('securityPassword', int.parse(pin));
  }

  void _handleSubmit() async {
    String pin = _getCurrentPin();

    if (pin.length < 6) {
      showNullDataAlert(context, message: "PIN harus 6 digit!");
      return;
    }

    switch (_step) {
      case 0: // Verifikasi PIN lama
        if (pin == securityPassword.toString()) {
          _clearPinFields();
          setState(() {
            _step = 1;
            _title = 'Masukkan PIN Baru';
          });
        } else {
          showFailedAlert(context, message: "PIN lama salah!");
          _clearPinFields();
        }
        break;

      case 1: // Masukkan PIN baru
        if (securityPassword != null && pin == securityPassword.toString()) {
          showNullDataAlert(context,
              message: "PIN baru tidak boleh sama dengan PIN lama!");
          _clearPinFields();
          return;
        }
        _newPin = pin;
        _clearPinFields();
        setState(() {
          _step = 2;
          _title = 'Konfirmasi PIN Baru';
        });
        break;

      case 2: // Konfirmasi PIN baru
        if (pin == _newPin) {
          await _saveNewPin(pin);
          if (!mounted) return;
          Navigator.of(context).pop();
          showSuccessAlert(context, "PIN berhasil diubah!");
        } else {
          showFailedAlert(context, message: "PIN tidak cocok! Silakan ulangi.");
          _clearPinFields();
          setState(() {
            _step = 1;
            _title = 'Masukkan PIN Baru';
            _newPin = '';
          });
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Column(
        children: [
          Text(
            _title,
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          if (_step > 0 && securityPassword != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index <= _step ? primaryColor : Colors.grey[300],
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
      content: PinInputWidget(controllers: pinControllers),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            elevation: 0,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'Batal',
            style: TextStyle(color: Colors.white),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            elevation: 0,
          ),
          onPressed: _handleSubmit,
          child: Text(
            _step == 2 ? 'Simpan' : 'Lanjut',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
