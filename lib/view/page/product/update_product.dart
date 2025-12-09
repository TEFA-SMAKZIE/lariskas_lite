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
import 'package:kas_mini_lite/model/code.dart';
import 'package:kas_mini_lite/model/product.dart';
import 'package:kas_mini_lite/providers/bluetoothProvider.dart';
import 'package:kas_mini_lite/providers/securityProvider.dart';
import 'package:kas_mini_lite/services/database_service.dart';
import 'package:kas_mini_lite/utils/colors.dart';
import 'package:kas_mini_lite/utils/formatters.dart';
import 'package:kas_mini_lite/utils/image.dart';
import 'package:kas_mini_lite/utils/null_data_alert.dart';
import 'package:kas_mini_lite/utils/printer_helper.dart';
import 'package:kas_mini_lite/utils/responsif/fsize.dart';
import 'package:kas_mini_lite/utils/toast.dart';
import 'package:kas_mini_lite/view/page/product/select_category.dart';
import 'package:kas_mini_lite/view/page/qr_code_scanner.dart';
import 'package:kas_mini_lite/view/widget/back_button.dart';
import 'package:kas_mini_lite/view/widget/custom_textfield.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class UpdateProductPage extends StatefulWidget {
  final Product? product;

  const UpdateProductPage({super.key, required this.product});

  @override
  State<UpdateProductPage> createState() => _UpdateProductPageState();
}

class _UpdateProductPageState extends State<UpdateProductPage> {
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
  final TextEditingController _productIdController = TextEditingController();

  // focus node for add category textfield
  final FocusNode _categoryFocusNode = FocusNode();

  File? image;

  void _validateImage() {
    if (image?.path == noImage) {
      setState(() {
        image = null;
      });
    }
  }

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

  void _checkboxChangeStatus() {
    if (widget.product!.productStock == 0) {
      _isChecked = true;
    } else {
      _isChecked = false;
    }
  }

  void _openCamera() {
    // Dummy function to simulate opening the camera
    print("Open Camera Functionality Triggered");
    // Here, you can integrate your camera opening logic
  }

  String _formatCurrency(double value) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(value);
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
                          _productBarcodeTextController.text.length > 20
                              ? '${_productBarcodeTextController.text.substring(0, 19)}...'
                              : _productBarcodeTextController.text,
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
                            itemQRCode[index].text;
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

    // auto format
    _productHargaBeliController.addListener(() {
      final formatter = NumberFormat.decimalPattern('id');
      int value =
          int.tryParse(_productHargaBeliController.text.replaceAll('.', '')) ??
              0;
      String newText = formatter.format(value);
      if (_productHargaBeliController.text != newText) {
        _productHargaBeliController.value =
            _productHargaBeliController.value.copyWith(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      }
    });

    // auto format hargaJual
    _productHargaJualController.addListener(() {
      final formatter = NumberFormat.decimalPattern('id');
      int value =
          int.tryParse(_productHargaJualController.text.replaceAll('.', '')) ??
              0;
      String newText = formatter.format(value);
      if (_productHargaJualController.text != newText) {
        _productHargaJualController.value =
            _productHargaJualController.value.copyWith(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      }
    });

    _validateImage();
    _checkboxChangeStatus();
    _productNameController.text = widget.product!.productName;
    _productIdController.text = widget.product!.productId.toString();
    _productBarcodeController.text = widget.product!.productBarcode;
    _productStockController.text = widget.product!.productStock.toString();
    _productSatuanController.text = widget.product!.productUnit;
    _productHargaBeliController.text =
        widget.product!.productPurchasePrice.toString();
    _productHargaJualController.text =
        widget.product!.productSellPrice.toString();
    _productCategoryController.text = widget.product!.categoryName ?? '';
    _productSoldController.text = widget.product!.productSold.toString();
    image = File(widget.product!.productImage);
    _productHargaBeliController.addListener(_calculateKeuntungan);
    _productHargaBeliController.addListener(_calculatePersentaseKeuntungan);
    _productHargaJualController.addListener(_calculateKeuntungan);
    _productHargaJualController.addListener(_calculatePersentaseKeuntungan);
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _productBarcodeController.dispose();
    _productStockController.dispose();
    _productHargaBeliController.dispose();
    _productHargaJualController.dispose();
    _productCategoryController.dispose();
    _productSoldController.dispose();
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
    final besarProfit =
        int.tryParse(_profitController.text.replaceAll('.', '')) ?? 0;
    final persentaseKeuntungan =
        hargaJual != 0 ? (besarProfit / hargaJual) * 100 : 0;
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

  Future<void> _updateProduct() async {
    final productName = _productNameController.text;
    final productBarcode = _productBarcodeController.text;
    final productStock = int.tryParse(_productStockController.text) ?? 0;
    final productSatuan = _productSatuanController.text;
    final productHargaBeli =
        int.tryParse(_productHargaBeliController.text.replaceAll('.', '')) ?? 0;
    final productHargaJual =
        int.tryParse(_productHargaJualController.text.replaceAll('.', '')) ?? 0;
    final productCategory = _productCategoryController.text;
    final productSold = int.tryParse(_productSoldController.text) ?? 0;
    //  image?.path ?? widget.product!.productImag

    String productImage;

    if (image == null ||
        image!.path.isEmpty ||
        widget.product?.productImage == 'assets/products/no-image.png') {
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

    if (productName.isEmpty ||
        productBarcode.isEmpty ||
        productSatuan.isEmpty ||
        productCategory.isEmpty) {
      showNullDataAlert(context,
          message: "Harap isi semua kolom yang wajib diisi!");
      return;
    }

    final updatedProduct = Product(
      productId: widget.product!.productId,
      productBarcode: productBarcode,
      productBarcodeType: widget.product!.productBarcodeType,
      productName: productName,
      productStock: productStock,
      productUnit: productSatuan,
      productSold: productSold,
      productPurchasePrice: productHargaBeli,
      productSellPrice: productHargaJual,
      productDateAdded: widget.product!.productDateAdded,
      productImage: productImage,
      categoryName: productCategory,
    );

    try {
      await _databaseService.updateProduct(updatedProduct);

      successToastFilledColor(context, "Produk", "Produk berhasil diperbarui!");

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memperbarui produk: $e")),
      );
    }
  }

  // productPurchasePrice: int.parse(_productHargaBeliController.text.replaceAll('.', '')),
  // productSellPrice: int.parse(_productHargaJualController.text.replaceAll('.', '')),
  // categoryId: selectedCategoryId, // Pastikan Anda memiliki ID kategori yang dipilih
  // productImage: image?.path ?? '', // Pastikan Anda memiliki gambar produk
  // dateAdded: DateTime.now().toIso8601String(),

  void createCategoryModal() {
    showDialog(
      context: context,
      builder: (context) {
        // Memberikan fokus ke TextField setelah dialog ditampilkan
        // Hal ini dilakukan agar pengguna dapat langsung mengetikkan nama kategori
        // tanpa harus mengklik TextField terlebih dahulu.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _categoryFocusNode.requestFocus();
        });
        return AlertDialog(
          backgroundColor: Colors.grey[300],
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Tambah Kategori',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _productCreateCategoryController,
                focusNode: _categoryFocusNode,
                decoration: InputDecoration(
                  labelText:
                      'Kategori', // Teks yang akan ditampilkan di atas hintText
                  hintText: 'Nama Kategori',
                  floatingLabelBehavior: FloatingLabelBehavior
                      .never, // Label tetap di dalam input field
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const Gap(5),
              ElevatedButton(
                  onPressed: () async {
                    final categoryName = _productCreateCategoryController.text;
                    if (categoryName.isNotEmpty) {
                      final db = await _databaseService.database;
                      final data = await db.rawQuery('''
                        SELECT *
                        FROM categories WHERE category_name = ?
                        ''', [categoryName]);

                      if (data.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Kategori sudah ada!")));
                      } else {
                        await _databaseService.addCategory(
                            categoryName, DateTime.now().toIso8601String());
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "Kategori berhasil ditambahkan! $categoryName")));
                      }
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "Kategori berhasil ditambahkan! $categoryName")));

                      // Fetch categories again to update the list
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Nama Kategori Tidak Boleh Kosong")));
                    }

                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                      backgroundColor: greenColor,
                      foregroundColor: Colors.white),
                  child: const Center(
                    child: Text(
                      "SIMPAN",
                      style: TextStyle(fontSize: 16),
                    ),
                  ))
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var bluetoothProvider = Provider.of<BluetoothProvider>(context);
    var securityProvider = Provider.of<SecurityProvider>(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: const CustomBackButton(),
        title: Text(
          image != null
              ? 'LIHAT PRODUK ${widget.product!.productName}'
              : 'LIHAT PRODUK ${widget.product!.productName}',
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
                        onTap: () {
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
                                    ? Hero(
                                        tag:
                                            "productImage_${widget.product!.productId}",
                                        child: Image.file(
                                          image!,
                                          width: 180,
                                          height: 180,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Image.asset(
                                              "assets/products/no-image.png",
                                              width: 180,
                                              height: 180,
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        ),
                                      )
                                    : Hero(
                                        tag: "productImage",
                                        child: Image.asset(
                                          "assets/products/no-image.png",
                                          width: 180,
                                          height: 180,
                                          fit: BoxFit.cover,
                                        ),
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
                        fillColor: Colors.grey[200],
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
                        fillColor: Colors.grey[200],
                        hintText: "Barcode",
                        hintStyle: const TextStyle(fontSize: 17),
                        prefixIcon: const Icon(Icons.barcode_reader),
                        suffixIcon: Container(
                          height: 57,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors
                                .grey[300], // Warna latar belakang abu-abu
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(8),
                                bottomRight: Radius.circular(
                                    8)), // Sudut yang melengkung
                          ),
                          child: IconButton(
                            icon: const Iconify(MaterialSymbols.barcode_scanner,
                                size: 30),
                            onPressed: scanQRCode,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                      ),
                      maxLines: 1,
                    ),
                    Column(
                      children: [
                        const Gap(8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                  elevation: 0,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: _showBarcodeModal,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _productBarcodeTextController.text.isEmpty
                                          ? 'Barcode Saja'
                                          : _productBarcodeTextController
                                                      .text.length >
                                                  10
                                              ? '${_productBarcodeTextController.text.substring(0, 11)}...'
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
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () {
                                      PrinterHelper.printCode(
                                          bluetoothProvider.connectedDevice!,
                                          codeType:
                                              _productBarcodeTypeController
                                                  .text,
                                          codeText:
                                              _productBarcodeController.text,
                                          productName:
                                              _productNameController.text,
                                          productPrice:
                                              _productHargaJualController.text);
                                    },
                                    child: const Row(
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
                    ),
                    const Gap(15),
                    const Text(
                      "Stock",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const Gap(10),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
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
                              fillColor: Colors.grey[200],

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
                      fillColor: Colors.grey[200],
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
                      fillColor: Colors.grey[200],
                      hintText: "Harga Beli",
                      prefixIcon: const Icon(Icons.money),
                      controller: _productHargaBeliController,
                      maxLines: 1,
                      prefixText: "Rp. ",
                      obscureText: false,
                      suffixIcon: null,
                      keyboardType: TextInputType.number,
                      inputFormatter: [currencyInputFormatter()],
                    ),
                    const Gap(15),
                    const Text(
                      "Harga Jual",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const Gap(10),
                    CustomTextField(
                        fillColor: Colors.grey[200],
                        hintText: "Harga Jual",
                        prefixIcon: const Icon(Icons.money),
                        controller: _productHargaJualController,
                        maxLines: 1,
                        prefixText: "Rp. ",
                        obscureText: false,
                        suffixIcon: null,
                        keyboardType: TextInputType.number,
                        inputFormatter: [currencyInputFormatter()]),
                    const Gap(15),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Keuntungan",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              const Gap(10),
                              CustomTextField(
                                fillColor: Colors.grey[200],
                                hintText: "Keuntungan",
                                prefixIcon: null,
                                controller: _profitController,
                                maxLines: 1,
                                prefixText: "Rp. ",
                                obscureText: false,
                                suffixIcon: null,
                                keyboardType: TextInputType.number,
                                inputFormatter: [currencyInputFormatter()],
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
                              const Text(
                                "Persentase Keuntungan",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              const Gap(10),
                              CustomTextField(
                                  fillColor: Colors.grey[200],
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
                              backgroundColor: Colors.grey[200],
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
                                const Icon(Icons.category,
                                    size: 20, color: Colors.black),
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
                            createCategoryModal();
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black,
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
                                color: Colors.black,
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
              if (!securityProvider.editProduk)
                Positioned(
                  bottom: 15,
                  left: 0,
                  right: 0,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 150.0, end: 0.0),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, value),
                        child: child,
                      );
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 50,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: primaryColor),
                            child: TextButton(
                              onPressed: () {
                                _updateProduct();
                              },
                              child: const Text(
                                "SIMPAN",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
