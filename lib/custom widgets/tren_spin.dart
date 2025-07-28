import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class TrenSpin extends StatefulWidget {
  final String prompt;
  final double? width;
  final double? height;
  final int initialValue;
  final int minValue;
  final int maxValue;
  final int step;
  final ValueChanged<int>? onChanged;
  final TextEditingController? controller; // 🔥 NEW PARAMETER

  const TrenSpin({
    super.key,
    required this.prompt,
    this.width,
    this.height,
    this.initialValue = 0,
    this.minValue = 0,
    this.maxValue = 10000,
    this.step = 1,
    this.onChanged,
    this.controller, // 🔥 OPTIONAL CONTROLLER
  });

  @override
  _TrenSpinState createState() => _TrenSpinState();
}

class _TrenSpinState extends State<TrenSpin>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  late final TextEditingController _controller;
  bool _isFocused = false;
  late int _currentValue;
  late AnimationController _animationController;
  bool _isControllerInternal = false; // Track if we created the controller

  bool get shouldShowFloatingLabel =>
      _isFocused || _currentValue != widget.initialValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;

    // 🔥 USE PROVIDED CONTROLLER OR CREATE NEW ONE
    if (widget.controller != null) {
      _controller = widget.controller!;
      _isControllerInternal = false;
      // Set initial value if controller is empty
      if (_controller.text.isEmpty) {
        _controller.text = _currentValue.toString();
      } else {
        // Use controller's current value
        int? controllerValue = int.tryParse(_controller.text);
        if (controllerValue != null) {
          _currentValue = controllerValue.clamp(
            widget.minValue,
            widget.maxValue,
          );
        }
      }
    } else {
      _controller = TextEditingController(text: _currentValue.toString());
      _isControllerInternal = true;
    }

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
      if (_isFocused) {
        _animationController.forward();
        // Select all text when focused
        _controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controller.text.length,
        );
      } else {
        _animationController.reverse();
        _validateAndUpdateValue();
      }
    });

    _controller.addListener(() {
      // Only update if the text is different from current value
      if (_controller.text != _currentValue.toString()) {
        _validateAndUpdateValue();
      }
    });
  }

  void _validateAndUpdateValue() {
    String text = _controller.text;
    if (text.isEmpty) {
      _updateValue(widget.minValue);
      return;
    }

    int? newValue = int.tryParse(text);
    if (newValue != null) {
      _updateValue(newValue.clamp(widget.minValue, widget.maxValue));
    } else {
      // If invalid input, revert to current value
      _controller.text = _currentValue.toString();
    }
  }

  void _updateValue(int newValue) {
    if (newValue != _currentValue) {
      setState(() {
        _currentValue = newValue;
        _controller.text = _currentValue.toString();
      });
      widget.onChanged?.call(_currentValue);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _animationController.dispose();
    // 🔥 ONLY DISPOSE IF WE CREATED THE CONTROLLER
    if (_isControllerInternal) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _increment() {
    if (_currentValue < widget.maxValue) {
      _updateValue(
        (_currentValue + widget.step).clamp(widget.minValue, widget.maxValue),
      );
    }
  }

  void _decrement() {
    if (_currentValue > widget.minValue) {
      _updateValue(
        (_currentValue - widget.step).clamp(widget.minValue, widget.maxValue),
      );
    }
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
          height: responsiveHeight + (shouldShowFloatingLabel ? 20 : 0),
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

              // Main spin container
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
                    child: Row(
                      children: [
                        // Decrement button
                        _buildSpinButton(
                          icon: Icons.remove,
                          onPressed: _currentValue > widget.minValue
                              ? _decrement
                              : null,
                          iconSize: iconSize,
                          borderRadius: borderRadius,
                        ),

                        // Typable text field
                        Expanded(
                          child: Center(
                            child: TextField(
                              focusNode: _focusNode,
                              controller: _controller,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: fontSize,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              cursorColor: Colors.redAccent,
                              cursorWidth: max(2.0, responsiveWidth * 0.005),
                              cursorHeight: 20,
                              decoration: InputDecoration(
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
                                  horizontal: 8,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Increment button
                        _buildSpinButton(
                          icon: Icons.add,
                          onPressed: _currentValue < widget.maxValue
                              ? _increment
                              : null,
                          iconSize: iconSize,
                          borderRadius: borderRadius,
                        ),
                      ],
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

  Widget _buildSpinButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required double iconSize,
    required double borderRadius,
  }) {
    bool isEnabled = onPressed != null;

    return Container(
      width: 50,
      height: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          right: icon == Icons.remove
              ? BorderSide(color: Colors.grey.withOpacity(0.3), width: 1)
              : BorderSide.none,
          left: icon == Icons.add
              ? BorderSide(color: Colors.grey.withOpacity(0.3), width: 1)
              : BorderSide.none,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.horizontal(
            left: icon == Icons.remove
                ? Radius.circular(borderRadius)
                : Radius.zero,
            right: icon == Icons.add
                ? Radius.circular(borderRadius)
                : Radius.zero,
          ),
          splashColor: Colors.redAccent.withOpacity(0.1),
          highlightColor: Colors.redAccent.withOpacity(0.05),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isEnabled
                    ? (_isFocused
                          ? Colors.redAccent.withOpacity(0.8)
                          : Colors.grey[300])
                    : Colors.grey[600],
                size: iconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
