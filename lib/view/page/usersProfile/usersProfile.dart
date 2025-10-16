import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bi.dart';
import 'package:iconify_flutter/icons/ion.dart';
import 'package:iconify_flutter/icons/mdi_light.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kas_mini_flutter_app/providers/userProvider.dart';
import 'package:kas_mini_flutter_app/services/userService.dart';
import 'package:kas_mini_flutter_app/utils/checkToken.dart';
import 'package:kas_mini_flutter_app/utils/colors.dart';
import 'package:kas_mini_flutter_app/utils/image.dart';
import 'package:kas_mini_flutter_app/utils/responsif/fsize.dart';
import 'package:kas_mini_flutter_app/utils/toast.dart';
import 'package:kas_mini_flutter_app/view/widget/back_button.dart';
import 'package:kas_mini_flutter_app/view/widget/expensiveFloatingButton.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  static bool isDefaultImage = false;
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _selectCameraOrGalery() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () async {
                Navigator.of(context).pop();
                await pickImage(ImageSource.camera);
              },
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
              onTap: () => pickImage(ImageSource.gallery),
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

  Future pickImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage == null) return;

      final imageTemporary = File(pickedImage.path);
      setState(() => this.image = imageTemporary);

      final croppedImage = await cropImage(imageTemporary);

      if (croppedImage != null) {
        setState(() {
          image = croppedImage;
        });
      }
      print("image: $image");
    } on PlatformException catch (e) {
      print("Error: $e");
    }
  }

  File? image;
  String noImage = "assets/products/no-image.png";
  String? userProfileFromApi;
  String? userProfileFromApiBackup;
  bool isNoImage = false;

  late TextEditingController serialNumberController;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneNumberController;

  final userService = UserService();
  @override
  void initState() {
    super.initState();

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    serialNumberController = TextEditingController(
        text: userProvider.serialNumberData?.serialNumber ?? '');
    nameController =
        TextEditingController(text: userProvider.serialNumberData?.name ?? '-');
    emailController = TextEditingController(
        text: userProvider.serialNumberData?.email ?? '-');
    phoneNumberController = TextEditingController(
        text: userProvider.serialNumberData?.phoneNumber ?? "-");
    userProfileFromApi = userProvider.serialNumberData?.profileImage;
    userProfileFromApiBackup = userProvider.serialNumberData?.profileImage;

    print('PROFILE IMAGE: $userProfileFromApi');
  }

  @override
  void dispose() {
    serialNumberController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // var userProvider = Provider.of<UserProvider>(context);

    // serialNumberController = TextEditingController(
    //     text: userProvider.serialNumberData?.serialNumber ?? '');
    // nameController =
    //     TextEditingController(text: userProvider.serialNumberData?.name ?? '-');
    // emailController = TextEditingController(
    //     text: userProvider.serialNumberData?.email ?? '-');
    // phoneNumberController = TextEditingController(
    //     text: userProvider.serialNumberData?.phoneNumber ?? "-");

    // if (isNoImage == false) {
    //   userProfileFromApi = userProvider.serialNumberData?.profileImage;
    // } else {
    //   userProfileFromApi = null;
    // }
    // userProfileFromApiBackup = userProvider.serialNumberData?.profileImage;

    // print('PROFILE IMAGE: $userProfileFromApi');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const CustomBackButton(),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text(
          'PROFIL PENGGUNA',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: SizeHelper.Fsize_normalTitle(context),
            color: primaryColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
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
                          child: Builder(
                            builder: (context) {
                              if (image != null) {
                                // Jika gambar berasal dari file lokal
                                return Image.file(
                                  image!,
                                  width: 180,
                                  height: 180,
                                  fit: BoxFit.cover,
                                );
                              } else {
                                if (userProfileFromApi != null) {
                                  return CachedNetworkImage(
                                      imageUrl: userProfileFromApi!,
                                      width: 180,
                                      height: 180,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                            noImage,
                                            width: 180,
                                            height: 180,
                                            fit: BoxFit.cover,
                                          ));
                                } else {
                                  return Image.asset(
                                    noImage,
                                    width: 180,
                                    height: 180,
                                    fit: BoxFit.cover,
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ),
                      if (userProfileFromApi != null || image != null)
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
                                setState(() {
                                  isNoImage = true;
                                  image = null;
                                  print('image: $image');
                                  userProfileFromApi = null;
                                  print(
                                      'user profile api: $userProfileFromApi');
                                });
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
              Gap(20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    CustomTextField(
                      fillColor: Colors.grey[200],
                      hintText: "Serial Number",
                      icon: FontAwesomeIcons.eye,
                      controller: serialNumberController,
                      enabled: false,
                    ),
                    CustomTextField(
                      fillColor: Colors.grey[200],
                      hintText: "Nama",
                      icon: FontAwesomeIcons.user,
                      controller: nameController,
                    ),
                    CustomTextField(
                      fillColor: Colors.grey[200],
                      hintText: "Email",
                      icon: FontAwesomeIcons.envelope,
                      controller: emailController,
                    ),
                    CustomTextField(
                      fillColor: Colors.grey[200],
                      hintText: "No Telepon",
                      icon: FontAwesomeIcons.phone,
                      controller: phoneNumberController,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ExpensiveFloatingButton(
          isPositioned: true,
          onPressed: () async {
            File imageFile;
            if (isNoImage == true || image == null) {
              imageFile = await getAssetAsFile(noImage);
            } else if (image != null) {
              imageFile = image!;
            } else {
              print("Error: Image is null");
              return;
            }
            userService.updateSerialNumberDetails(
              context,
              nameController.text,
              emailController.text,
              phoneNumberController.text,
              imageFile,
            );
          },
          text: "SIMPAN",
        ),
      ),
    );
  }

  // IMPORTANT!! DIGUNAKAN UNTUK CONVERT DARI ASSET KE FILE (noImage issue)
  Future<File> getAssetAsFile(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/${assetPath.split('/').last}');
    await tempFile.writeAsBytes(byteData.buffer.asUint8List());
    return tempFile;
  }
}

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final Color? color;
  final TextEditingController? controller;
  final bool? enabled;

  CustomTextField(
      {required this.hintText,
      required this.icon,
      this.color,
      this.enabled,
      this.controller,
      Color? fillColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: color ?? Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          suffixIcon: Icon(icon, color: Colors.grey[700]),
        ),
      ),
    );
  }
}
