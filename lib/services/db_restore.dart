import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:kas_mini_lite/utils/alert.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

Future<void> requestStoragePermission() async {
  var status = await Permission.storage.request();
  if (!status.isGranted) {
    throw Exception('Izin akses penyimpanan ditolak');
  }
}

Future<void> restoreDB(BuildContext context) async {
  await requestStoragePermission();
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result == null) throw Exception('Tidak ada file yang dipilih');

    File zipFile = File(result.files.single.path!);
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    final appDir = await getExternalStorageDirectory();

    final productDir = Directory('${appDir!.path}/product');
    final tokoDir = Directory('${appDir.path}/toko');
    await productDir.create(recursive: true);
    await tokoDir.create(recursive: true);

    for (var file in archive) {
      if (file.isFile) {
        final filename = file.name;

        // Restore database
        if (filename == 'master_db.db') {
          final dbPath = await getDatabasesPath();
          final dbFile = File('$dbPath/master_db.db');
          await dbFile.writeAsBytes(file.content as List<int>);
          print('Database berhasil dipulihkan! $dbPath' );
          continue;
        }

        // Restore product images
        if (filename.startsWith('files/product/')) {
          final targetPath = '${productDir.path}/${filename.replaceFirst('files/product/', '')}';
          final outputFile = File(targetPath);
          await outputFile.create(recursive: true);
          await outputFile.writeAsBytes(file.content as List<int>);
          print('Gambar produk dipulihkan: $targetPath');
          continue;
        }

        // Restore toko images
        if (filename.startsWith('files/toko/')) {
          final targetPath = '${tokoDir.path}/${filename.replaceFirst('files/toko/', '')}';
          final outputFile = File(targetPath);
          await outputFile.create(recursive: true);
          await outputFile.writeAsBytes(file.content as List<int>);
          print('Gambar toko dipulihkan: $targetPath');
          continue;
        }

        // Jika file tidak dikenal
        print('File tidak dikenal dan dilewati: $filename');
      }
    }

    showStatusDialog(context, 'Data berhasil dipulihkan!');
  } catch (e) {
    showErrorDialog(context, 'Restore gagal, silakan hubungi admin!\n$e');
  }
}
