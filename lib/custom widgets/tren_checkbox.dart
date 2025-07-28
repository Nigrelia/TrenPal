import 'package:flutter/material.dart';

class TrenPalCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final String? label;
  final double? width;
  final double? height;
  final bool showLoading;
  final Color? activeColor;
  final Color? checkColor;
  final Color? borderColor;
  final double? borderRadius;
  final EdgeInsets? padding;

  const TrenPalCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.width,
    this.height,
    this.showLoading = false,
    this.activeColor,
    this.checkColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
  });

  @override
  _TrenPalCheckboxState createState() => _TrenPalCheckboxState();
}

class _TrenPalCheckboxState extends State<TrenPalCheckbox>
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
    if (!_isLoading && widget.onChanged != null) {
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
    if (_isLoading || widget.onChanged == null) return;

    if (widget.showLoading) {
      setState(() {
        _isLoading = true;
        _pressed = false;
      });
      _animationController.reverse();

      try {
        await Future.delayed(
          const Duration(milliseconds: 300),
        ); // Simulate async operation
        widget.onChanged!(!widget.value);
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      widget.onChanged!(!widget.value);
      setState(() => _pressed = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsiveness
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final orientation = MediaQuery.of(context).orientation;

    // Calculate responsive dimensions
    double responsiveWidth;
    double responsiveHeight;

    if (widget.width != null && widget.height != null) {
      responsiveWidth = widget.width!;
      responsiveHeight = widget.height!;
    } else {
      if (orientation == Orientation.portrait) {
        responsiveWidth = screenWidth * (widget.label == null ? 0.12 : 0.85);
        responsiveHeight = screenHeight * 0.07;
      } else {
        responsiveWidth = screenWidth * (widget.label == null ? 0.08 : 0.6);
        responsiveHeight = screenHeight * 0.12;
      }
      responsiveWidth = responsiveWidth.clamp(40.0, 500.0);
      responsiveHeight = responsiveHeight.clamp(40.0, 80.0);
    }

    // Scale other elements
    double borderRadius = widget.borderRadius ?? responsiveWidth * 0.15;
    double fontSize = responsiveHeight * 0.28;
    double iconSize = responsiveHeight * 0.35;

    // Ensure minimum readable sizes
    borderRadius = borderRadius.clamp(4.0, 16.0);
    fontSize = fontSize.clamp(14.0, 18.0);
    iconSize = iconSize.clamp(18.0, 24.0);

    bool isDisabled = widget.onChanged == null;
    final activeColor = widget.activeColor ?? Colors.redAccent;
    final checkColor = widget.checkColor ?? Colors.white;
    final borderColor = widget.borderColor ?? Colors.redAccent.withOpacity(0.6);

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
              padding: widget.padding ?? EdgeInsets.zero,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  if (_pressed && !_isLoading && !isDisabled)
                    BoxShadow(
                      color: activeColor.withOpacity(
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: responsiveHeight * 0.8,
                    height: responsiveHeight * 0.8,
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
                            : [
                                const Color(0xFF363636),
                                const Color(0xFF1F1F1F),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(borderRadius),
                      border: Border.all(
                        color: _isLoading
                            ? Colors.grey.withOpacity(0.5)
                            : isDisabled
                            ? Colors.grey.withOpacity(0.2)
                            : _pressed
                            ? activeColor.withOpacity(0.8)
                            : borderColor,
                        width: _pressed ? 2 : 1.5,
                      ),
                    ),
                    child: Center(
                      child: _isLoading
                          ? SizedBox(
                              width: iconSize * 0.6,
                              height: iconSize * 0.6,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  activeColor.withOpacity(0.8),
                                ),
                              ),
                            )
                          : AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: widget.value
                                  ? Icon(
                                      Icons.check,
                                      size: iconSize,
                                      color: checkColor,
                                    )
                                  : const SizedBox(),
                            ),
                    ),
                  ),
                  if (widget.label != null) ...[
                    SizedBox(width: responsiveWidth * 0.03),
                    Expanded(
                      child: Text(
                        widget.label!,
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
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
