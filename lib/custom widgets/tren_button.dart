import 'package:flutter/material.dart';

class TrenPalButton extends StatefulWidget {
  final String text;
  final Future<void> Function()? onPressed;
  final double? width;
  final double? height;
  final bool showLoading;
  final IconData? icon; // ✅ Optional icon

  const TrenPalButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height,
    this.showLoading = false,
    this.icon,
  });

  @override
  _TrenPalButtonState createState() => _TrenPalButtonState();
}

class _TrenPalButtonState extends State<TrenPalButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!_isLoading && widget.onPressed != null) {
      setState(() => _pressed = true);
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (!_isLoading) {
      setState(() => _pressed = false);
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (!_isLoading) {
      setState(() => _pressed = false);
      _animationController.reverse();
    }
  }

  Future<void> _handleTap() async {
    if (_isLoading || widget.onPressed == null) return;

    if (widget.showLoading) {
      setState(() {
        _isLoading = true;
        _pressed = false;
      });
      _animationController.reverse();

      try {
        await widget.onPressed!();
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      await widget.onPressed!();
      setState(() => _pressed = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final orientation = MediaQuery.of(context).orientation;

    double responsiveWidth;
    double responsiveHeight;

    if (widget.width != null && widget.height != null) {
      responsiveWidth = widget.width!;
      responsiveHeight = widget.height!;
    } else {
      if (orientation == Orientation.portrait) {
        responsiveWidth = screenWidth * 0.85;
        responsiveHeight = screenHeight * 0.07;
      } else {
        responsiveWidth = screenWidth * 0.6;
        responsiveHeight = screenHeight * 0.12;
      }
      responsiveWidth = responsiveWidth.clamp(280.0, 500.0);
      responsiveHeight = responsiveHeight.clamp(50.0, 80.0);
    }

    double borderRadius = responsiveWidth * 0.04;
    double fontSize = responsiveHeight * 0.28;
    double iconSize = responsiveHeight * 0.35;

    borderRadius = borderRadius.clamp(8.0, 16.0);
    fontSize = fontSize.clamp(14.0, 18.0);
    iconSize = iconSize.clamp(18.0, 24.0);

    bool isDisabled = widget.onPressed == null;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: _handleTap,
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: Container(
              width: responsiveWidth,
              height: responsiveHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  if (_pressed && !_isLoading && !isDisabled)
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(
                        0.4 * _glowAnimation.value,
                      ),
                      blurRadius: 20 * _glowAnimation.value,
                      spreadRadius: 2 * _glowAnimation.value,
                      offset: const Offset(0, 0),
                    ),
                  BoxShadow(
                    color: Colors.black.withOpacity(_pressed ? 0.4 : 0.2),
                    blurRadius: _pressed ? 12 : 6,
                    offset: Offset(0, _pressed ? 6 : 3),
                  ),
                ],
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isLoading
                        ? [const Color(0xFF505050), const Color(0xFF3A3A3A)]
                        : isDisabled
                        ? [const Color(0xFF2A2A2A), const Color(0xFF1A1A1A)]
                        : _pressed
                        ? [const Color(0xFF404040), const Color(0xFF2A2A2A)]
                        : [const Color(0xFF363636), const Color(0xFF1F1F1F)],
                  ),
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: _isLoading
                        ? Colors.grey.withOpacity(0.5)
                        : isDisabled
                        ? Colors.grey.withOpacity(0.2)
                        : _pressed
                        ? Colors.redAccent.withOpacity(0.8)
                        : Colors.redAccent.withOpacity(0.6),
                    width: _pressed ? 2 : 1.5,
                  ),
                ),
                child: Center(
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: iconSize,
                              height: iconSize,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.redAccent.withOpacity(0.8),
                                ),
                              ),
                            ),
                            SizedBox(width: responsiveWidth * 0.03),
                            Text(
                              'Loading...',
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontWeight: FontWeight.w600,
                                fontSize: fontSize * 0.9,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                size: iconSize,
                                color: isDisabled
                                    ? Colors.grey[600]
                                    : _pressed
                                    ? Colors.white
                                    : Colors.grey[300],
                              ),
                              SizedBox(width: responsiveWidth * 0.03),
                            ],
                            Flexible(
                              child: Text(
                                widget.text,
                                style: TextStyle(
                                  color: isDisabled
                                      ? Colors.grey[600]
                                      : _pressed
                                      ? Colors.white
                                      : Colors.grey[300],
                                  fontWeight: FontWeight.w600,
                                  fontSize: fontSize,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
