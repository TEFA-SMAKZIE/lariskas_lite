import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kas_mini_lite/providers/bluetoothProvider.dart';
import 'package:kas_mini_lite/services/authService.dart';
import 'package:kas_mini_lite/utils/colors.dart';
import 'package:kas_mini_lite/utils/successAlert.dart';
import 'package:kas_mini_lite/utils/toast.dart';
import 'package:kas_mini_lite/view/page/home/home.dart';
import 'package:kas_mini_lite/view/page/login.dart';
import 'package:kas_mini_lite/main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart'; // Import main.dart to access scaffoldMessengerKey

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();
  bool _hasAttemptedReconnect =
      false; // Pelacak apakah sudah mencoba koneksi ulang
  bool _hasAttemptedCheck = false;
  bool _hasNavigated = false; // Pelacak apakah navigasi sudah dilakukan

  @override
  void initState() {
    super.initState();
    _navigateToHome();

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (mounted) {
    //     _requestPermissions();
    //     _checkTokenSplashScreen();
    //     if (!_hasAttemptedReconnect) {
    //       _autoReconnectBluetooth();
    //     }
    //     // _checkInternetConnection();
    //   }
    // });

    // _autoReconnectBluetooth();
    // _checkInternetConnection();
  }

  // void checkTokenAndNavigate(BuildContext context) async {
  //   final authService = AuthService();
  //   final token = await authService.getToken();

  //   if (token != null && !authService.isTokenExpired(context, token)) {
  //     // Token valid, lanjutkan ke halaman utama
  //     Navigator.pushReplacement(
  //         context, MaterialPageRoute(builder: (_) => Home()));
  //   } else {
  //     // Token expired atau tidak ada, logout
  //     if (!_hasAttemptedCheck) {
  //       _hasAttemptedCheck = true;
  //       await authService.logout(context);
  //     }
  //   }
  // }

  // void checkTokenAndNavigate(BuildContext context) async {
  //   if (_hasNavigated) return; // Jika sudah navigasi, hentikan

  //   final authService = AuthService();
  //   final token = await authService.getToken();

  //   if (token != null && !authService.isTokenExpired(context, token)) {
  //       _navigateToHome();
  //   } else {
  //       await authService.logout(context);
  //         _navigateToLogin();
  //   }
  // }

  // Future<void> _checkTokenSplashScreen() async {
  //   final authService = AuthService();

  //   String? token = await _authService.getToken();
//   if (token == null || !authService.isTokenExpired(context, token)) {
  //     _navigateToLogin();
  //   } else {
  //     _navigateToHome();
  //   }
  // }

  // void _checkTokenSplashScreen() async {
  //   try {
  //     final token = await _authService.getToken();
  //     if (token != null && !_authService.isTokenExpired(context, token)) {
  //       print("Navigating to Home");
  //       _navigateToHome();
  //     } else {
  //       print("Navigating to Login");
  //       _navigateToLogin();
  //     }
  //   } catch (e) {
  //     print("Error checking token: $e");
  //     _navigateToLogin(); // Fallback ke halaman login
  //   }
  // }

  // void _navigateToLogin() {
  //   Future.delayed(Duration(seconds: 1), () {
  //     // Pastikan widget masih terpasang
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => LoginPage()),
  //     );
  //   });
  // }

  void _navigateToHome() {
    Future.delayed(Duration(seconds: 1), () {
      // Pastikan widget masih terpasang
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => Home(
                  isRedirectFromLogin: false,
                )),
      );
    });
  }

  // maintenance (belum beres)
  void _autoReconnectBluetooth() async {
    try {
      final bluetoothProvider =
          Provider.of<BluetoothProvider>(context, listen: false);
      await bluetoothProvider.reconnectToDevice(context);
      if (bluetoothProvider.isConnected) {
        _hasAttemptedReconnect = true;
        // print('Bluetooth reconnected successfully');
        // connectionToast(
        //   context,
        //   "Koneksi Bluetooth Berhasil!",
        //   "Berhasil terhubung ke perangkat Bluetooth.",
        //   isConnected: true,
        // );
      } else {
        _hasAttemptedReconnect = true;
        // print('Bluetooth reconnection attempt failed');
      }
    } catch (e) {
      _hasAttemptedReconnect = true;
      // print('Error during Bluetooth reconnection: $e');
      // connectionToast(
      //   context,
      //   "Koneksi Bluetooth Error!",
      //   "Terjadi kesalahan saat mencoba menghubungkan ke perangkat Bluetooth.",
      //   isConnected: false,
      // );
    }
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
      Permission.storage,
    ].request();

    statuses.forEach((permission, status) {
      print('$permission: $status');
    });

    if (statuses.values.every((status) => status.isGranted)) {
      print("All permissions granted.");
    } else {
      print("Some permissions were denied.");
    }
  }

  // check connection
  // Future<void> _checkInternetConnection() async {
  //   var connectivityResult = await (Connectivity().checkConnectivity());
  //   if (connectivityResult == ConnectivityResult.none) {
  //     print('No Internet Connection');
  //     connectionToast(
  //         context, "Koneksi Gagal!", "Anda tidak terhubung ke jaringan.",
  //         isConnected: false);
  //   } else {
  //     print('Internet Connected');
  //     connectionToast(context, "Koneksi Berhasil!",
  //         "Anda telah berhasil terhubung ke jaringan.",
  //         isConnected: true);
  //   }
  // }

  // check token
  // void startTokenCheck(BuildContext context) {
  //   final authService = AuthService();
  //   Timer.periodic(Duration(seconds: 1), (timer) async {
  //     final token = await authService.getToken();
  //     if (token == null || authService.isTokenExpired(token)) {
  //       timer.cancel(); // Stop the timer if the token is expired
  //       await authService.logout(context);
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment(0, 2),
          end: Alignment(-0, -2),
        ),
      ),
      child: Center(
          child: Stack(
        children: [
          Opacity(
            opacity: 0.2,
            child: Image.asset(
              'assets/images/bg-splash-screen-without-opacity.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'LarisKas',
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const Gap(20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Container(
                    width: 150,
                    child: LinearProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      )),
    ));
  }
}
