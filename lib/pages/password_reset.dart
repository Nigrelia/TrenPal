import 'package:flutter/material.dart';
import 'package:trenpal/custom%20widgets/keyboard_safe_wrapper.dart';
import 'package:trenpal/custom%20widgets/text_field.dart';
import 'package:trenpal/custom%20widgets/tren_alerts.dart';
import 'package:trenpal/custom%20widgets/tren_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasswordReset extends StatelessWidget {
  PasswordReset({super.key});
  final emailcontroller = TextEditingController();

  Future resetPass(context, String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      TrenAlerts.success(context, "Email sent successfully !");
    } on FirebaseAuthException catch (e) {
      TrenAlerts.error(context, e.message.toString());
    }
  }

  @override
  Widget build(context) {
    return KeyboardSafeWrapper(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/img/resetpass.png"),
            AnimatedGrayTextField(
              prompt: "Enter your Email",
              height: 55,
              width: 350,
              controller: emailcontroller,
            ),
            SizedBox(height: 20),
            TrenPalButton(
              text: "Reset password",
              onPressed: () async {
                resetPass(context, emailcontroller.text.trim());
              },
              showLoading: true,
            ),
          ],
        ),
      ),
    );
  }
}
