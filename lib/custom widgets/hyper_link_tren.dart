import 'package:flutter/material.dart';

class TrenPalHyperText extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final double? fontSize;
  final Color? color;
  final Color? hoverColor;
  final bool showUnderline;
  final FontWeight? fontWeight;
  final Duration animationDuration;
  final EdgeInsetsGeometry? padding;

  const TrenPalHyperText({
    super.key,
    required this.text,
    required this.onPressed,
    this.fontSize,
    this.color,
    this.hoverColor,
    this.showUnderline = true,
    this.fontWeight,
    this.animationDuration = const Duration(milliseconds: 200),
    this.padding,
  });

  @override
  State<TrenPalHyperText> createState() => _TrenPalHyperTextState();
}

class _TrenPalHyperTextState extends State<TrenPalHyperText>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _colorAnimation =
        ColorTween(
          begin: widget.color ?? Colors.red,
          // ignore: deprecated_member_use
          end: widget.hoverColor ?? Colors.red.withOpacity(0.7),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding:
                  widget.padding ??
                  const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
              child: Text(
                widget.text,
                style: TextStyle(
                  color: _colorAnimation.value,
                  decoration: widget.showUnderline
                      ? TextDecoration.underline
                      : TextDecoration.none,
                  decorationColor: _colorAnimation.value,
                  fontSize: widget.fontSize ?? 14,
                  fontWeight: widget.fontWeight ?? FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Add this smooth navigation helper
class SmoothNavigation {
  // Subtle fade transition - barely noticeable but smooth
  static void subtleFade(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation.drive(
              Tween(
                begin: 0.0,
                end: 1.0,
              ).chain(CurveTween(curve: Curves.easeInOut)),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  // Very subtle slide - almost imperceptible
  static void subtleSlide(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(
                begin: const Offset(0.1, 0.0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOutQuart)),
            ),
            child: FadeTransition(
              opacity: animation.drive(
                Tween(
                  begin: 0.0,
                  end: 1.0,
                ).chain(CurveTween(curve: Curves.easeIn)),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  // Almost instant but smooth
  static void quickSwap(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation.drive(
              Tween(
                begin: 0.3,
                end: 1.0,
              ).chain(CurveTween(curve: Curves.easeOut)),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 150),
      ),
    );
  }
}

// Enhanced version with ripple effect
class TrenPalHyperTextRipple extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? fontSize;
  final Color? color;
  final Color? rippleColor;
  final bool showUnderline;
  final FontWeight? fontWeight;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const TrenPalHyperTextRipple({
    super.key,
    required this.text,
    required this.onPressed,
    this.fontSize,
    this.color,
    this.rippleColor,
    this.showUnderline = true,
    this.fontWeight,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: borderRadius ?? BorderRadius.circular(4),
        splashColor: rippleColor ?? (color ?? Colors.red).withOpacity(0.1),
        highlightColor: (color ?? Colors.red).withOpacity(0.05),
        child: Container(
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text(
            text,
            style: TextStyle(
              color: color ?? Colors.red,
              decoration: showUnderline
                  ? TextDecoration.underline
                  : TextDecoration.none,
              decorationColor: color ?? Colors.red,
              fontSize: fontSize ?? 14,
              fontWeight: fontWeight ?? FontWeight.w500,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
