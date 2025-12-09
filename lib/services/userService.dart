import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kas_mini_lite/constants/apiConstants.dart';
import 'package:kas_mini_lite/providers/userProvider.dart';
import 'package:kas_mini_lite/utils/loadingAlert.dart';
import 'package:kas_mini_lite/utils/null_data_alert.dart';
import 'package:kas_mini_lite/utils/successAlert.dart';
import 'package:provider/provider.dart';

class UserService {
  String _name = '';
  String _email = '';
  String _phoneNumber = '';

  // Getter untuk mendapatkan data user
  String get name => _name;
  String get email => _email;
  String get phoneNumber => _phoneNumber;

  // Method untuk mengubah nama
  void updateName(String newName) {
    _name = newName;
    debugPrint('Name updated to: $_name');
  }

  // Method untuk mengubah email
  void updateEmail(String newEmail) {
    _email = newEmail;
    debugPrint('Email updated to: $_email');
  }

  // Method untuk mengubah nomor telepon
  void updatePhoneNumber(String newPhoneNumber) {
    _phoneNumber = newPhoneNumber;
    debugPrint('Phone number updated to: $_phoneNumber');
  }

  final _storage = FlutterSecureStorage();

  Future<Map<String, dynamic>> getSerialNumberAsUserData(
      BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      String? serialNumber = userProvider.payload?.serialNumberId;
      print("serial number: $serialNumber");
      if (serialNumber == null || serialNumber.isEmpty) {
        throw Exception('Serial number is missing or invalid');
      }
      // Retrieve the token from secure storage
      String? token = await _storage.read(key: 'token');
      print(token);
      if (token == null) {
        throw Exception('Token not found');
      }

      // Add the token to the request headers for authentication
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await http.get(
          Uri.parse(
              '${ApiConstants.baseUrl}/api/serial-number/${serialNumber}'),
          headers: headers);

      if (response.statusCode == 200) {
        print('serial number: ${response.body}');
        final data = jsonDecode(response.body);
        print('serial number after json decoded: $data');
        return data;
      } else {
        print(serialNumber);
        print('Error: ${response.statusCode}, ${response.body}');
        throw Exception('Failed to fetch serial number data');
      }
    } catch (err) {
      debugPrint('Error occurred: $err');
      throw Exception('Failed to fetch serial number data: $err');
    }
  }

  Future<void> uploadProfileImage(File imageFile) async {
    final token = await _storage.read(key: 'token');
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imageFile.path),
    });

    final response = await Dio().post(
      '${ApiConstants.baseUrl}/api/serial-number',
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    final newImageUrl = response.data['data']['profileImage'];

    // simpan URL ke local storage / langsung pakai
  }

  Future<void> updateSerialNumberDetails(BuildContext context, String name,
      String email, String phoneNumber, File? image) async {
    try {
      showLoadingAlert(context);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      String? token = await _storage.read(key: 'token');
      if (token == null) {
        throw Exception('Token not found');
      }

      // Decode the token to extract the serial number
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid token format');
      }
      final payload = json
          .decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      final serialNumberId = payload['serialNumberId'];
      if (serialNumberId == null || serialNumberId.isEmpty) {
        throw Exception('Serial number is missing or invalid');
      }

      print("serialnumber id: $serialNumberId");

      // Buat form data untuk mengirimkan gambar dan data lainnya
      final formData = FormData.fromMap({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        if (image != null)
          'image': await MultipartFile.fromFile(image.path)
        else if (image != null && !image.toString().startsWith('http'))
          'image': image
      });

      // Validate image size if provided
      if (image != null) {
        final imageSize = await image.length();
        const maxSizeInBytes = 10 * 1024 * 1024; 
        if (imageSize > maxSizeInBytes) {
            showNullDataAlert(context, message: "Ukuran foto tidak boleh lebih dari 10 MB");
            return;
        }
      }

      print("Image Path: ${image?.path}");


      // Kirim permintaan ke API
      final response = await Dio().put(
        '${ApiConstants.baseUrl}/api/serial-number/$serialNumberId/update',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );  

      print("Form Data: ${formData.fields}");

      if (response.statusCode == 200) {
        debugPrint('Serial number details updated successfully');
        await userProvider.getSerialNumberAsUser(context);
              Navigator.of(context, rootNavigator: true).pop(); 
        showSuccessAlert(context, "Berhasil mengubah!");
      } else {
        debugPrint(
            'Failed to update serial number details: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error updating serial number details: $e');
    }
  }

  // Future<void> updateSerialNumberDetails(
  //     context, String name, String email, String phoneNumber) async {
  //   try {
  //     final userProvider = Provider.of<UserProvider>(context, listen: false);

  //     String? token = await _storage.read(key: 'token');
  //     if (token == null) {
  //       throw Exception('Token not found');
  //     }

  //     // Decode the token to extract the serial number
  //     final parts = token.split('.');
  //     if (parts.length != 3) {
  //       throw Exception('Invalid token format');
  //     }
  //     final payload = json
  //         .decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
  //     final serialNumberId = payload['serialNumberId'];
  //     if (serialNumberId == null || serialNumberId.isEmpty) {
  //       throw Exception('Serial number is missing or invalid');
  //     }

  //     print("serialnumber id: $serialNumberId");

  //     // Update the serial number details via the API
  //     final response = await http.put(
  //       Uri.parse(
  //           '${ApiConstants.baseUrl}/api/serial-number/$serialNumberId/update'),
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode({
  //         'name': name,
  //         'email': email,
  //         'phoneNumber': phoneNumber,
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       debugPrint('Serial number details updated successfully');
  //       await userProvider.getSerialNumberAsUser(context);
  //       showSuccessAlert(context, "Berhasil mengubah!");
  //     } else {
  //       debugPrint(
  //           'Failed to update serial number details: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     debugPrint('Error updating serial number details: $e');
  //   }
  // }

  Future<void> postSerialNumber(
      String name, String email, String phoneNumber) async {
    try {
      String? token = await _storage.read(key: 'token');
      print("JWT TOKEN:  ${token.toString()}");
      if (token == null) {
        throw Exception('Token not found');
      }

      // decode
      final parts = token.split('.');
      print("JWT TOKEN AFTER DECODE:  ${parts.toString()}");
      if (parts.length != 3) {
        throw Exception('Invalid token format');
      }
      final payload = json
          .decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      final extractedSerialNumber = payload['serialNumber'];
      print("Serial Number: ${extractedSerialNumber}");
      if (!extractedSerialNumber) {
        throw Exception('Serial number mismatch');
      }

      // Post the serial number to the API
      final response = await http.post(
          Uri.parse(
              'http://localhost:3000/api/serial-number/$extractedSerialNumber'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: {
            name: name,
            email: email,
            phoneNumber: phoneNumber
          });

      if (response.statusCode == 200) {
        debugPrint('Serial number posted successfully');
      } else {
        debugPrint('Failed to post serial number: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error posting serial number: $e');
    }
  }
}
