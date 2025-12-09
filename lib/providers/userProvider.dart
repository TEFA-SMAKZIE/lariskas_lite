import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:kas_mini_lite/model/serialNumberPayload.dart';
import 'package:kas_mini_lite/model/tokenPayload.dart';
import 'package:kas_mini_lite/services/userService.dart';

class UserProvider with ChangeNotifier {
  final _storage = FlutterSecureStorage();

  TokenPayload? _payload;


  TokenPayload? get payload => _payload;

  set payload(TokenPayload? value) {
    _payload = value;
    notifyListeners();
  }


  Future<void> fetchAndDecodeToken() async {
    try {
      String? token = await _storage.read(key: "token");
      if (token != null) {
        if (token.isNotEmpty) {
          Map<String, dynamic> payload = Jwt.parseJwt(token);
          print(payload);
          this.payload = TokenPayload.fromJson(payload);
        } else {
          print("Token is empty");
        }
      } else {
        print("Token not found");
      }
    } catch (e) {
      print("Error decoding token: $e");
    }
  }

  SerialNumberPayload? _serialNumberData;

  SerialNumberPayload? get serialNumberData => _serialNumberData;

  set serialNumberData(SerialNumberPayload? value) {
    _serialNumberData = value;
    notifyListeners();
  }

  Future<void> getSerialNumberAsUser(BuildContext context) async {
    try {
      final dataString = await UserService().getSerialNumberAsUserData(context);

      // Simpan data ke variabel jika getSerialNumberAsUserData returns data
      // Uncomment and modify the following line if the method is updated to return data:
      // _serialNumberData = dataString;

      // Perbarui serialNumberPayload jika diperlukan
      this.serialNumberData = SerialNumberPayload.fromJson(dataString);

      debugPrint("serialNumberData: $_serialNumberData");
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
  }
}
