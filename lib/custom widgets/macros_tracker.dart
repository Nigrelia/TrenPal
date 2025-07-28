import 'package:flutter/material.dart';

class MacrosTracker extends StatelessWidget {
  final double width;
  final double height;
  final int carbs;
  final int protein;
  final int fats;
  final int carbsGoal;
  final int proteinGoal;
  final int fatsGoal;

  const MacrosTracker({
    super.key,
    required this.width,
    required this.height,
    required this.carbs,
    required this.protein,
    required this.fats,
    required this.carbsGoal,
    required this.proteinGoal,
    required this.fatsGoal,
  });

  @override
  Widget build(BuildContext context) {
    // Neon color palette
    const Color neonCarbs = Color(0xFF00F9FF); // Cyan
    const Color neonProtein = Color(0xFF39FF14); // Green
    const Color neonFats = Color(0xFFFF00FF); // Magenta

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2B0000), Color(0xFF400101), Color(0xFF3F0B0B)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "MACROS TRACKER",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),
          _buildNeonMacroBar("Carbs", carbs, carbsGoal, neonCarbs),
          const SizedBox(height: 12),
          _buildNeonMacroBar("Protein", protein, proteinGoal, neonProtein),
          const SizedBox(height: 12),
          _buildNeonMacroBar("Fats", fats, fatsGoal, neonFats),
        ],
      ),
    );
  }

  Widget _buildNeonMacroBar(
    String label,
    int value,
    int goal,
    Color neonColor,
  ) {
    double percent = (value / goal).clamp(0.0, 1.0);
    bool isComplete = percent >= 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: neonColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: neonColor.withOpacity(0.8),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "$label: ",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                  TextSpan(
                    text: "$value",
                    style: TextStyle(
                      color: neonColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: neonColor.withOpacity(0.8),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  TextSpan(
                    text: " / $goal g",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutQuint,
                height: 10,
                width: percent * (width - 32), // Account for padding
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      neonColor.withOpacity(0.9),
                      neonColor.withOpacity(0.7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: neonColor.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
            if (isComplete)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: RadialGradient(
                      colors: [neonColor.withOpacity(0.3), Colors.transparent],
                      radius: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
