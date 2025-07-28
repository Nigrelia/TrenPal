import 'package:flutter/material.dart';
import 'package:trenpal/custom%20widgets/gradiant_back.dart'; // Import your gradient

class SafeV2 extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool enableScrolling;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool useGradientBackground;

  const SafeV2({
    super.key,
    required this.child,
    this.padding,
    this.enableScrolling = true,
    this.mainAxisAlignment = MainAxisAlignment.start, // Changed to start
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.useGradientBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Gradient background
          if (useGradientBackground) const GradientBack(),

          // Content with keyboard handling
          SafeArea(
            top: false, // Disable top safe area
            bottom: true,
            child: enableScrolling
                ? SingleChildScrollView(
                    padding:
                        padding ?? EdgeInsets.zero, // Removed default padding
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height,
                      ),
                      child: child, // Direct child without additional Column
                    ),
                  )
                : Padding(
                    padding:
                        padding ?? EdgeInsets.zero, // Removed default padding
                    child: child, // Direct child without additional Column
                  ),
          ),
        ],
      ),
    );
  }
}
