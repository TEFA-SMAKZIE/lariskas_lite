import 'dart:async';
import 'dart:io';
import 'package:kas_mini_flutter_app/view/page/login.dart';
import 'package:sizer/sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:kas_mini_flutter_app/model/cashier.dart';
import 'package:kas_mini_flutter_app/model/transaction.dart';
import 'package:kas_mini_flutter_app/providers/cashierProvider.dart';
import 'package:kas_mini_flutter_app/providers/securityProvider.dart';
import 'package:kas_mini_flutter_app/providers/settingProvider.dart';
import 'package:kas_mini_flutter_app/providers/userProvider.dart';
import 'package:kas_mini_flutter_app/services/authService.dart';
import 'package:kas_mini_flutter_app/services/database_service.dart';
import 'package:kas_mini_flutter_app/utils/colors.dart';
import 'package:kas_mini_flutter_app/utils/pinModalWithAnimation.dart';
import 'package:kas_mini_flutter_app/utils/toast.dart';
import 'package:kas_mini_flutter_app/view/page/History_transaksi.dart';
import 'package:kas_mini_flutter_app/view/page/aboutapplication/applicationAbout.dart';
import 'package:kas_mini_flutter_app/view/page/addStockProduct/add_stock_product.dart';
import 'package:kas_mini_flutter_app/view/page/full_icon_page.dart';
import 'package:kas_mini_flutter_app/view/page/cashier/cashier_page.dart';
import 'package:kas_mini_flutter_app/view/page/cashier/update_cashier_from_home_page.dart';
import 'package:kas_mini_flutter_app/view/page/change_password/changePassword.dart';
import 'package:kas_mini_flutter_app/view/page/expense/expense_page.dart';
import 'package:kas_mini_flutter_app/view/page/home/product_terbaru_list.dart';
import 'package:kas_mini_flutter_app/view/page/home/riwayat_transaksi.dart';
import 'package:kas_mini_flutter_app/view/page/income/income_page.dart';
import 'package:kas_mini_flutter_app/view/page/login_cashier/login_cashier.dart';
import 'package:kas_mini_flutter_app/view/page/print_resi/input_resi.dart';
import 'package:kas_mini_flutter_app/view/page/product/product.dart';
import 'package:kas_mini_flutter_app/view/page/report/report_page.dart';
import 'package:kas_mini_flutter_app/view/page/settings/securityPage.dart';
import 'package:kas_mini_flutter_app/view/page/settings/setting.dart';
import 'package:kas_mini_flutter_app/view/page/transaction/transactions_page.dart';
import 'package:kas_mini_flutter_app/view/page/usersProfile/usersProfile.dart';
import 'package:kas_mini_flutter_app/view/widget/line_chart_card.dart';
import 'package:kas_mini_flutter_app/view/widget/menu_card.dart';
import 'package:kas_mini_flutter_app/view/widget/modals.dart';
import 'package:kas_mini_flutter_app/view/widget/pinModal.dart';
import 'package:kas_mini_flutter_app/view/widget/refresWidget.dart';
import 'package:kas_mini_flutter_app/view/widget/sidebar_list_tile.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  final bool isRedirectFromLogin;

  const Home({super.key, this.isRedirectFromLogin = false});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DatabaseService db = DatabaseService.instance;
  List<TransactionData> transactionData = [];
  @override
  void initState() {
    super.initState();
    // _checkToken();
    getTransaction();
    Provider.of<CashierProvider>(context, listen: false)
        .loadCashierDataFromSharedPreferences();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // startTokenCheck(context);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.fetchAndDecodeToken();
      userProvider.getSerialNumberAsUser(context);
    });
  }

  // void _navigateToLogin() {
  //   Future.delayed(Duration(seconds: 1), () {
  //     // Pastikan widget masih terpasang
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => LoginPage()),
  //     );
  //   });
  // }

  // void _checkToken() async {
  //   try {
  //     final token = await _authService.getToken();
  //     if (token != null && !_authService.isTokenExpired(context, token)) {
  //       print("Home!");
  //     } else {
  //       print("Navigating to Login");
  //       _navigateToLogin();
  //     }
  //   } catch (e) {
  //     print("Error checking token: $e");
  //     _navigateToLogin(); // Fallback ke halaman login
  //   }
  // }

  void getTransaction() async {
    List<TransactionData> data = await db.getTransaction();
    setState(() {
      transactionData = data;
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // final AuthService _authService = AuthService();

  // void _logout() async {
  //   try {
  //     await _authService.logout(context);
  //   } catch (e) {
  //     print('Error during logout: $e');
  //   }
  // }

  Future<void> _handleRefresh() async {
    await Provider.of<CashierProvider>(context, listen: false)
        .loadCashierDataFromSharedPreferences();
    setState(() {});
  }

  Future<int> _getTodayTotalOmzet() async {
    List<TransactionData> transactions = await databaseService.getTransaction();
    // Fetch your transactions from the database or API

    // Get today's date
    final today = DateTime.now();

    // Filter transactions based on today's date and transactionStatus = "Selesai"
    final todayTransactions = transactions.where((transaction) {
      try {
        String dateStr = transaction.transactionDate.split(', ')[1];
        DateTime transactionDate =
            DateFormat("dd/MM/yyyy HH:mm").parse(dateStr).toLocal();
        return transactionDate.year == today.year &&
            transactionDate.month == today.month &&
            transactionDate.day == today.day &&
            transaction.transactionStatus == "Selesai";
      } catch (e) {
        print("Error parsing date: ${transaction.transactionDate}, Error: $e");
        return false;
      }
    }).toList();

    // Calculate total omzet
    Future<int> totalOmzet = _calculateTotalOmzet(todayTransactions);
    return totalOmzet;
  }

  final List<Map<String, dynamic>> data = [
    {
      'icon': Icons.people_rounded,
      'title': 'Ganti Kasir',
      'color': Colors.white,
      'destination': LoginCashier()
    },
  ];

  Future<int> _calculateTotalOmzet(List<TransactionData> transactions) async {
    return await transactions.fold<Future<int>>(Future.value(0),
        (futureSum, transaction) async {
      final sum = await futureSum;
      final transactionTotal = await transaction.transactionTotal;
      return sum + transactionTotal;
    });
  }

  // @override
  // void startTokenCheck(BuildContext context) {
  //    final authService = AuthService();
  //   Timer.periodic(Duration(seconds: 1), (timer) async {
  //     final token = await authService.getToken();
  //     if (token == null || authService.isTokenExpired(context, token)) {
  //       timer.cancel();
  //       await authService.logout(context);
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    var cashierProvider = Provider.of<CashierProvider>(context);
    var securityProvider = Provider.of<SecurityProvider>(context);
    var settingProvider = Provider.of<SettingProvider>(context);
    var userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: bgColor,
        drawer: Drawer(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFF344CB7), // Warna atas
                  Color(0xFF172251), // Warna bawah
                ],
              ),
            ),
            child: SafeArea(
              child: CustomRefreshWidget(
                onRefresh: _handleRefresh,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Drawer
                    GestureDetector(
                      onTap: () {
                        if (UserProvider().serialNumberData != null) {
                          connectionToast(context, "Koneksi Gagal!",
                              "Anda tidak terhubung ke jaringan. Login Ulang",
                              isConnected: false);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfileScreen()),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 20),
                        child: Row(
                          children: [
                            userProvider.serialNumberData != null &&
                                    userProvider.serialNumberData!.profileImage
                                        .isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: userProvider
                                        .serialNumberData!.profileImage,
                                    placeholder: (context, url) =>
                                        CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                    imageBuilder: (context, imageProvider) =>
                                        CircleAvatar(
                                      radius: 20,
                                      backgroundImage: imageProvider,
                                    ),
                                  )
                                : CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey,
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                  ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (userProvider.serialNumberData?.name ==
                                              null ||
                                          userProvider.serialNumberData?.name
                                                  .isEmpty ==
                                              true)
                                      ? '-'
                                      : userProvider.serialNumberData!.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  (userProvider.serialNumberData?.email ==
                                              null ||
                                          userProvider.serialNumberData?.email
                                                  .isEmpty ==
                                              true)
                                      ? '-'
                                      : userProvider.serialNumberData!.email,
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            IconButton(
                              icon:
                                  const Icon(Icons.arrow_forward_ios, size: 18),
                              color: Colors.white,
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                final item = data[index];
                                if (item['title'] == "Ganti Kasir") {
                                  return Column(
                                    children: [
                                      SidebarListTile(
                                        icon: item['icon'],
                                        title: item['title'],
                                        iconColor: item['color'],
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    item['destination']),
                                          );
                                        },
                                      ),
                                      SidebarListTile(
                                        icon: Icons.payment_outlined,
                                        title: "Pengeluaran",
                                        iconColor: Colors.white,
                                        onTap: () {
                                          if (securityProvider
                                              .kunciPengeluaran) {
                                            showPinModalWithAnimation(context,
                                                pinModal: PinModal(
                                                  destination: ExpensePage(),
                                                ));
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ExpensePage()),
                                            );
                                          }
                                        },
                                      ),
                                      SidebarListTile(
                                          icon: Icons.monetization_on,
                                          title: "Pemasukan",
                                          iconColor: Colors.white,
                                          onTap: () {
                                            if (securityProvider
                                                .kunciPemasukan) {
                                              showPinModalWithAnimation(
                                                context,
                                                pinModal: PinModal(
                                                  destination: IncomePage(),
                                                ),
                                              );
                                            } else {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        IncomePage()),
                                              );
                                            }
                                          }),
                                    ],
                                  );
                                }
                                return SidebarListTile(
                                  icon: item['icon'],
                                  title: item['title'],
                                  iconColor: item['color'],
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              item['destination']),
                                    );
                                  },
                                );
                              },
                            ),

                            const Divider(
                                color: Colors.white24,
                                thickness: 1,
                                indent: 16,
                                endIndent: 16),
                            // Akun Section
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 8),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Akun",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            SidebarListTile(
                              icon: Icons.settings_outlined,
                              title: 'Pengaturan',
                              iconColor: Colors.white,
                              onTap: () {
                                if (securityProvider.kunciPengaturanToko) {
                                  showPinModalWithAnimation(
                                    context,
                                    pinModal: PinModal(
                                      destination: SettingPage(),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SettingPage()),
                                  );
                                }
                              },
                            ),

                            if (cashierProvider.cashierData?['cashierName'] ==
                                "Owner")
                              SidebarListTile(
                                icon: Icons.shield_outlined,
                                title: 'Keamanan',
                                iconColor: Colors.white,
                                onTap: () {
                                  showPinModalWithAnimation(
                                    context,
                                    pinModal: PinModal(
                                      destination: SecuritySettingsPage(),
                                    ),
                                  );
                                },
                              ),
                            SidebarListTile(
                              icon: Icons.password_outlined,
                              title: 'Ganti Password',
                              iconColor: Colors.white,
                              onTap: () {
                                if (securityProvider.kunciGantiPassword) {
                                  showPinModalWithAnimation(
                                    context,
                                    pinModal: PinModal(
                                      destination: ChangepasswordPage(),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ChangepasswordPage()),
                                  );
                                }
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 20),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.info_outline,
                                color: Colors.white),
                            title: const Text(
                              'About',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UpdatePage()));
                            },
                          ),
                          if (!securityProvider.sembunyikanLogout)
                            ListTile(
                              leading: const Icon(Icons.logout_outlined,
                                  color: Colors.white),
                              title: const Text(
                                'Logout',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // onTap: _logout,
                              onTap: () {},
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              CustomRefreshWidget(
                onRefresh: _handleRefresh,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(30),
                                  bottomRight: Radius.circular(30))),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                right: 20, left: 20, top: 20, bottom: 20),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(children: [
                                      IconButton(
                                        onPressed: () {
                                          _scaffoldKey.currentState
                                              ?.openDrawer();
                                        },
                                        icon: const Icon(Icons.menu,
                                            color: primaryColor, size: 32),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          CashierData? cashier =
                                              await cashierProvider
                                                  .getCashierById(int.parse(
                                                      cashierProvider
                                                              .cashierData?[
                                                          'cashierId']));

                                          if (cashier != null) {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        UpdateCashierFromHome(
                                                            cashier: cashier)));
                                          } else {
                                            print('Cashier data is null');
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            ClipOval(
                                              child: Image.asset(
                                                "assets/profiles/profile-1.png",
                                                width: 45,
                                                height: 45,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Gap(10),
                                            Text(cashierProvider
                                                .cashierData?['cashierName'])
                                          ],
                                        ),
                                      ),
                                    ]),
                                    GestureDetector(
                                        onTap: () {
                                          if (securityProvider
                                              .kunciPengaturanToko) {
                                            showPinModalWithAnimation(context,
                                                pinModal: PinModal(
                                                  destination: SettingPage(),
                                                ));
                                          } else {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        SettingPage()));
                                          }
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  (settingProvider
                                                              .getSettingName
                                                              ?.isEmpty ??
                                                          true)
                                                      ? 'Nama Toko'
                                                      : (settingProvider
                                                                  .getSettingName!
                                                                  .replaceAll(
                                                                      '\n', ' ')
                                                                  .length >
                                                              15
                                                          ? '${settingProvider.getSettingName!.replaceAll('\n', ' ').substring(0, 20)}...'
                                                          : settingProvider
                                                              .getSettingName!
                                                              .replaceAll(
                                                                  '\n', ' ')),
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16),
                                                ),
                                                Text(
                                                  (settingProvider
                                                              .getSettingAddress
                                                              ?.isEmpty ??
                                                          true)
                                                      ? 'Alamat Toko'
                                                      : (settingProvider
                                                                  .getSettingAddress!
                                                                  .replaceAll(
                                                                      '\n', ' ')
                                                                  .length >
                                                              30
                                                          ? '${settingProvider.getSettingAddress!.replaceAll('\n', ' ').substring(0, 30)}...'
                                                          : settingProvider
                                                              .getSettingAddress!
                                                              .replaceAll(
                                                                  '\n', ' ')),
                                                ),
                                              ],
                                            ),
                                            const Gap(10),
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                child: settingProvider
                                                            .settingImage !=
                                                        null
                                                    ? Hero(
                                                        tag: "settingImage",
                                                        child: Image.file(
                                                          File(settingProvider
                                                              .settingImage!),
                                                          width: 45,
                                                          height: 45,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (context, error,
                                                                  stackTrace) {
                                                            return Image.asset(
                                                              "assets/products/no-image.png",
                                                              width: 45,
                                                              height: 45,
                                                              fit: BoxFit.cover,
                                                            );
                                                          },
                                                        ),
                                                      )
                                                    : Hero(
                                                        tag: "settingNoImage",
                                                        child: Image.asset(
                                                          "assets/products/no-image.png",
                                                          width: 45,
                                                          height: 45,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          ],
                                        )),
                                  ],
                                ),
                                Gap(20),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                              colors: [
                                                primaryColor,
                                                secondaryColor
                                              ],
                                              begin: Alignment(0, 2),
                                              end: Alignment(-0, -2)),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Total Penjualan Hari Ini",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16),
                                            ),
                                            const SizedBox(height: 4),
                                            FutureBuilder<int>(
                                              future:
                                                  _getTodayTotalOmzet(), // Now returns Future<int>
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return CircularProgressIndicator();
                                                } else if (snapshot.hasError) {
                                                  return Text(
                                                      'Error: ${snapshot.error}');
                                                } else if (snapshot.hasData) {
                                                  final totalOmzet = snapshot
                                                          .data ??
                                                      0; // Directly use the integer value

                                                  return Text(
                                                    '${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0).format(totalOmzet)}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  );
                                                } else {
                                                  return Text(
                                                    '${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0).format(0)}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                            const SizedBox(height: 15),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        bottom: -5,
                                        right: 15,
                                        child: Image.asset(
                                          'assets/images/Grafik.png',
                                          fit: BoxFit.cover,
                                          width: 145,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Gap(20),
                                Row(
                                  children: [
                                    Consumer<CashierProvider>(
                                      builder:
                                          (context, cashierProvider, child) {
                                        if (cashierProvider
                                                .cashierData?['cashierName'] ==
                                            "Owner") {
                                          return Expanded(
                                            child: MainCard(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        CashierPage(),
                                                  ),
                                                );
                                              },
                                              title: "Kasir\n",
                                              color: Colors.black,
                                              imagePath:
                                                  'assets/images/cashier.png',
                                            ),
                                          );
                                        } else {
                                          return Expanded(
                                              child: MainCard(
                                            onTap: () {
                                              if (securityProvider
                                                  .kunciProduk) {
                                                showPinModalWithAnimation(
                                                  context,
                                                  pinModal: PinModal(
                                                    destination: ProductPage(),
                                                  ),
                                                );
                                              } else {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProductPage()),
                                                );
                                              }
                                            },
                                            title: "Produk\n",
                                            color: Colors.black,
                                            imagePath:
                                                'assets/images/income.png',
                                          ));
                                        }
                                      },
                                    ),
                                    const Gap(10),
                                    Expanded(
                                      child: MainCard(
                                        onTap: () {
                                          if (securityProvider.kunciProduk) {
                                            showPinModalWithAnimation(
                                              context,
                                              pinModal: PinModal(
                                                destination: ProductPage(),
                                              ),
                                            );
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProductPage()),
                                            );
                                          }
                                        },
                                        title: "Produk\n",
                                        color: Colors.black,
                                        imagePath: 'assets/images/product.png',
                                      ),
                                    ),
                                    const Gap(10),
                                    // Expanded(
                                    //   child: MainCard(
                                    //     onTap: () {
                                    //       if (securityProvider.kunciLaporan) {
                                    //         showPinModalWithAnimation(context,
                                    //             pinModal: PinModal(
                                    //               destination: ReportPage(),
                                    //             ));
                                    //       } else {
                                    //         Navigator.push(
                                    //           context,
                                    //           MaterialPageRoute(
                                    //             builder: (context) =>
                                    //                 const ReportPage(),
                                    //           ),
                                    //         );
                                    //       }
                                    //     },
                                    //     title: "Laporan\n",
                                    //     color: Colors.black,
                                    //     imagePath: "assets/images/report.png",
                                    //   ),
                                    // ),
                                    Gap(10),
                                    Expanded(
                                      child: MainCard(
                                        onTap: () {
                                          if (securityProvider
                                              .kunciRiwayatTransaksi) {
                                            showPinModalWithAnimation(
                                              context,
                                              pinModal: PinModal(
                                                destination: RiwayatTransaksi(),
                                              ),
                                            );
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      RiwayatTransaksi()),
                                            );
                                          }
                                        },
                                        title: "Riwayat\nTransaksi",
                                        color: Colors.black,
                                        imagePath: 'assets/images/history.png',
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(10),
                                Row(
                                  children: [
                                    // Expanded(
                                    //   child: MainCard(
                                    //     onTap: () {
                                    //       Navigator.push(
                                    //           context,
                                    //           MaterialPageRoute(
                                    //               builder: (_) =>
                                    //                   const AddStockProductPage()));
                                    //     },
                                    //     title: "Tambah\nStok Produk",
                                    //     color: Colors.black,
                                    //     imagePath: 'assets/images/add.png',
                                    //   ),
                                    // ),
                                    const Gap(10),
                                    Expanded(
                                      child: MainCard(
                                        onTap: () {
                                          if (securityProvider
                                              .kunciPengaturanToko) {
                                            showPinModalWithAnimation(
                                              context,
                                              pinModal: PinModal(
                                                destination: SettingPage(),
                                              ),
                                            );
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      SettingPage()),
                                            );
                                          }
                                        },
                                        title: "Pengaturan\n",
                                        color: Colors.black,
                                        imagePath: 'assets/images/setting.png',
                                      ),
                                    ),
                                    const Gap(10),
                                    Expanded(
                                      child: MainCard(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      const InputResi()));
                                        },
                                        title: "Cetak Resi\n",
                                        color: Colors.black,
                                        imagePath: 'assets/images/printer.png',
                                      ),
                                    ),
                                    const Gap(10),
                                    Expanded(
                                      child: MainCard(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      const AllIconPage()));
                                        },
                                        title: "Lihat\nSemua",
                                        color: Colors.black,
                                        imagePath: 'assets/images/group.png',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Gap(20),
                      Container(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Produk Terbaru",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17.sp),
                                      ),
                                      Text(
                                        "Baru ditambahkan",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 15.sp),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ProductPage(),
                                          ));
                                    },
                                    child: const Row(
                                      children: [
                                        Text(
                                          "Lihat semua",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: primaryColor),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: primaryColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              SizedBox(
                                height: 100,
                                child: ProductTerbaruList(
                                  key: ValueKey(DateTime.now()),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Gap(20),
                      Container(
                        child: RiwayatTransaksiSection(),
                      ),
                      Gap(20),
                      Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 30,
                left: MediaQuery.of(context).size.width / 2 - 35,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => TransactionPage(
                                  selectedProducts: [],
                                )));
                  },
                  child: Container(
                    height: 70,
                    width: 70,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [primaryColor, secondaryColor],
                          begin: Alignment(0, 3),
                          end: Alignment(-0, -2)),
                      shape: BoxShape.circle,
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          color: Colors.white,
                          size: 25,
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Transaksi",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

// Riwayat Transaksi Container
class RiwayatTransaksiSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Riwayat Transaksi",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.sp),
              ),
              Text(
                "Hari ini",
                style: TextStyle(color: Colors.grey, fontSize: 15.sp),
              ),
              SizedBox(height: 12),
              RiwayatTransaksi_list(
                key: ValueKey(DateTime.now()),
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0),
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.5),
                    Colors.white.withOpacity(0.8),
                    Colors.white.withOpacity(0.9),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RiwayatTransaksi(),
                      ));
                },
                child: Text(
                  "Selengkapnya",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
