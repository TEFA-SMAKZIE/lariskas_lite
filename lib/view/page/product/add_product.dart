import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bi.dart';
import 'package:iconify_flutter/icons/ion.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:iconify_flutter/icons/mdi_light.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kas_mini_flutter_app/model/code.dart';
import 'package:kas_mini_flutter_app/providers/bluetoothProvider.dart';
import 'package:kas_mini_flutter_app/services/database_service.dart';
import 'package:kas_mini_flutter_app/utils/bluetoothAlert.dart';
import 'package:kas_mini_flutter_app/utils/colors.dart';
import 'package:kas_mini_flutter_app/utils/formatters.dart';
import 'package:kas_mini_flutter_app/utils/image.dart';
import 'package:kas_mini_flutter_app/utils/null_data_alert.dart';
import 'package:kas_mini_flutter_app/utils/printer_helper.dart';
import 'package:kas_mini_flutter_app/utils/responsif/fsize.dart';
import 'package:kas_mini_flutter_app/utils/toast.dart';
import 'package:kas_mini_flutter_app/view/page/product/select_category.dart';
import 'package:kas_mini_flutter_app/view/page/qr_code_scanner.dart';
import 'package:kas_mini_flutter_app/view/widget/add_category_modal.dart';
import 'package:kas_mini_flutter_app/view/widget/back_button.dart';
import 'package:kas_mini_flutter_app/view/widget/custom_textfield.dart';
import 'package:kas_mini_flutter_app/view/widget/expensiveFloatingButton.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  // db

  final DatabaseService _databaseService = DatabaseService.instance;

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productBarcodeController =
      TextEditingController();
  final TextEditingController _productStockController = TextEditingController();
  final TextEditingController _productSatuanController =
      TextEditingController();
  final TextEditingController _productHargaBeliController =
      TextEditingController(text: '0');
  final TextEditingController _productHargaJualController =
      TextEditingController(text: '0');
  final TextEditingController _productCreateCategoryController =
      TextEditingController();
  final TextEditingController _productCategoryController =
      TextEditingController();
  final TextEditingController _productBarcodeTypeController =
      TextEditingController(text: "barcode");
  final TextEditingController _productBarcodeTextController =
      TextEditingController(text: "Barcode Saja");
  final TextEditingController _profitController = TextEditingController();
  final TextEditingController _lossController = TextEditingController();
  final TextEditingController _productSoldController =
      TextEditingController(text: "0");

  // focus node for add category textfield
  final FocusNode _categoryFocusNode = FocusNode();

  File? image;
  bool _isBarcodeFilled = false;
  bool _isChecked = false;

  String noImage = "assets/products/no-image.png";

  void _checkBarcodeInput() {
    setState(() {
      _productBarcodeController.text.isNotEmpty
          ? _isBarcodeFilled = true
          : _isBarcodeFilled = false;
    });
  }

  void _handleCheckboxChange(bool? value) {
    setState(() {
      _isChecked = value ?? false;
      if (_isChecked) {
        _productStockController.text = '0';
      }
    });
  }

  String _formatCurrency(double value) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(value);
  }

  Future<void> scanQRCode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QrCodeScanner()),
    );

    if (result != null && mounted) {
      setState(() {
        _productBarcodeController.text = result;
        _checkBarcodeInput();
      });
    }
  }

  Future pickImage(ImageSource source, context) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      Navigator.pop(context);
      if (pickedImage == null) return;

      final imageTemporary = File(pickedImage.path);
      print(pickedImage);
      setState(() => this.image = imageTemporary);

      final croppedImage = await cropImage(imageTemporary);

      if (croppedImage != null) {
        setState(() {
          image = croppedImage;
        });
      }

    } on PlatformException catch (e) {
      print("Error: $e");
    }
  }

  void _selectCameraOrGalery() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => pickImage(ImageSource.camera, context),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Iconify(
                    MdiLight.camera,
                    size: 40,
                  ),
                  Gap(10),
                  Text(
                    "Kamera",
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            const Gap(15),
            const Divider(
              color: Colors.black,
              indent: 1.0,
            ),
            const Gap(15),
            GestureDetector(
              onTap: () => pickImage(ImageSource.gallery, context),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Iconify(
                    Ion.ios_albums_outline,
                    size: 40,
                  ),
                  Gap(15),
                  Text(
                    "Galeri",
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBarcodeModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Type Code',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Iconify(
                        Ion.close_circled,
                        color: Colors.white,
                        size: 20,
                      ))
                ],
              ),
              const Gap(10),
              Container(
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 14, 94, 134),
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.only(
                    top: 5, right: 10, bottom: 5, left: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Saat ini:',
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                        Text(
                          _productBarcodeTextController.text,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15),
                        )
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
          backgroundColor: const Color.fromARGB(255, 36, 99, 131),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: SingleChildScrollView(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: itemQRCode.length,
                itemBuilder: (context, index) {
                  return ZoomTapAnimation(
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        // ini untuk teks yang ada di button nya
                        _productBarcodeTextController.text =
                            itemQRCode[index].text;
                        // ini untuk teks yang akan di kirim lewat
                        _productBarcodeTypeController.text =
                            itemQRCode[index].type;
                      });
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                      ),
                      child: Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Center(
                                child: Image.asset(
                                  itemQRCode[index].image,
                                  width: 80,
                                  height: 80,
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            bottom: 10,
                            left: 0,
                            right: 0,
                            child: Text(
                              itemQRCode[index].text,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _productHargaBeliController.addListener(_calculateKeuntungan);
    _productHargaBeliController.addListener(_calculatePersentaseKeuntungan);
    _productHargaJualController.addListener(_calculateKeuntungan);
    _productHargaJualController.addListener(_calculatePersentaseKeuntungan);
  }

  @override
  void dispose() {
    _productHargaBeliController.removeListener(_calculateKeuntungan);
    _productHargaBeliController.removeListener(_calculatePersentaseKeuntungan);
    _productHargaJualController.removeListener(_calculateKeuntungan);
    _productHargaJualController.removeListener(_calculatePersentaseKeuntungan);
    _productHargaBeliController.dispose();
    _productHargaJualController.dispose();
    _profitController.dispose();
    _lossController.dispose();
    super.dispose();
  }

  void _calculateKeuntungan() {
    // Remove thousand separators before parsing
    final hargaBeli =
        int.tryParse(_productHargaBeliController.text.replaceAll('.', '')) ?? 0;
    final hargaJual =
        int.tryParse(_productHargaJualController.text.replaceAll('.', '')) ?? 0;
    final keuntungan = hargaJual - hargaBeli;
    _profitController.text =
        NumberFormat.decimalPattern('id').format(keuntungan);
  }

  void _calculatePersentaseKeuntungan() {
    final hargaJual =
        int.tryParse(_productHargaJualController.text.replaceAll('.', '')) ?? 0;
    final hargaBeli =
        int.tryParse(_productHargaBeliController.text.replaceAll('.', '')) ?? 0;
    final besarProfit =
        int.tryParse(_profitController.text.replaceAll('.', '')) ?? 0;
    final persentaseKeuntungan =
        hargaBeli != 0 ? (besarProfit / hargaBeli * 100) : 0;
    _lossController.text =
        '${NumberFormat.decimalPattern('id').format(persentaseKeuntungan)}%';
  }

//   void _createNewProduct() async {
//   final productName = _productNameController.text;
//   final productImage = image?.path ?? '';
//   final productBarcode = _productBarcodeController.text;
//   final productBarcodeType = _productBarcodeTypeController.text;
//   final productStock = _productStockController.text;
//   final productHargaBeli = _productHargaBeliController.text;
//   final productHargaJual = _productHargaJualController.text;
//   final productCategory = _productCategoryController.text;
//   final productSold = _productSoldController.text;

//   if (productName.isEmpty ||
//       productStock.isEmpty ||
//       productHargaBeli.isEmpty ||
//       productHargaJual.isEmpty ||
//       productCategory.isEmpty) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Semua field harus diisi!")),
//     );
//     return;
//   }

//   try {
//     final stock = int.parse(productStock);
//     final hargaBeli = int.parse(productHargaBeli.replaceAll('.', ''));
//     final hargaJual = int.parse(productHargaJual.replaceAll('.', ''));
//     final sold = int.parse(productSold);

//     print("Product Name: $productName");
//     print("Product Image: $productImage");
//     print("Product Barcode: $productBarcode");
//     print("Product Barcode Type: $productBarcodeType");
//     print("Product Stock: $stock");
//     print("Product Harga Beli: $hargaBeli");
//     print("Product Harga Jual: $hargaJual");
//     print("Product Category: $productCategory");

//     _databaseService.addProducts(
//       productName,
//       productImage,
//       productBarcode,
//       productBarcodeType,
//       stock,
//       hargaBeli,
//       hargaJual,
//       sold,
//       productCategory,
//       DateTime.now().toIso8601String(),
//     );

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Produk berhasil ditambahkan!")),
//     );
//     Navigator.pop(context);
//   } catch (e) {
//     print("Error: $e");
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Input tidak valid!")),
//     );
//   }
// }

  Future<void> _createNewProduct() async {
    String productImage;

    final productName = _productNameController.text;

    // Simpan gambar ke direktori yang diinginkan
    if (image == null || image!.path.isEmpty) {
      productImage = "assets/products/no-image.png";
    } else {
      final directory = await getExternalStorageDirectory();
      final productDir = Directory('${directory!.path}/product');
      if (!await productDir.exists()) {
        await productDir.create(recursive: true);
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      final savedImage = await image!.copy('${productDir.path}/$fileName');
      productImage = savedImage.path;
    }

    final productBarcode = _productBarcodeController.text;
    final productBarcodeType = _productBarcodeTypeController.text;
    final productStock = _productStockController.text;
    final productSatuan = _productSatuanController.text;
    final productHargaBeli = _productHargaBeliController.text;
    final productHargaJual = _productHargaJualController.text;
    final productDateAdded = DateTime.now().toIso8601String();
    final productCategory = _productCategoryController.text;
    final productSold = _productSoldController.text;

    if (productName.isEmpty ||
        productBarcode.isEmpty ||
        productBarcodeType.isEmpty ||
        productStock.isEmpty ||
        productHargaBeli.isEmpty ||
        productHargaJual.isEmpty ||
        productSatuan.isEmpty ||
        productCategory.isEmpty) {
     showNullDataAlert(context,
          message: "Harap isi semua kolom yang wajib diisi!");
      return;
    }

    try {
      _databaseService.addProducts(
        productImage,
        productName,
        productBarcode,
        productBarcodeType,
        int.parse(productStock),
        productSatuan,
        int.parse(productSold),
        int.parse(productHargaBeli.replaceAll('.', '')),
        int.parse(productHargaJual.replaceAll('.', '')),
        productCategory,
        productDateAdded,
      );

      successToastFilledColor(context, "Pemberitahuan!",
          "Berhasil Menambahkan Produk $productName");
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menambahkan Produk: $e")),
      );
    }
  }

  // productPurchasePrice: int.parse(_productHargaBeliController.text.replaceAll('.', '')),
  // productSellPrice: int.parse(_productHargaJualController.text.replaceAll('.', '')),
  // categoryId: selectedCategoryId, // Pastikan Anda memiliki ID kategori yang dipilih
  // productImage: image?.path ?? '', // Pastikan Anda memiliki gambar produk
  // dateAdded: DateTime.now().toIso8601String(),

  @override
  Widget build(BuildContext context) {
    var bluetoothProvider = Provider.of<BluetoothProvider>(context);
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        titleSpacing: 0,
        leading: const CustomBackButton(),
        title: Text(
          'TAMBAH PRODUK',
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
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          _selectCameraOrGalery();
                        },
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              margin: const EdgeInsets.all(25),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: image != null
                                    ? Image.file(
                                        image!,
                                        width: 180,
                                        height: 180,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        noImage,
                                        width: 180,
                                        height: 180,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            if (image != null)
                              Positioned(
                                top: 10,
                                right: 15,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Iconify(
                                      Bi.x,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                    onPressed: () {
                                      image = null;
                                      // hanya variable image yang akan di kosongkan, tidak ada yang lain
                                      // jawaban: tidak, setState hanya digunakan untuk mengubah UI, tidak untuk mengisi variable. Kalau ingin mengisi variable, maka kita perlu mengisi variable nya secara langsung seperti di atas ini.
                                      // setState(() {
                                      //   image = null;
                                      //   _imageController.text = '';
                                      // });

                                      setState(() {});
                                    },
                                  ),
                                ),
                              ),
                            Positioned(
                              bottom:
                                  10, // Adjust this value to move the button higher or lower
                              right:
                                  10, // Adjust this value to move the button left or right
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: const BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const IconButton(
                                  icon: Iconify(
                                    Bi.camera_fill,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  onPressed: null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(25),
                    const Text(
                      "Nama Produk",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const Gap(10),
                    CustomTextField(
                        fillColor: Colors.white,
                        obscureText: false,
                        hintText: "Nama Produk",
                        prefixIcon:
                            const Icon(Icons.add_shopping_cart_outlined),
                        controller: _productNameController,
                        maxLines: 1,
                        suffixIcon: null),
                    const Gap(15),
                    const Text(
                      "Barcode",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const Gap(10),
                    TextField(
                      onChanged: (value) {
                        _checkBarcodeInput();
                      },
                      controller: _productBarcodeController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Barcode",
                        hintStyle: const TextStyle(fontSize: 17),
                        prefixIcon: const Icon(Icons.barcode_reader),
                        suffixIcon: Container(
                          height: 57,
                          width: 60,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(8),
                                bottomRight: Radius.circular(
                                    8)), // Sudut yang melengkung
                          ),
                          child: IconButton(
                            icon: const Iconify(
                              MaterialSymbols.barcode_scanner,
                              size: 30,
                              color: Colors.white,
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
                          borderSide: const BorderSide(color: primaryColor),
                        ),
                      ),
                      maxLines: 1,
                    ),
                    _isBarcodeFilled
                        ? Column(
                            children: [
                              const Gap(8),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        elevation: 0,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: _showBarcodeModal,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _productBarcodeTextController
                                                    .text.isEmpty
                                                ? 'Barcode Saja'
                                                : _productBarcodeTextController
                                                            .text.length >
                                                        6
                                                    ? '${_productBarcodeTextController.text.substring(0, 7)}...'
                                                    : _productBarcodeTextController
                                                        .text,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const Icon(
                                              Icons.keyboard_arrow_down_rounded)
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Gap(5),
                                  Expanded(
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed: () {
                                            if (bluetoothProvider.isConnected) {
                                              PrinterHelper.printCode(
                                                  bluetoothProvider
                                                      .connectedDevice!,
                                                  codeType:
                                                      _productBarcodeTypeController
                                                          .text,
                                                  codeText:
                                                      _productBarcodeController
                                                          .text,
                                                  productName:
                                                      _productNameController
                                                          .text,
                                                  productPrice:
                                                      _productHargaJualController
                                                          .text);
                                            } else {
                                              showBluetoothAlert(context);
                                            }
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Iconify(
                                                Ion.printer,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              Gap(5),
                                              Expanded(
                                                child: Text(
                                                  "Cetak Barcode",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14),
                                                ),
                                              ),
                                            ],
                                          )))
                                ],
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                    const Gap(15),
                    const Text(
                      "Stock",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const Gap(10),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: CheckboxListTile(
                        value: _isChecked,
                        title: const Text(
                          'Tanpa Stok',
                          style: TextStyle(fontSize: 17),
                        ),
                        onChanged: _handleCheckboxChange,
                        activeColor: primaryColor,
                        // tileColor: Colors.grey[200],
                        // Membuat checkbox berada di kiri judul, bukan di kanan.
                        controlAffinity: ListTileControlAffinity.leading,
                        checkboxShape: const CircleBorder(),
                        // Fungsi ini akan dipanggil saat checkbox diubah nilainya.
                        // Fungsi ini digunakan untuk mengubah nilai _isChecked menjadi true atau false.
                        // Nilai _isChecked digunakan untuk menentukan apakah stok produk akan diinputkan atau tidak.
                        // Jika _isChecked bernilai true, maka stok produk tidak akan diinputkan.
                        // Jika _isChecked bernilai false, maka stok produk akan diinputkan.
                      ),
                    ),
                    const Gap(15),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: !_isChecked
                          ? CustomTextField(
                              fillColor: Colors.white,

                              key: ValueKey<bool>(_isChecked),
                              // Menggunakan ValueKey untuk memastikan widget diperbarui ketika nilai _isChecked berubah.
                              obscureText: false,
                              hintText: "Stok",
                              prefixIcon: const Icon(
                                  Icons.shopping_cart_checkout_outlined),
                              controller: _productStockController,
                              maxLines: 1,
                              keyboardType: TextInputType.number,
                              suffixIcon: null,
                            )
                          : null, // Empty container when _isChecked is true
                    ),
                    if (!_isChecked) const Gap(15),
                    const Text(
                      "Satuan Produk",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const Gap(10),
                    CustomTextField(
                      fillColor: Colors.white,
                      hintText: "Satuan Produk",
                      prefixIcon: const Icon(Icons.onetwothree),
                      controller: _productSatuanController,
                      maxLines: 1,
                      obscureText: false,
                      suffixIcon: null,
                    ),
                    const Gap(15),
                    const Text(
                      "Harga Beli",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const Gap(10),
                    CustomTextField(
                      fillColor: Colors.white,
                      hintText: "Harga Beli",
                      prefixIcon: const Icon(Icons.money),
                      controller: _productHargaBeliController,
                      maxLines: 1,
                      inputFormatter: [
                        FilteringTextInputFormatter.digitsOnly,
                        currencyInputFormatter(),
                      ],
                      prefixText: _productHargaBeliController.text.length <= 3
                          ? "Rp. "
                          : "Rp ",
                      obscureText: false,
                      suffixIcon: null,
                      keyboardType: TextInputType.number,
                    ),
                    const Gap(15),
                    const Text(
                      "Harga Jual",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const Gap(10),
                    CustomTextField(
                        fillColor: Colors.white,
                        hintText: "Harga Jual",
                        prefixIcon: const Icon(Icons.money),
                        controller: _productHargaJualController,
                        maxLines: 1,
                        prefixText: _productHargaJualController.text.length <= 3
                            ? "Rp. "
                            : "Rp ",
                        obscureText: false,
                        suffixIcon: null,
                        keyboardType: TextInputType.number,
                        inputFormatter: [
                          FilteringTextInputFormatter.digitsOnly,
                          currencyInputFormatter()
                        ]),
                    const Gap(15),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Keuntungan",
                                style: TextStyle(
                                    fontSize:
                                        SizeHelper.Fsize_productProfit(context),
                                    fontWeight: FontWeight.bold),
                              ),
                              const Gap(10),
                              CustomTextField(
                                fillColor: Colors.white,
                                hintText: "Keuntungan",
                                prefixIcon: null,
                                controller: _profitController,
                                maxLines: 1,
                                prefixText: _profitController.text.length <= 3
                                    ? "Rp. "
                                    : "Rp ",
                                obscureText: false,
                                suffixIcon: null,
                                keyboardType: TextInputType.number,
                                inputFormatter: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  currencyInputFormatter()
                                ],
                                readOnly: true,
                              ),
                            ],
                          ),
                        ),
                        const Gap(5),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Persentase Keuntungan",
                                style: TextStyle(
                                    fontSize:
                                        SizeHelper.Fsize_productProfit(context),
                                    fontWeight: FontWeight.bold),
                              ),
                              const Gap(10),
                              CustomTextField(
                                  fillColor: Colors.white,
                                  hintText: "Persentase Keuntungan",
                                  prefixIcon: null,
                                  controller: _lossController,
                                  maxLines: 1,
                                  obscureText: false,
                                  suffixIcon: null,
                                  keyboardType: TextInputType.number,
                                  readOnly: true,
                                  inputFormatter: [currencyInputFormatter()]),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Gap(15),
                    const Text(
                      "Kategori",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const Gap(10),
                    Row(
                      children: [
                        // Bagian Kiri
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SelectCategory()),
                              );

                              if (result != null) {
                                setState(() {
                                  _productCategoryController.text = result;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.grey[800],
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(13),
                                  bottomLeft: Radius.circular(13),
                                ),
                              ),
                              minimumSize: const Size(0, 55),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.category,
                                  size: 20,
                                  color: Colors.black,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _productCategoryController.text.isEmpty
                                        ? "Kategori"
                                        : _productCategoryController
                                                    .text.length >
                                                15
                                            ? '${_productCategoryController.text.substring(0, 15)}...'
                                            : _productCategoryController.text,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Bagian Kanan
                        ElevatedButton(
                          onPressed: () {
                            createCategoryModal(
                              context: context,
                              productCreateCategoryController:
                                  _productCreateCategoryController,
                              categoryFocusNode: _categoryFocusNode,
                              databaseService: _databaseService,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(13),
                                bottomRight: Radius.circular(13),
                              ),
                            ),
                            minimumSize: const Size(0, 55),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.add,
                                size: 20,
                                color: Colors.white,
                              ),
                              SizedBox(width: 5),
                              Text(
                                "Tambah",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Gap(78)
                  ],
                ),
              ),
              ExpensiveFloatingButton(
                onPressed: () => _createNewProduct(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
