import 'package:flutter/material.dart';
import 'package:trenpal/custom%20widgets/tren_checkbox.dart';
import 'package:trenpal/pages/dashboard.dart';
import 'package:trenpal/custom%20widgets/hyper_link_tren.dart';
import 'package:trenpal/custom%20widgets/keyboard_safe_wrapper.dart';
import 'package:trenpal/pages/password_reset.dart';
import 'package:trenpal/custom%20widgets/text_field.dart';
import 'package:trenpal/custom%20widgets/tren_alerts.dart';
import 'package:trenpal/custom%20widgets/tren_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signup_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final emailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    rememberScreen(context);
  }

  void rememberScreen(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final _isChecked = prefs.getBool('rememberMe') ?? false;
    String email = prefs.getString('savedEmail') ?? '';
    String password = prefs.getString('savedPassword') ?? '';

    if (_isChecked) {
      await (context, email, password);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TrenDashboard()),
      );
    }
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isChecked = prefs.getBool('rememberMe') ?? false;
      if (_isChecked) {
        emailcontroller.text = prefs.getString('savedEmail') ?? '';
        passwordcontroller.text = prefs.getString('savedPassword') ?? '';
      }
    });
  }

  Future<void> _saveCredentials(bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', rememberMe);
    if (rememberMe) {
      await prefs.setString('savedEmail', emailcontroller.text);
      await prefs.setString('savedPassword', passwordcontroller.text);
    } else {
      await prefs.remove('savedEmail');
      await prefs.remove('savedPassword');
    }
  }

  Future<void> resetMacros(String userId) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    final snapshot = await userDoc.get();

    if (!snapshot.exists) return;

    final data = snapshot.data()!;
    Timestamp lastReset =
        data['lastResetDate'] ?? data['creationDate'] ?? Timestamp.now();
    final now = Timestamp.now();

    final dayNow = now.toDate().day;
    final monthnow = now.toDate().month;
    final yearnow = now.toDate().year;
    final Regday = lastReset.toDate().day;
    final Regmonth = lastReset.toDate().month;
    final regyear = lastReset.toDate().year;

    if (regyear != yearnow || Regday != dayNow || Regmonth != monthnow) {
      await userDoc.update({
        "currentIntake": 0,
        "carbs": 0,
        "protein": 0,
        "fats": 0,
        "lastResetDate": now,
      });
      print('Macros reset successfully');
    } else {
      print('No reset needed yet');
    }
  }

  Future<void> signin(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await resetMacros(FirebaseAuth.instance.currentUser!.uid);
      await _saveCredentials(_isChecked);

      TrenAlerts.success(context, "Welcome back to TrenPal!");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TrenDashboard()),
      );
    } on FirebaseAuthException catch (e) {
      if (email.isEmpty || password.isEmpty) {
        TrenAlerts.error(context, "Fill all fields");
      } else {
        TrenAlerts.error(context, e.message.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardSafeWrapper(
      child: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset("assets/img/app_logo.png", width: 280),
                  const SizedBox(height: 40),

                  AnimatedGrayTextField(
                    prompt: "Enter Your Email",
                    width: 280,
                    height: 50,
                    inputType: "text",
                    controller: emailcontroller,
                  ),
                  const SizedBox(height: 20),

                  AnimatedGrayTextField(
                    prompt: "Enter Your Password",
                    width: 280,
                    height: 50,
                    inputType: 'password',
                    controller: passwordcontroller,
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TrenPalHyperText(
                          text: "Forgot your password?",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PasswordReset(),
                              ),
                            );
                          },
                          fontSize: 13,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20, left: 30),
                        child: TrenPalCheckbox(
                          value: _isChecked,
                          onChanged: (value) {
                            setState(() {
                              _isChecked = value ?? false;
                            });
                          },
                          label: "Remember me?",
                          height: 25,
                          width: 250,
                        ),
                      ),
                    ],
                  ),

                  TrenPalButton(
                    icon: Icons.login,
                    text: "Login",
                    onPressed: () async {
                      await signin(
                        context,
                        emailcontroller.text.trim(),
                        passwordcontroller.text.trim(),
                      );
                    },
                    width: 280,
                    height: 50,
                    showLoading: true,
                  ),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Not a Member ?",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "ubuntu",
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 1),
                      TrenPalHyperText(
                        text: "Sign up Now !",
                        fontSize: 16,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignupScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
