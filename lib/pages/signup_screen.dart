import 'package:flutter/material.dart';
import 'package:trenpal/custom%20widgets/combo_box.dart';
import 'package:trenpal/custom%20widgets/date_picker.dart';
import 'package:trenpal/custom%20widgets/keyboard_safe_wrapper.dart';
import 'package:trenpal/pages/main_screen.dart';
import 'package:trenpal/custom%20widgets/text_field.dart';
import 'package:trenpal/custom%20widgets/tren_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trenpal/custom%20widgets/tren_spin.dart';
import '../custom widgets/tren_alerts.dart';
import '../custom widgets/tren_radio.dart';
import 'package:intl/intl.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  int? ActLvl;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  final dobController = TextEditingController();
  final goalController = TextEditingController();
  final weightcontroller = TextEditingController();
  final heightcontroller = TextEditingController();
  final intensitycontroller = TextEditingController();

  int goalCalculator({
    required int weight,
    required int height,
    required int age,
    required String intensity,
    required String goal,
    required String gender,
  }) {
    double bmr;
    double bmrFinal;

    if (gender == "male") {
      bmr = (10 * weight + 6.25 * height - 5 * age + 5) * 1.375;
    } else {
      bmr = (10 * weight + 6.25 * height - 5 * age - 161) * 1.375;
    }

    if (goal == "Losing weight" && intensity == "Extreme") {
      bmrFinal = bmr - 1000;
    } else if (goal == "Losing weight" && intensity == "Moderate") {
      bmrFinal = bmr - 500;
    } else if (goal == "Gaining weight" && intensity == "Moderate") {
      bmrFinal = bmr + 500;
    } else {
      bmrFinal = bmr + 1000;
    }

    return bmrFinal.round();
  }

  final EzRadioController gendercontroller = EzRadioController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    dobController.dispose();
    goalController.dispose();
    weightcontroller.dispose();
    heightcontroller.dispose();
    intensitycontroller.dispose();
    gendercontroller.dispose();
    super.dispose();
  }

  Future signup(BuildContext context) async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        usernameController.text.trim().isEmpty ||
        dobController.text.trim().isEmpty ||
        goalController.text.trim().isEmpty ||
        weightcontroller.text.trim().isEmpty ||
        heightcontroller.text.trim().isEmpty ||
        intensitycontroller.text.trim().isEmpty ||
        gendercontroller.selectedValue == null) {
      TrenAlerts.error(context, 'Please fill all fields!');
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      DateFormat format = DateFormat("dd/MM/yyyy");
      DateTime dob = format.parse(dobController.text);
      DateTime today = DateTime.now();
      int age = today.year - dob.year;
      if (today.month < dob.month ||
          (today.month == dob.month && today.day < dob.day)) {
        age--;
      }

      int intake = goalCalculator(
        weight: int.tryParse(weightcontroller.text.trim()) ?? 0,
        height: int.tryParse(heightcontroller.text.trim()) ?? 0,
        age: age,
        intensity: intensitycontroller.text.trim(),
        goal: goalController.text.trim(),
        gender: gendercontroller.selectedValue ?? "male",
      );

      await addDetails(
        userCredential.user!.uid,
        emailController.text.trim(),
        usernameController.text.trim(),
        dobController.text.trim(),
        goalController.text.trim(),
        heightcontroller.text.trim(),
        weightcontroller.text.trim(),
        intensitycontroller.text.trim(),
        gendercontroller.selectedValue!,
        intake,
      );

      TrenAlerts.success(
        context,
        'Welcome to TrenPal! Account created successfully!',
      );
    } catch (e) {
      String errorMsg = 'Signup failed. Please try again.';
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'weak-password':
            errorMsg = 'Password is too weak. Use at least 6 characters.';
            break;
          case 'email-already-in-use':
            errorMsg = 'An account already exists with this email.';
            break;
          case 'invalid-email':
            errorMsg = 'Please enter a valid email address.';
            break;
        }
      }
      TrenAlerts.error(context, errorMsg);
    }
  }

  Future addDetails(
    String userId,
    String email,
    String username,
    String dob,
    String goal,
    String height,
    String weight,
    String intensity,
    String gender,
    int intake,
  ) async {
    await FirebaseFirestore.instance.collection("users").doc(userId).set({
      "email": email,
      "username": username,
      "dob": dob,
      "goal": goal,
      "creationDate": Timestamp.now(),
      "intensity": intensity,
      "weight": weight,
      "height": height,
      "gender": gender,
      "intake": intake,
      "currentIntake": "0",
      "carbs": "0",
      "protein": "0",
      "fats": "0",
      "carbsGoal": "300",
      "proteinGoal": "200",
      "fatsGoal": "75",
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardSafeWrapper(
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Image.asset("assets/img/signup_logo.png", width: 300),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedGrayTextField(
                        prompt: "Email",
                        width: 175,
                        height: 55,
                        inputType: "text",
                        controller: emailController,
                      ),
                      const SizedBox(width: 10),
                      AnimatedGrayTextField(
                        prompt: "Password",
                        width: 175,
                        height: 55,
                        inputType: "password",
                        controller: passwordController,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedGrayTextField(
                        prompt: "Username",
                        width: 175,
                        height: 55,
                        inputType: "text",
                        controller: usernameController,
                      ),
                      const SizedBox(width: 10),
                      AnimatedDatePicker(
                        prompt: "BirthDate",
                        width: 175,
                        height: 55,
                        controller: dobController,
                        dateFormat: "dd/MM/yyyy",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TrenSpin(
                      prompt: 'Height',
                      width: 170,
                      height: 50,
                      controller: heightcontroller,
                    ),
                    const SizedBox(width: 20),
                    TrenSpin(
                      prompt: 'Weight',
                      width: 170,
                      height: 50,
                      controller: weightcontroller,
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                AnimatedComboBox(
                  prompt: "What's your goal",
                  options: const ["Losing weight", "Gaining weight"],
                  width: 360,
                  height: 55,
                  controller: goalController,
                ),
                const SizedBox(height: 15),
                AnimatedComboBox(
                  prompt: "Goal Intensity",
                  options: const ["Extreme", "Moderate"],
                  width: 360,
                  height: 55,
                  controller: intensitycontroller,
                ),
                const SizedBox(height: 20),
                // Add both gender options
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    EzRadio(
                      label: "Male",
                      group: "gender",
                      controller: gendercontroller,
                      height: 50,
                      width: 175,
                    ),
                    SizedBox(width: 10),
                    EzRadio(
                      label: "Female",
                      group: "gender",
                      controller: gendercontroller,
                      height: 50,
                      width: 175,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TrenPalButton(
                  text: 'Sign up',
                  onPressed: () async {
                    signup(context);
                    await Future.delayed(Duration(seconds: 2));
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MainScreen()),
                    );
                  },
                  showLoading: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
