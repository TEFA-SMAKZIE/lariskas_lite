import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:kas_mini_flutter_app/utils/toast.dart';

class BluetoothProvider with ChangeNotifier {
  BluetoothDevice? _connectedDevice;
  BluetoothDevice? _connectingDevice;
  void setConnectingDevice(BluetoothDevice device) {
    _connectingDevice = device;
    notifyListeners();
  }

  bool _isConnected = false;

  BluetoothDevice? get connectedDevice => _connectedDevice;
  BluetoothDevice? get connectingDevice => _connectingDevice;
  bool get isConnected => _isConnected;

  /// Menghubungkan ke perangkat
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      _connectingDevice = device;
      notifyListeners();
      await device.connect();
      _connectedDevice = device;
      _isConnected = true;
      _connectingDevice = null;
      notifyListeners();
    } catch (e) {
      _connectingDevice = null;
      print("Gagal terhubung: $e");
      notifyListeners();
    }
  }

  /// Memutuskan koneksi
  Future<void> disconnectDevice() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
      _isConnected = false;
      notifyListeners();
    }
  }

  /// Menghubungkan ulang ke perangkat yang sebelumnya terhubung
  Future<void> reconnectToDevice(context) async {
    if (_connectedDevice != null) {
      try {
        notifyListeners();
        await _connectedDevice!.connect();
        _isConnected = true;

        notifyListeners();
      } catch (e) {
        print("Gagal menghubungkan ulang: $e");
        notifyListeners();
      }
    } else {
      _isConnected = false;
      // connectionToast(
      //   context,
      //   "Koneksi Bluetooth Gagal!",
      //   "Tidak dapat terhubung ke perangkat Bluetooth.",
      //   isConnected: false,
      // );
      print("Tidak ada perangkat yang sebelumnya terhubung.");
    }
  }
}
