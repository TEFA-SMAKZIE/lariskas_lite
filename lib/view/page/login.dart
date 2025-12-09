import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:kas_mini_lite/providers/appVersionProvider.dart';
import 'package:kas_mini_lite/services/authService.dart';
import 'package:kas_mini_lite/utils/colors.dart';
import 'package:kas_mini_lite/utils/toast.dart';
import 'package:kas_mini_lite/view/page/home/home.dart';
import 'package:kas_mini_lite/view/widget/custom_textfield.dart';
import 'package:lottie/lottie.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LarisKas Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _serialNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _loading = false;
  String appVersion = 'Loading...';

  @override
  void dispose() {
    _serialNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
    });
  
    try {
      await _authService.loginWithSerialNumber(
        context,
        _serialNumberController.text,
        _passwordController.text,
      );

      Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (context, animation, secondaryAnimation) =>
                const Home(isRedirectFromLogin: true,),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ));
    } catch (e) {
      String errorMessage = e.toString().replaceFirst('Exception: ', '');
      failedToast(context, "Login", errorMessage);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    var appVersionProvider = AppVersionProvider();
    appVersionProvider.getAppVersion().then((_) {
      setState(() {
        appVersion = appVersionProvider.appVersion;
      });
    });
  }

  bool _isPasswordObscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 100),
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                            fontSize: 35,
                            color: Colors.black,
                            height: 1,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                          children: const [
                            TextSpan(text: 'Selamat Datang\n'),
                            TextSpan(text: 'di '),
                            TextSpan(
                              text: 'Laris',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: 'Kas\n',
                              style: TextStyle(
                                color: greenColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: 'Catat, Kelola, Aman',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontWeight: FontWeight.w100,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(30),
                    Image.asset(
                      "assets/images/Logo-Kasmini.jpg",
                      width: 100,
                      height: 100,
                    ),
                    const Gap(30),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Masuk ke LarisKas Anda',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const Gap(10),
                    CustomTextField(
                      fillColor: Colors.grey[200],
                      suffixIcon: null,
                      obscureText: false,
                      hintText: 'Nomor Serial',
                      prefixIcon: const Icon(Icons.numbers_outlined),
                      controller: _serialNumberController,
                      maxLines: 1,
                    ),
                    const Gap(10),
                    CustomTextField(
                      suffixIcon: IconButton(
                       icon: _isPasswordObscured
                            ? const Iconify(Ic.twotone_visibility)
                            : Iconify(Ic.twotone_visibility_off),
                        onPressed: () {
                          setState(() {
                            _isPasswordObscured = !_isPasswordObscured;
                          });
                        },
                      ),
                      fillColor: Colors.grey[200],
                      obscureText: _isPasswordObscured,
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.password_outlined),
                      controller: _passwordController,
                      maxLines: 1,
                    ),
                    const Gap(20),
                    SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: _loading == true ? Colors.white : null,
                          gradient: _loading == true
                              ? null
                              : LinearGradient(
                                  colors: [primaryColor, secondaryColor],
                                  begin: Alignment(0, 2),
                                  end: Alignment(-0, -2),
                                ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            side: _loading == true
                                ? BorderSide(color: primaryColor, width: 2)
                                : BorderSide.none,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: _loading == true
                              ? Lottie.asset(
                                  'assets/lottie/loading-2.json',
                                  width: 100,
                                  height: 100,
                                )
                              : Text(
                                  "LOGIN",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const Gap(5),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.only(top: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 4.0,
                          children: [
                            const Text(
                              'Lupa Nomor Serial atau Password?',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const Gap(5),
                            GestureDetector(
                              onTap: () {
                                failedToast(
                                    context,
                                    "Lupa Nomor Serial atau Password",
                                    "Silahkan Lapor Admin untuk mendapatkan dukungan lebih lanjut.");
                              },
                              child: Text(
                                'Hubungi!',
                                style: TextStyle(
                                  color: Colors.blue[400],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Stack(children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    height: 40,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, secondaryColor],
                        begin: Alignment(0, 2),
                        end: Alignment(-0, -2),
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          'Versi $appVersion',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
