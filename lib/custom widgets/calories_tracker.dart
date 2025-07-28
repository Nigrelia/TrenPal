import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class TrenTracker extends StatelessWidget {
  final double width;
  final double height;
  final int calories;
  final int calorieGoal;
  final String title;
  final IconData icon;
  final List<Color> gradientColors;
  final bool showStreak;
  final int streakDays;

  const TrenTracker({
    super.key,
    required this.width,
    required this.height,
    required this.calories,
    required this.calorieGoal,
    this.title = "Calories Intake",
    this.icon = Icons.local_fire_department,
    this.gradientColors = const [
      Color(0xFFFF6B6B),
      Color(0xFFFF8E53),
      Color(0xFFFF6B9D),
    ],
    this.showStreak = true,
    this.streakDays = 0,
  });

  @override
  Widget build(BuildContext context) {
    double percent = (calories / calorieGoal).clamp(0.0, 1.0);
    bool goalReached = percent >= 1.0;
    int remaining = (calorieGoal - calories).clamp(0, calorieGoal);

    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2B0000), Color(0xFF400101), Color(0xFF3F0B0B)],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header with title and streak
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 0.8,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (showStreak && streakDays > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.local_fire_department,
                                  size: 12,
                                  color: Colors.orange.shade300,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$streakDays day${streakDays > 1 ? 's' : ''} streak',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.orange.shade300,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradientColors),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors.first.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 18),
                  ),
                ],
              ),

              // Main progress circle with stats
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double circleSize = constraints.maxWidth * 0.7;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        if (goalReached)
                          Container(
                            width: circleSize * 1.1,
                            height: circleSize * 1.1,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  gradientColors.first.withOpacity(0.2),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        CircularPercentIndicator(
                          radius: circleSize / 2,
                          lineWidth: 10.0,
                          percent: percent,
                          animation: true,
                          animationDuration: 1200,
                          center: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: gradientColors,
                                ).createShader(bounds),
                                child: Text(
                                  '$calories',
                                  style: TextStyle(
                                    fontSize: circleSize * 0.22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Text(
                                'calories',
                                style: TextStyle(
                                  fontSize: circleSize * 0.08,
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                          backgroundColor: Colors.white.withOpacity(0.15),
                          linearGradient: LinearGradient(
                            colors: gradientColors,
                          ),
                        ),
                        Positioned(
                          bottom: circleSize * 0.1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: goalReached
                                  ? LinearGradient(colors: gradientColors)
                                  : null,
                              color: goalReached
                                  ? null
                                  : Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                if (goalReached)
                                  const Icon(Icons.celebration, size: 14),
                                Text(
                                  goalReached
                                      ? ' GOAL ACHIEVED! '
                                      : '${(percent * 100).toInt()}% Complete',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Big Goal & Left Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildProminentStat(
                    icon: Icons.flag,
                    value: '$calorieGoal',
                    label: 'Daily Goal',
                    color: Colors.blue.shade300,
                  ),
                  _buildProminentStat(
                    icon: remaining > 0 ? Icons.trending_up : Icons.celebration,
                    value: remaining > 0
                        ? '$remaining'
                        : '+${calories - calorieGoal}',
                    label: remaining > 0 ? 'Left' : 'Extra',
                    color: remaining > 0
                        ? Colors.orange.shade300
                        : Colors.green.shade300,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProminentStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
