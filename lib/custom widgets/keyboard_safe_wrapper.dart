import 'package:flutter/material.dart';
import 'package:trenpal/custom%20widgets/gradiant_back.dart';

class KeyboardSafeWrapper extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool enableScrolling;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool useGradientBackground;

  const KeyboardSafeWrapper({
    super.key,
    required this.child,
    this.padding,
    this.enableScrolling = true,
    this.mainAxisAlignment = MainAxisAlignment.center,
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
          if (useGradientBackground) GradientBack(),

          // Content with keyboard handling
          SafeArea(
            child: enableScrolling
                ? SingleChildScrollView(
                    padding: padding ?? const EdgeInsets.all(16.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top -
                            MediaQuery.of(context).padding.bottom -
                            32,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: mainAxisAlignment,
                          crossAxisAlignment: crossAxisAlignment,
                          children: [child],
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: padding ?? const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: mainAxisAlignment,
                      crossAxisAlignment: crossAxisAlignment,
                      children: [Expanded(child: child)],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
