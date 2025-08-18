import 'package:flutter/material.dart';
import 'package:trenpal/custom%20widgets/text_field.dart';
import 'package:trenpal/custom%20widgets/tren_alerts.dart';
import 'package:trenpal/custom%20widgets/tren_button.dart';
import 'package:trenpal/custom%20widgets/tren_spin.dart';
import 'package:trenpal/entities/meals.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MealsPage extends StatefulWidget {
  const MealsPage({super.key});

  @override
  State<MealsPage> createState() => _MealsPageState();
}

class _MealsPageState extends State<MealsPage> {
  final name = TextEditingController();
  final carbs = TextEditingController();
  final protein = TextEditingController();
  final fats = TextEditingController();
  final calories = TextEditingController();

  Future<void> LogMeal(
    BuildContext context,
    String name,
    int carbs,
    int protein,
    int calories,
    int fats,
  ) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      addDetails(uid, calories, protein, carbs, fats, name);
    } catch (e) {
      print("fuck off");
    }
  }

  Future addDetails(
    String userId,
    int calories,
    int protein,
    int carbs,
    int fats,
    String name,
  ) async {
    await FirebaseFirestore.instance.collection("meals").doc(userId).set({
      "name": name,
      "calories": calories,
      "protein": protein,
      "carbs": carbs,
      "fats": fats,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              "assets/img/meals.png",
              width: 250,
              height: 250,
              fit: BoxFit.contain,
            ),
            AnimatedGrayTextField(prompt: "Name", controller: name),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TrenSpin(
                  prompt: "Calories",
                  maxValue: 5000,
                  minValue: 1,
                  step: 100,
                  initialValue: 350,
                  width: 170,
                  height: 55,
                  controller: calories,
                ),
                SizedBox(width: 10),
                TrenSpin(
                  prompt: "Protein",
                  maxValue: 400,
                  minValue: 0,
                  step: 1,
                  initialValue: 5,
                  width: 170,
                  height: 55,
                  controller: protein,
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TrenSpin(
                  prompt: "Carbs",
                  maxValue: 1000,
                  minValue: 0,
                  step: 1,
                  initialValue: 50,
                  width: 170,
                  height: 55,
                  controller: carbs,
                ),
                SizedBox(width: 10),
                TrenSpin(
                  prompt: "Fats",
                  maxValue: 1000,
                  minValue: 0,
                  step: 1,
                  initialValue: 20,
                  width: 170,
                  height: 55,
                  controller: fats,
                ),
              ],
            ),
            SizedBox(height: 20),
            TrenPalButton(
              text: "Add Meal",
              onPressed: () async {
                String mealName = name.text.trim();
                int mealCarbs = int.tryParse(carbs.text) ?? 0;
                int mealProtein = int.tryParse(protein.text) ?? 0;
                int mealCalories = int.tryParse(calories.text) ?? 0;
                int mealFats = int.tryParse(fats.text) ?? 0;

                await LogMeal(
                  context,
                  mealName,
                  mealCarbs,
                  mealProtein,
                  mealCalories,
                  mealFats,
                );
              },
              icon: Icons.food_bank_outlined,
            ),
          ],
        ),
      ),
    );
  }
}
