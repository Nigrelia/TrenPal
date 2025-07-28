import 'package:flutter/material.dart';

class GradientBack extends StatelessWidget {
  final Widget? child; // Optional child widget to place inside the container

  const GradientBack({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 0, 0, 0),
            Color.fromARGB(255, 2, 2, 2),
            Color.fromARGB(255, 4, 4, 4),
            Color.fromARGB(255, 6, 6, 6),
            Color.fromARGB(255, 8, 8, 8),
            Color.fromARGB(255, 10, 10, 10),
            Color.fromARGB(255, 12, 12, 12),
            Color.fromARGB(255, 14, 14, 14),
            Color.fromARGB(255, 16, 16, 16),
            Color.fromARGB(255, 19, 19, 19),
          ],
        ),
      ),
      child: child, // Allows you to add content inside the container
    );
  }
}
