import 'dart:io';

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
import 'package:kas_mini_lite/model/product.dart';
import 'package:kas_mini_lite/model/settingProfit.dart';
import 'package:kas_mini_lite/providers/bluetoothProvider.dart';
import 'package:kas_mini_lite/providers/securityProvider.dart';
import 'package:kas_mini_lite/providers/settingProvider.dart';
import 'package:kas_mini_lite/services/database_service.dart';
import 'package:kas_mini_lite/services/db.copy.dart';
import 'package:kas_mini_lite/services/db_restore.dart';
import 'package:kas_mini_lite/utils/colors.dart';
import 'package:kas_mini_lite/utils/failedAlert.dart';
import 'package:kas_mini_lite/utils/image.dart';
import 'package:kas_mini_lite/utils/pinModalWithAnimation.dart';
import 'package:kas_mini_lite/utils/responsif/fsize.dart';
import 'package:kas_mini_lite/utils/successAlert.dart';
import 'package:kas_mini_lite/utils/toast.dart';
import 'package:kas_mini_lite/view/page/settings/paymentManagement.dart';
import 'package:kas_mini_lite/view/page/settings/scanDevicePrinter.dart';
import 'package:kas_mini_lite/view/page/settings/selectTemplate.dart';
import 'package:kas_mini_lite/view/widget/back_button.dart';
import 'package:kas_mini_lite/view/widget/custom_textfield.dart';
import 'package:kas_mini_lite/view/widget/expensiveFloatingButton.dart';
import 'package:kas_mini_lite/view/widget/pinModal.dart';
import 'package:kas_mini_lite/view/widget/queueActivation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _footerController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  final DatabaseService _databaseService = DatabaseService.instance;

  File? image;
  String noImage = "assets/products/no-image.png";
  String? currentImage;
  bool isSelectingImage = false;

  // profit
  String? _selectedProfit;

  // struk
  String? _selectedTemplateText;
  String? _selectedTemplate;
  String? _selectedTemplatePapperSize;

  // printer
  String? _printerDevice;
  bool? _isPrinterAutoCutOn = false;
  final bool _isPrinterConnected = false;
  bool? _isCashdrawerOn = false;
  bool? _isSoundOn = false;

  //* //* //* //* //* //* //*
  //? CONFIG: GLOBAL VARIABLE
  //?
  //?
  //?
  //?
  //* //* //* //* //* //* //*

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isCashdrawerOn = prefs.getBool('isCashdrawerOn') ?? false;
      _isPrinterAutoCutOn = prefs.getBool('isPrinterAutoCutOn') ?? false;
      _isSoundOn = prefs.getBool('isSoundOn') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isCashdrawerOn', _isCashdrawerOn!);
    await prefs.setBool('isPrinterAutoCutOn', _isPrinterAutoCutOn!);
    await prefs.setBool('isSoundOn', _isSoundOn!);
  }

  //* //* //* //* //* //* //*
  //? END
  //* //* //* //* //* //* //*

  int queueNumber = 1;
  bool isAutoReset = false;
  bool nonActivateQueue = false;

  Future<void> _loadQueueAndisAutoResetValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      queueNumber = prefs.getInt('queueNumber') ?? 1;
      isAutoReset = prefs.getBool('isAutoReset') ?? false;
      nonActivateQueue = prefs.getBool('nonActivateQueue') ?? false;
    });

    print('''
      loaded: 
      queueNumber: $queueNumber,
      isAutoReset: $isAutoReset
    ''');
  }

  @override
  void initState() {
    super.initState();
    _loadQueueAndisAutoResetValue();
    loadSettingProfile();
    loadSettingProfit();
    loadSettingTemplate();
    _loadSettings();
    _saveSettings();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  //* //* //* //* //* //* //*
  //? load Setting from db
  //?
  //?
  //?
  //?
  //* //* //* //* //* //* //*

  Future<void> loadAllSettingData() async {
    final settingData = await _databaseService.getAllSettings();

    setState(() {});
  }

  Future<void> loadSettingProfit() async {
    final settingProfit = await _databaseService.getSettingProfit();

    setState(() {
      _selectedProfit = settingProfit;
    });
    print(_selectedProfit);
  }

  Future<void> loadSettingTemplate() async {
    final settingTemplate = await _databaseService.getSettingReceipt();

    setState(() {
      _selectedTemplate = settingTemplate['settingReceipt'];
      _selectedTemplateText = settingTemplate['settingReceipt'] == 'default'
          ? 'Default'
          : "Tanpa Antrian";
      _selectedTemplatePapperSize = settingTemplate['settingReceiptSize'];
    });
    print(_selectedProfit);
  }

  //* //* //* //* //* //* //*
  //? END
  //* //* //* //* //* //* //*

  //* //* //* //* //* //* //*
  //? IMAGE
  //?
  //?
  //?
  //?
  //?
  //* //* //* //* //* //* //*

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

      isSelectingImage = true;
    } on PlatformException catch (e) {
      print("Error: $e");
    }
  }

  void _changeSettingProfit(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return Center(
              child: Container(
            color: Colors.white,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            width: 300,
            height: 180,
            padding: const EdgeInsets.all(16.0),
            child: Column(children: [
              Expanded(
                child: ListView.builder(
                  itemCount: itemProfit.length,
                  itemBuilder: (context, index) {
                    final settingProfit = itemProfit[index];

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _selectedProfit == settingProfit.profit
                                    ? greenColor
                                    : Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedProfit = settingProfit.profit;
                            });
                          },
                          child: Text(
                            settingProfit.profitText,
                            style: TextStyle(
                                color: _selectedProfit == settingProfit.profit
                                    ? Colors.white
                                    : Colors.black),
                          )),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () async {},
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Center(
                  child: Text(
                    "SIMPAN",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ]),
          ));
        });
  }

  void _selectCameraOrGalery(BuildContext buildContext) {
    showDialog(
      context: buildContext,
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

  //* //* //* //* //* //* //*
  //? END
  //* //* //* //* //* //* //*

  //* //* //* //* //* //* //*
  //? SETTING PROFILE
  //?
  //?
  //?
  //?
  //* //* //* //* //* //* //*

  Future<void> loadSettingProfile() async {
    final settingProfile = await _databaseService.getSettingProfile();

    setState(() {
      _nameController.text = settingProfile['settingName'] ?? '';
      _addressController.text = settingProfile['settingAddress'] ?? '';
      _footerController.text = settingProfile['settingFooter'] ?? '';
      currentImage = settingProfile['settingImage'] != noImage
          ? settingProfile['settingImage'] ?? noImage
          : noImage;
      if (currentImage != null && currentImage!.isNotEmpty) {
        image = File(currentImage!);
      }
      print('Name: ${_nameController.text}');
      print('Address: ${_addressController.text}');
      print('Footer: ${_footerController.text}');
      print('Current Image: $currentImage');
    });
  }

  Future<void> _updateSettingProfile() async {
    String finalImagePath = noImage;

    if (image == null) {
      // User explicitly removed image or no image exists
      finalImagePath = noImage;
      print("No image - using default placeholder");
    } else if (isSelectingImage) {
      // User picked a NEW image, need to save it
      final directory = await getExternalStorageDirectory();
      final tokoDir = Directory('${directory!.path}/toko');

      if (!await tokoDir.exists()) {
        await tokoDir.create(recursive: true);
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      final savedImage = await image!.copy('${tokoDir.path}/$fileName');
      finalImagePath = savedImage.path;
      print("New image saved at: $finalImagePath");
    } else {
      // User didn't pick a new image, use the existing one
      finalImagePath = currentImage ?? noImage;
      print("Using existing image: $finalImagePath");
    }

    try {
      await _databaseService.updateSettingProfile(_nameController.text,
          _addressController.text, _footerController.text, finalImagePath);

      setState(() {
        isSelectingImage = false;
        currentImage = finalImagePath;
      });

      showSuccessAlert(context, "Berhasil Memperbaharui Pengaturan Toko");
    } catch (e) {
      print("Update error: $e");
      showFailedAlert(context,
          message: "Ada kesalahan, silahkan hubungi Admin!.");
    }
  }

  //* //* //* //* //* //* //*
  //? END
  //* //* //* //* //* //* //*

  //* //* //* //* //* //* //*
  //? SWITCH
  //?
  //?
  //?
  //* //* //* //* //* //* //*

  Widget _buildSettingItem(
      String title, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: SizeHelper.Fsize_spaceBetweenTextAndButton(context)),
        ),
        Switch(
          value: value,
          onChanged: (newValue) async {
            onChanged(newValue);
            try {
              await _saveSettings();
              successToast(context, title, "Berhasil Mengubah $title");
            } catch (e) {
              showFailedAlert(context,
                  message: "Ada kesalahan, silakan lapor ke Admin!.");
            }
          },
          activeColor: Colors.white,
          activeTrackColor: primaryColor,
          inactiveTrackColor: greyColor,
          inactiveThumbColor: primaryColor,
        ),
      ],
    );
  }

  //* //* //* //* //* //* //*
  //? END
  //* //* //* //* //* //* //*

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    var bluetoothProvider = Provider.of<BluetoothProvider>(context);
    var settingProvider = Provider.of<SettingProvider>(
      context,
    );
    var securityProvider = Provider.of<SecurityProvider>(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: const CustomBackButton(),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text(
          'PENGATURAN',
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          _selectCameraOrGalery(context);
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
                                        tag: "settingImage",
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
                                        tag: "settingNoImage",
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
                                      isSelectingImage = false;
                                      // hanya variable image yang akan di kosongkan, tidak ada yang lain
                                      // jawaban: tidak, setState hanya digunakan untuk mengubah UI, tidak untuk mengisi variable. Kalau ingin mengisi variable, maka kita perlu mengisi variable nya secara langsung seperti di atas ini.
                                      setState(() {
                                        image = null;
                                        _imageController.text = '';
                                      });
                                    },
                                  ),
                                ),
                              ),
                            Positioned(
                              bottom: 10,
                              right: 10,
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

                    if (isSelectingImage != false)
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isSelectingImage = false;
                            image = File(currentImage!);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Center(
                          child: Text(
                            "Cancel",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Nama Toko',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const Gap(10),
                    CustomTextField(
                      maxLines: null,
                      fillColor: Colors.white,
                      suffixIcon: null,
                      obscureText: false,
                      hintText: 'Nama Toko...',
                      prefixIcon: null,
                      controller: _nameController,
                    ),
                    const Gap(10),
                    const _Label(
                      text: 'Alamat Lengkap Toko',
                    ),
                    const Gap(10),
                    CustomTextField(
                      suffixIcon: null,
                      fillColor: Colors.white,
                      obscureText: false,
                      hintText: 'Alamat Toko...',
                      prefixIcon: null,
                      controller: _addressController,
                      maxLines: 4,
                    ),
                    const Gap(10),
                    const _Label(text: 'Footer Message Toko'),
                    const Gap(10),
                    CustomTextField(
                      suffixIcon: null,
                      fillColor: Colors.white,
                      obscureText: false,
                      hintText: 'Footer Message...',
                      prefixIcon: null,
                      controller: _footerController,
                      maxLines: 4,
                    ),
                    const Gap(10),

                    //*
                    //! SETTING PROFIT
                    //!
                    //!
                    //!
                    //*

                    const _Label(text: "Setting Profit"),
                    const Gap(10),
                    ButtonPassingData(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            bool isExpanded = false;
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return Dialog(
                                  child: Container(
                                    width: 300,
                                    height: null,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Spacer(),
                                            Text(
                                              'Setting Profit',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            const Spacer(),
                                            InkWell(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Icon(Icons.close),
                                            ),
                                          ],
                                        ),
                                        const Gap(20),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              _selectedProfit = "omzetModal";
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color: _selectedProfit ==
                                                      "omzetModal"
                                                  ? primaryColor
                                                  : Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              children: [
                                                if (_selectedProfit ==
                                                    "omzetModal")
                                                  const Icon(Icons.check,
                                                      color: Colors.white),
                                                const Gap(10),
                                                Text(
                                                  'Profit = Omzet - modal',
                                                  style: GoogleFonts.poppins(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <=
                                                                400
                                                            ? 10
                                                            : 16,
                                                    color: _selectedProfit ==
                                                            "omzetModal"
                                                        ? Colors.grey[200]
                                                        : primaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const Gap(10),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              _selectedProfit =
                                                  "omzetModalPengeluaran";
                                              isExpanded = !isExpanded;
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color: _selectedProfit ==
                                                      "omzetModalPengeluaran"
                                                  ? primaryColor
                                                  : Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              children: [
                                                if (_selectedProfit ==
                                                    "omzetModalPengeluaran")
                                                  const Icon(Icons.check,
                                                      color: Colors.white),
                                                const Gap(10),
                                                Flexible(
                                                  child: Text(
                                                    'Profit = Omzet - modal - pengeluaran',
                                                    style: GoogleFonts.poppins(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .width <=
                                                                  400
                                                              ? 10
                                                              : 16,
                                                      color: _selectedProfit ==
                                                              "omzetModalPengeluaran"
                                                          ? Colors.grey[200]
                                                          : primaryColor,
                                                    ),
                                                    overflow: isExpanded
                                                        ? TextOverflow.visible
                                                        : TextOverflow.ellipsis,
                                                    maxLines:
                                                        isExpanded ? null : 1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const Gap(30),
                                        InkWell(
                                          onTap: () async {
                                            if (_selectedProfit == null) {
                                              showFailedAlert(context,
                                                  message:
                                                      "Pilih salah satu pengaturan profit terlebih dahulu");
                                              return;
                                            }

                                            try {
                                              if (_selectedProfit ==
                                                  "omzetModal") {
                                                await _databaseService
                                                    .updateSettingProfit(
                                                        'omzetModal');
                                              } else if (_selectedProfit ==
                                                  "omzetModalPengeluaran") {
                                                await _databaseService
                                                    .updateSettingProfit(
                                                        'omzetModalPengeluaran');
                                              }

                                              Navigator.pop(context, true);
                                              showSuccessAlert(
                                                  context, 'Berhasil');
                                              loadSettingProfit();
                                            } catch (e) {
                                              showFailedAlert(context,
                                                  message:
                                                      "Gagal menyimpan pengaturan profit");
                                              return;
                                            }
                                          },
                                          child: Container(
                                            height: 40,
                                            width: 100,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: greenColor,
                                            ),
                                            child: Center(
                                              child: Text(
                                                'Simpan',
                                                style: GoogleFonts.poppins(
                                                    color: whiteMerona),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      text: _selectedProfit == "omzetModal"
                          ? "Profit: Omzet - Modal"
                          : "Profit: Omzet - Modal - Pengeluaran",
                    ),
                    const Gap(10),
                    ButtonPassingData(
                      onPressed: () async {
                        final result = await Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const SelectTemplate(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                const begin = Offset(0.0, 1.0);
                                const end = Offset.zero;
                                const curve = Curves.ease;

                                var tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));

                                return SlideTransition(
                                  position: animation.drive(tween),
                                  child: child,
                                );
                              },
                            ));

                        if (result != null) {
                          setState(() {
                            _selectedTemplate = result['type'] as String?;
                            _selectedTemplateText =
                                result['typeText'] as String;
                            _selectedTemplatePapperSize = result['papperSize'];
                          });
                        }
                      },
                      text:
                          "Template Struk: $_selectedTemplateText | $_selectedTemplatePapperSize",
                    ),
                    const Gap(10),
                    ButtonPassingDataPrinter(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ScanDevicePrinter(),
                          ),
                        );


                      },

                      text: "Printer",
                      isConnectedText: (bluetoothProvider.isConnected)
                          ? "Terhubung ke ${bluetoothProvider.connectedDevice?.platformName ?? 'Ada kesalahan'}"
                                      .length >
                                  20
                              ? "${"Terhubung ke ${bluetoothProvider.connectedDevice?.platformName ?? 'Ada kesalahan'}".substring(0, 20)}..."
                              : "Terhubung ke ${bluetoothProvider.connectedDevice?.platformName ?? 'Ada kesalahan'}"
                          : MediaQuery.of(context).size.width <= 400
                              ? "Tidak Terhubung"
                              : "Tidak ada Printer yang Terhubung",
                      isConnected: bluetoothProvider.isConnected,
                    ),
                    const Gap(10),

                    //* //* //* //* //* //*
                    //! SETTING SOUND
                    //!
                    //!
                    //!
                    //* //* //* //* //* //*

                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     const Align(
                    //       alignment: Alignment.centerLeft,
                    //       child: _Label(text: "Pengaturan Suara"),
                    //     ),
                    //     const Divider(
                    //       indent: 0,
                    //       endIndent: 0,
                    //       thickness: 1,
                    //       color: Colors.black,
                    //     ),
                    //     Column(
                    //       children: [
                    //         _buildSettingItem('Sound', _isSoundOn ?? false,
                    //             (value) {
                    //           setState(() {
                    //             _isSoundOn = value;
                    //           });
                    //         }),
                    //       ],
                    //     )
                    //   ],
                    // ),

                    //* //* //* //* //* //* //*
                    //! END
                    //* //* //* //* //* //* //*

                    //*
                    //! SETTING PRINTER
                    //!
                    //!
                    //!
                    //*

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: _Label(text: "Pengaturan Printer"),
                        ),
                        const Divider(
                          indent: 0,
                          endIndent: 0,
                          thickness: 1,
                          color: Colors.black,
                        ),
                        Column(
                          children: [
                            // _buildSettingItem(
                            //     'Printer AutoCut', _isPrinterAutoCutOn ?? false,
                            //     (value) {
                            //   setState(() {
                            //     _isPrinterAutoCutOn = value;
                            //   });
                            // }),
                            _buildSettingItem(
                                'Cashdrawer', _isCashdrawerOn ?? false,
                                (value) {
                              setState(() {
                                _isCashdrawerOn = value;
                              });
                            }),
                          ],
                        )
                      ],
                    ),
                    //* //* //* //* //* //* //*
                    //! END
                    //* //* //* //* //* //* //*

                    //?

                    //?

                    //* //* //* //* //* //*
                    //! SETTING MORE
                    //!
                    //!
                    //!
                    //* //* //* //* //* //*

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: _Label(text: "Pengaturan Lainnya"),
                        ),
                        const Divider(
                          indent: 0,
                          endIndent: 0,
                          thickness: 1,
                          color: Colors.black,
                        ),
                        Column(
                          children: [
                            _spaceBetweenTextAndButton(
                                title: "Antrian",
                                buttonText: 'Kelola Antrian',
                                onPressed: () async {
                                  final result = await showModalQueueActivation(
                                      context,
                                      queueNumber,
                                      isAutoReset,
                                      nonActivateQueue);
                                  if (result != null) {
                                    print("queue: $result");

                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setInt(
                                        'queueNumber', result['queueNumber']);
                                    await prefs.setBool(
                                        'isAutoReset', result['isAutoReset']);
                                    await prefs.setBool('nonActivateQueue',
                                        result['nonActivateQueue']);
                                    setState(() {
                                      queueNumber = result['queueNumber'];
                                    });

                                    _loadQueueAndisAutoResetValue();
                                  }
                                }),
                            _spaceBetweenTextAndButton(
                              title: "Metode Pembayaran",
                              buttonText: 'Kelola Data',
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => PaymentManagement()));
                              },
                            ),
                          ],
                        )
                      ],
                    ),

                    //* //* //* //* //* //* //*
                    //! END
                    //* //* //* //* //* //* //*

                    //?

                    //* //* //* //* //* //*
                    //! SETTING MORE
                    //!
                    //!
                    //!
                    //!
                    //* //* //* //* //* //*
                    const Gap(10),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 13),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              List<Product> products = await _databaseService
                                  .getProducts(); // Punya productImage
                              await copyDatabaseToStorage(context, products);
                            },
                            child: _buttonImportExport(
                              iconify: Iconify(
                                MaterialSymbols.backup,
                                size: 30,
                              ),
                              text: "Backup",
                              onPressed: () {},
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              if (securityProvider.kunciRestoreData) {
                                showPinModalWithAnimation(
                                  context,
                                  pinModal: PinModal(onTap: () async {
                                    await restoreDB(context);
                                  }),
                                );
                              } else {
                                await restoreDB(context);
                              }
                            },
                            child: _buttonImportExport(
                              iconify: Iconify(
                                MaterialSymbols.settings_backup_restore_rounded,
                                size: 30,
                              ),
                              text: "Restore",
                              onPressed: () {},
                            ),
                          )
                        ],
                      ),
                    ),

                    //* //* //* //* //* //* //*
                    //! END
                    //* //* //* //* //* //* //*

                    const Gap(80),
                  ],
                ),
              ),
              ExpensiveFloatingButton(onPressed: () async {
                await _updateSettingProfile();
                await settingProvider.getSettingProfile();
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _buttonImportExport extends StatelessWidget {
  final Iconify iconify;
  final String text;
  final VoidCallback onPressed;

  const _buttonImportExport({
    super.key,
    required this.iconify,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        iconify,
        const Gap(10),
        Text(
          text,
          style: const TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
        )
      ],
    );
  }
}

class _spaceBetweenTextAndButton extends StatelessWidget {
  final String title;
  final String buttonText;
  final VoidCallback? onPressed;

  const _spaceBetweenTextAndButton({
    super.key,
    required this.title,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: SizeHelper.Fsize_spaceBetweenTextAndButton(context)),
        ),
        ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              backgroundColor: primaryColor,
              foregroundColor: whiteMerona,
              elevation: 0,
            ),
            child: Text(
              buttonText,
              style: TextStyle(
                  fontSize:
                      SizeHelper.Fsize_spaceBetweenTextAndButton(context)),
            ))
      ],
    );
  }
}

class ButtonPassingDataPrinter extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final String isConnectedText;
  final bool isConnected;

  const ButtonPassingDataPrinter({
    super.key,
    required this.onPressed,
    required this.text,
    required this.isConnectedText,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        minimumSize: const Size(0, 55),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // const Icon(
          //   Icons.abc,
          // ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  fontSize: SizeHelper.Fsize_spaceBetweenTextAndButton(context),
                  color: Colors.black),
            ),
          ),
          Text(
            isConnectedText,
            style: TextStyle(
                fontSize: SizeHelper.Fsize_spaceBetweenTextAndButton(context),
                color: isConnected ? greenColor : Colors.red),
          ),
          const Gap(10),
          const ArrowRight(),
        ],
      ),
    );
  }
}

class ArrowRight extends StatelessWidget {
  const ArrowRight({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Iconify(
      MaterialSymbols.arrow_forward_ios_rounded,
      size: 18,
    );
  }
}

class ButtonPassingData extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? text;

  const ButtonPassingData({
    super.key,
    this.onPressed,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        minimumSize: const Size(0, 55),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // const Icon(
          //   Icons.abc,
          // ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text ?? "None Selected",
              style: TextStyle(
                  fontSize: SizeHelper.Fsize_spaceBetweenTextAndButton(context),
                  color: Colors.black),
            ),
          ),
          const ArrowRight()
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(
              fontSize: SizeHelper.Fsize_settingLabel(context),
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
