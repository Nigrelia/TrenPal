import 'package:flutter/material.dart';
import 'package:trenpal/custom widgets/foods.dart';

class FoodsPage extends StatefulWidget {
  final int calories;
  final int calorieGoal;
  final int carbs;
  final int protein;
  final int fats;
  final int carbsGoal;
  final int proteinGoal;
  final int fatsGoal;
  final Function(int, int, int, int, int) onUpdateMacros;
  final Function(BuildContext, int, int, int, int) onshowMacrosDialog;

  const FoodsPage({
    super.key,
    required this.calories,
    required this.calorieGoal,
    required this.carbs,
    required this.protein,
    required this.fats,
    required this.carbsGoal,
    required this.proteinGoal,
    required this.fatsGoal,
    required this.onUpdateMacros,
    required this.onshowMacrosDialog,
  });

  @override
  State<FoodsPage> createState() => _FoodsPageState();
}

class _FoodsPageState extends State<FoodsPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Image.asset("assets/img/nutl.png"),
          const SizedBox(height: 20),
          JsonDataEditor(
            jsonPath: 'assets/foods.json',
            jsonStructure: {
              'name': '',
              'calories': 0,
              'protein': 0.0,
              'carbs': 0.0,
              'fats': 0.0,
              'fiber': 0.0,
              'sugars': 0.0,
            },
            title: 'Food Nutrition Database',
            firstButtonText: 'Log Food',
            onFirstButtonPressed: (item) async {
              int calories = (item['calories'] ?? 0).toInt();
              int protein = (item['protein'] ?? 0).toInt();
              int carbs = (item['carbs'] ?? 0).toInt();
              int fats = (item['fats'] ?? 0).toInt();

              widget.onshowMacrosDialog(
                context,
                carbs,
                protein,
                fats,
                calories,
              );
            },
          ),
        ],
      ),
    );
  }
}
