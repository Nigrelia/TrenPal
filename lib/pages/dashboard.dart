import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'food_page.dart';

import 'package:trenpal/custom%20widgets/safe_v2.dart';
import 'package:trenpal/custom%20widgets/ten_bot_nav.dart';
import 'package:trenpal/custom%20widgets/tren_alerts.dart';

import '../custom widgets/tren_popup.dart';
import 'main_screen.dart';
import 'calories_page.dart';

import 'package:shared_preferences/shared_preferences.dart';

class TrenDashboard extends StatefulWidget {
  const TrenDashboard({super.key});

  @override
  State<TrenDashboard> createState() => _TrenDashboardState();
}

class _TrenDashboardState extends State<TrenDashboard> {
  int calorieGoal = 2000;
  int calories = 0;
  int carbs = 0, protein = 0, fats = 0;
  int carbsGoal = 300, proteinGoal = 150, fatsGoal = 70;
  int _currentIndex = 0;
  bool isLoading = true;
  int car = 0, prot = 0, fat = 0, cals = 0;

  Future<bool> _showLogoutConfirmation() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2A2A2A),
              title: const Text(
                'Logout Confirmation',
                style: TextStyle(color: Colors.white),
              ),
              content: const Text(
                'Are you sure you want to logout?',
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(true);
                    await _performLogout();
                  },
                  child: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _performLogout() async {
    final prefs = await SharedPreferences.getInstance();
    bool _isChecked = prefs.getBool('rememberMe') ?? false;
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        _isChecked = false;
        await prefs.setBool('rememberMe', _isChecked);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      print("Error during logout: $e");
      if (mounted) {
        TrenAlerts.error(context, "Failed to logout. Please try again.");
      }
    }
  }

  Future<void> changeGoal(String userId, int newGoal) async {
    try {
      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(userId);
      await userDoc.update({"intake": newGoal});
      setState(() {
        calorieGoal = newGoal;
      });
      TrenAlerts.success(context, "Goal Updated !");
    } catch (e) {
      print("Error updating goal: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update calorie goal'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void showTrenPalPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => TrenPalPopup(
        title: 'Set Calorie Goal',
        buttonText: 'Update Goal',
        onSubmit: (value) async {
          await changeGoal(FirebaseAuth.instance.currentUser!.uid, value);
        },
        initialValue: calorieGoal,
        minValue: 1000,
        maxValue: 5000,
        step: 50,
      ),
    );
  }

  void showFastLogPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => TrenPalPopup(
        title: 'Quick Calorie Log',
        buttonText: 'Add Calories',
        onSubmit: (value) async {
          await addCalories(FirebaseAuth.instance.currentUser!.uid, value);
        },
        initialValue: 0,
        minValue: 0,
        maxValue: 2000,
        step: 10,
      ),
    );
  }

  void showMacrosDialog(BuildContext context, int c, int p, int f, int cc) {
    showDialog(
      context: context,
      builder: (context) => TrenPalPopup(
        title: 'Serving in Grams',
        buttonText: 'Log Food',
        onSubmit: (value) async {
          UpdateMacros(c, p, f, cc, value);
        },
        initialValue: 0,
        minValue: 0,
        maxValue: 2000,
        step: 10,
      ),
    );
  }

  List<Widget> get _pages => [
    CaloriesTrackerPage(
      calories: calories,
      calorieGoal: calorieGoal,
      carbs: carbs,
      protein: protein,
      fats: fats,
      carbsGoal: carbsGoal,
      proteinGoal: proteinGoal,
      fatsGoal: fatsGoal,
      onChangeGoal: () => showTrenPalPopup(context),
      onFastLog: () => showFastLogPopup(context),
    ),
    FoodsPage(
      calories: calories,
      calorieGoal: calorieGoal,
      carbs: carbs,
      protein: protein,
      fats: fats,
      carbsGoal: carbsGoal,
      proteinGoal: proteinGoal,
      fatsGoal: fatsGoal,
      onUpdateMacros: UpdateMacros,
      onshowMacrosDialog: showMacrosDialog,
    ),
    const AICoachPage(),
    const AccountPage(),
  ];

  @override
  void initState() {
    super.initState();
    getCalories();
  }

  Future<void> getCalories() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          carbs = (double.tryParse(data['carbs']?.toString() ?? '0') ?? 0)
              .round();
          protein = (double.tryParse(data['protein']?.toString() ?? '0') ?? 0)
              .round();
          fats = (double.tryParse(data['fats']?.toString() ?? '0') ?? 0)
              .round();

          carbsGoal =
              (double.tryParse(data['carbsGoal']?.toString() ?? '300') ?? 300)
                  .round();
          proteinGoal =
              (double.tryParse(data['proteinGoal']?.toString() ?? '150') ?? 150)
                  .round();
          fatsGoal =
              (double.tryParse(data['fatsGoal']?.toString() ?? '70') ?? 70)
                  .round();

          calorieGoal =
              (double.tryParse(data['intake']?.toString() ?? '2000') ?? 2000)
                  .round();
          calories =
              (double.tryParse(data['currentIntake']?.toString() ?? '0') ?? 0)
                  .round();

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error getting calories: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> addCalories(String userId, int additionalCalories) async {
    try {
      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(userId);
      final newTotal = calories + additionalCalories;
      await userDoc.update({"currentIntake": newTotal});
      setState(() {
        calories = newTotal;
      });
      TrenAlerts.success(context, "Calories Added");
    } catch (e) {
      print("Error adding calories: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add calories'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> UpdateMacros(
    int carbss,
    int proteins,
    int fatss,
    int additionalCalories,
    int value,
  ) async {
    double Mult = value / 100;
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    try {
      final newTotal = (calories + additionalCalories) * Mult;
      final carbsTot = (carbss + carbs) * Mult;
      final fatssTot = (fatss + fats) * Mult;
      final proteinsTot = (proteins + protein) * Mult;
      await userDoc.update({
        "carbs": carbsTot,
        "fats": fatssTot,
        "protein": proteinsTot,
        "currentIntake": newTotal,
      });
      setState(() {
        calories = newTotal.round();
        carbs = carbsTot.round();
        protein = proteinsTot.round();
        fats = fatssTot.round();
      });
      TrenAlerts.success(context, "Meal logged");
    } catch (e) {
      print("Error adding macros: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add macros'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A1A1A),
        body: Center(child: CircularProgressIndicator(color: Colors.redAccent)),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (!didPop) {
          await _showLogoutConfirmation();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        body: SafeV2(child: _pages[_currentIndex]),
        bottomNavigationBar: TrenPalBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavItem(
              label: 'Calories',
              icon: Icons.local_fire_department_rounded,
              badgeCount: 0,
            ),
            BottomNavItem(
              label: 'Foods',
              icon: Icons.fastfood_rounded,
              badgeCount: 0,
            ),
            BottomNavItem(
              label: 'AI Coach',
              icon: Icons.auto_awesome_rounded,
              badgeCount: 0,
            ),
            BottomNavItem(
              label: 'Account',
              icon: Icons.account_circle_rounded,
              badgeCount: 0,
            ),
          ],
          activeColor: Colors.redAccent,
        ),
      ),
    );
  }
}

class AICoachPage extends StatelessWidget {
  const AICoachPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Incoming ...',
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Incoming ...',
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }
}
