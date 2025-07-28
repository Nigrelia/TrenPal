import 'package:flutter/material.dart';
import 'dart:math';

class AnimatedGrayTextField extends StatefulWidget {
  final String prompt;
  final double? width;
  final double? height;
  final String inputType; // "text" or "password"
  final TextEditingController? controller;

  const AnimatedGrayTextField({
    super.key,
    required this.prompt,
    this.width,
    this.height,
    this.inputType = "text",
    this.controller,
  });

  @override
  _AnimatedGrayTextFieldState createState() => _AnimatedGrayTextFieldState();
}

class _AnimatedGrayTextFieldState extends State<AnimatedGrayTextField>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _obscureText = true;
  late final TextEditingController _controller;
  bool _isControllerInternal = false;

  late AnimationController _animationController;

  bool get isPassword => widget.inputType.toLowerCase() == "password";
  bool get hasText => _controller.text.isNotEmpty;
  bool get shouldShowFloatingLabel => _isFocused || hasText;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
      if (_isFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });

    if (widget.controller == null) {
      _controller = TextEditingController();
      _isControllerInternal = true;
    } else {
      _controller = widget.controller!;
    }

    // Listen to text changes
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _animationController.dispose();
    if (_isControllerInternal) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
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
        responsiveWidth = screenWidth * 0.85;
        responsiveHeight = screenHeight * 0.07;
      } else {
        responsiveWidth = screenWidth * 0.6;
        responsiveHeight = screenHeight * 0.12;
      }

      responsiveWidth = responsiveWidth.clamp(280.0, 500.0);
      responsiveHeight = responsiveHeight.clamp(50.0, 80.0);
    }

    // Scale other elements
    double borderRadius = responsiveWidth * 0.04;
    double horizontalPadding = responsiveWidth * 0.04;
    double verticalPadding = responsiveHeight * 0.3;
    double fontSize = responsiveHeight * 0.28;
    double iconSize = responsiveHeight * 0.35;

    // Ensure minimum readable sizes
    borderRadius = borderRadius.clamp(8.0, 16.0);
    horizontalPadding = horizontalPadding.clamp(12.0, 20.0);
    verticalPadding = verticalPadding.clamp(16.0, 24.0);
    fontSize = fontSize.clamp(14.0, 18.0);
    iconSize = iconSize.clamp(20.0, 26.0);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SizedBox(
          width: responsiveWidth,
          height:
              responsiveHeight +
              (shouldShowFloatingLabel
                  ? 20
                  : 0), // Extra space for floating label
          child: Stack(
            children: [
              // Floating label outside the border
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: horizontalPadding,
                top: shouldShowFloatingLabel ? 0 : responsiveHeight * 0.5 - 10,
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    color: shouldShowFloatingLabel
                        ? (_isFocused ? Colors.redAccent : Colors.grey[300])
                        : Colors.grey[400],
                    fontSize: shouldShowFloatingLabel ? 12 : fontSize * 0.9,
                    fontWeight: shouldShowFloatingLabel
                        ? FontWeight.w600
                        : FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: shouldShowFloatingLabel ? 1.0 : 0.7,
                    child: Container(
                      padding: shouldShowFloatingLabel
                          ? const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            )
                          : EdgeInsets.zero,
                      decoration: shouldShowFloatingLabel
                          ? BoxDecoration(
                              color: Colors.black.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(4),
                            )
                          : null,
                      child: Text(widget.prompt),
                    ),
                  ),
                ),
              ),

              // Main text field container
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                top: shouldShowFloatingLabel ? 18 : 0,
                left: 0,
                right: 0,
                child: Container(
                  height: responsiveHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    boxShadow: [
                      if (_isFocused)
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(
                            0.3 * _animationController.value,
                          ),
                          blurRadius: 20 * _animationController.value,
                          spreadRadius: 2 * _animationController.value,
                          offset: const Offset(0, 0),
                        ),
                      BoxShadow(
                        color: Colors.black.withOpacity(_isFocused ? 0.4 : 0.2),
                        blurRadius: _isFocused ? 12 : 6,
                        offset: Offset(0, _isFocused ? 6 : 3),
                      ),
                    ],
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _isFocused
                            ? [const Color(0xFF404040), const Color(0xFF2A2A2A)]
                            : [
                                const Color(0xFF363636),
                                const Color(0xFF1F1F1F),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(borderRadius),
                      border: Border.all(
                        color: _isFocused
                            ? Colors.redAccent.withOpacity(0.6)
                            : Colors.grey.withOpacity(0.2),
                        width: _isFocused ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: TextField(
                        focusNode: _focusNode,
                        controller: _controller,
                        obscureText: isPassword ? _obscureText : false,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                        ),
                        cursorColor: Colors.redAccent,
                        cursorWidth: max(2.0, responsiveWidth * 0.005),
                        cursorHeight: 20,
                        decoration: InputDecoration(
                          // Remove label since we're using floating label outside
                          hintText: shouldShowFloatingLabel
                              ? null
                              : widget.prompt,
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: fontSize * 0.9,
                            fontWeight: FontWeight.w400,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: verticalPadding,
                          ),
                          suffixIcon: isPassword
                              ? Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  child: IconButton(
                                    icon: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      child: Icon(
                                        _obscureText
                                            ? Icons.visibility_off_rounded
                                            : Icons.visibility_rounded,
                                        key: ValueKey(_obscureText),
                                        color: _isFocused
                                            ? Colors.redAccent.withOpacity(0.8)
                                            : Colors.grey[400],
                                        size: iconSize,
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(
                                        () => _obscureText = !_obscureText,
                                      );
                                    },
                                    splashRadius: 24,
                                    splashColor: Colors.redAccent.withOpacity(
                                      0.1,
                                    ),
                                    highlightColor: Colors.redAccent
                                        .withOpacity(0.05),
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
