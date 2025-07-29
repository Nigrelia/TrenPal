import 'package:trenpal/custom%20widgets/tren_button.dart';
import 'package:trenpal/custom%20widgets/tren_macros_popup.dart';
import '../custom widgets/calories_tracker.dart';
import 'package:trenpal/custom%20widgets/macros_tracker.dart';
import 'package:flutter/material.dart';

class CaloriesTrackerPage extends StatelessWidget {
  final int calories;
  final int calorieGoal;
  final int carbs;
  final int protein;
  final int fats;
  final int carbsGoal;
  final int proteinGoal;
  final int fatsGoal;
  final VoidCallback onChangeGoal;
  final VoidCallback onFastLog;
  final VoidCallback onUpdateMacros;
  void _showMacrosPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => MacrosPopup(
        initialProtein: 50,
        initialCarbs: 100,
        initialFats: 70,
        onUpdate: (protein, carbs, fats) {
          print("Protein: $protein g, Carbs: $carbs g, Fats: $fats g");
        },
      ),
    );
  }

  const CaloriesTrackerPage({
    super.key,
    required this.calories,
    required this.calorieGoal,
    required this.carbs,
    required this.protein,
    required this.fats,
    required this.carbsGoal,
    required this.proteinGoal,
    required this.fatsGoal,
    required this.onChangeGoal,
    required this.onFastLog,
    required this.onUpdateMacros,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 50),
          Image.asset("assets/img/dashboard1logo.png", height: 100, width: 300),
          const SizedBox(height: 5),
          TrenTracker(
            width: 365,
            height: 360,
            calories: calories,
            calorieGoal: calorieGoal,
          ),
          const SizedBox(height: 20),
          MacrosTracker(
            width: 365,
            height: 200,
            carbs: carbs,
            protein: protein,
            fats: fats,
            carbsGoal: carbsGoal,
            proteinGoal: proteinGoal,
            fatsGoal: fatsGoal,
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TrenPalButton(
                icon: Icons.tune,
                width: 172,
                height: 50,
                showLoading: false,
                text: "Adjust Intake",
                onPressed: () async {
                  onChangeGoal();
                },
              ),
              const SizedBox(width: 10),
              TrenPalButton(
                icon: Icons.add_circle,
                width: 172,
                height: 50,
                showLoading: false,
                text: "Quick Add",
                onPressed: () async {
                  onFastLog();
                },
              ),
            ],
          ),
          SizedBox(height: 20),
          TrenPalButton(
            icon: Icons.edit,
            width: 360,
            height: 50,
            showLoading: false,
            text: "Adjust Macros",
            onPressed: () async {
              onUpdateMacros();
            },
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
