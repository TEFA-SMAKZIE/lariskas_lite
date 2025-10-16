// import 'package:flutter/material.dart';
// import 'package:kas_mini_flutter_app/services/authService.dart';
// import 'package:kas_mini_flutter_app/view/page/home/home.dart';
// import 'package:kas_mini_flutter_app/view/page/login.dart';

// class CheckTokenUtils {
//   static final AuthService _authService = AuthService();

//   static Future<bool> checkToken(BuildContext context) async {
//     try {
//       final token = await _authService.getToken();
//       print(token);
//       if ((token != null || token!.isEmpty) && !_authService.isTokenExpired(context, token)) {
//         print("Navigating to Home");
//         _navigateToHome(context);
//         return false;
//       } else {
//         print("Navigating to Login");
//         _navigateToLogin(context);
//         return true;
//       }
//     } catch (e) {
//       print("Error checking token: $e");
//       _navigateToLogin(context);
//       return false;
//     }
//   }

//   static void _navigateToLogin(BuildContext context) {
//     Future.delayed(Duration(seconds: 1), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => LoginPage()),
//       );
//     });
//   }

//   static void _navigateToHome(BuildContext context) {
//     Future.delayed(Duration(seconds: 1), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => Home()),
//       );
//     });
//   }
// }
