import 'package:flutter/material.dart';
import 'dart:math';

class AnimatedComboBox extends StatefulWidget {
  final String prompt;
  final TextEditingController? controller;
  final double? width;
  final double? height;
  final List<String> options;
  final String? selectedValue;
  final void Function(String?)? onChanged;

  const AnimatedComboBox({
    super.key,
    required this.prompt,
    required this.options,
    this.controller,
    this.width,
    this.height,
    this.selectedValue,
    this.onChanged,
  });

  @override
  _AnimatedComboBoxState createState() => _AnimatedComboBoxState();
}

class _AnimatedComboBoxState extends State<AnimatedComboBox>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _isOpen = false;
  late final TextEditingController _controller;
  bool _isControllerInternal = false;
  String? _selectedValue;

  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  bool get hasValue => _selectedValue != null && _selectedValue!.isNotEmpty;
  bool get shouldShowFloatingLabel => _isFocused || hasValue || _isOpen;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
      if (_isFocused || _isOpen) {
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

    // Set initial value
    if (widget.selectedValue != null) {
      _selectedValue = widget.selectedValue;
      _controller.text = _selectedValue!;
    }
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

  void _toggleDropdown() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _focusNode.requestFocus();
        _animationController.forward();
      } else {
        _focusNode.unfocus();
        _animationController.reverse();
      }
    });
  }

  void _selectOption(String option) {
    setState(() {
      _selectedValue = option;
      _controller.text = option;
      _isOpen = false;
    });
    _animationController.reverse();
    widget.onChanged?.call(option);
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
              (shouldShowFloatingLabel ? 20 : 0) +
              (_isOpen ? min(widget.options.length * 50.0, 200.0) : 0),
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
                        ? (_isFocused || _isOpen
                              ? Colors.redAccent
                              : Colors.grey[300])
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

              // Main combo box container
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                top: shouldShowFloatingLabel ? 18 : 0,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    // Main input container
                    GestureDetector(
                      onTap: _toggleDropdown,
                      child: Container(
                        height: responsiveHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(borderRadius),
                          boxShadow: [
                            if (_isFocused || _isOpen)
                              BoxShadow(
                                color: Colors.redAccent.withOpacity(
                                  0.3 * _animationController.value,
                                ),
                                blurRadius: 20 * _animationController.value,
                                spreadRadius: 2 * _animationController.value,
                                offset: const Offset(0, 0),
                              ),
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                (_isFocused || _isOpen) ? 0.4 : 0.2,
                              ),
                              blurRadius: (_isFocused || _isOpen) ? 12 : 6,
                              offset: Offset(
                                0,
                                (_isFocused || _isOpen) ? 6 : 3,
                              ),
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
                              colors: (_isFocused || _isOpen)
                                  ? [
                                      const Color(0xFF404040),
                                      const Color(0xFF2A2A2A),
                                    ]
                                  : [
                                      const Color(0xFF363636),
                                      const Color(0xFF1F1F1F),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(borderRadius),
                            border: Border.all(
                              color: (_isFocused || _isOpen)
                                  ? Colors.redAccent.withOpacity(0.6)
                                  : Colors.grey.withOpacity(0.2),
                              width: (_isFocused || _isOpen) ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Center(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      hasValue
                                          ? _selectedValue!
                                          : (shouldShowFloatingLabel
                                                ? ''
                                                : widget.prompt),
                                      style: TextStyle(
                                        color: hasValue
                                            ? Colors.white
                                            : Colors.grey[500],
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Dropdown arrow
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                child: RotationTransition(
                                  turns: _rotationAnimation,
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: (_isFocused || _isOpen)
                                        ? Colors.redAccent.withOpacity(0.8)
                                        : Colors.grey[400],
                                    size: iconSize,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Dropdown options
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: _isOpen
                          ? min(widget.options.length * 50.0, 200.0)
                          : 0,
                      child: _isOpen
                          ? Container(
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF404040),
                                    Color(0xFF2A2A2A),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(
                                  borderRadius,
                                ),
                                border: Border.all(
                                  color: Colors.redAccent.withOpacity(0.6),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  borderRadius,
                                ),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: widget.options.length,
                                  itemBuilder: (context, index) {
                                    final option = widget.options[index];
                                    final isSelected = option == _selectedValue;

                                    return InkWell(
                                      onTap: () => _selectOption(option),
                                      child: Container(
                                        height: 50,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: horizontalPadding,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.redAccent.withOpacity(
                                                  0.1,
                                                )
                                              : Colors.transparent,
                                          border:
                                              index < widget.options.length - 1
                                              ? Border(
                                                  bottom: BorderSide(
                                                    color: Colors.grey
                                                        .withOpacity(0.2),
                                                    width: 0.5,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                option,
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? Colors.redAccent
                                                      : Colors.white,
                                                  fontSize: fontSize * 0.9,
                                                  fontWeight: isSelected
                                                      ? FontWeight.w500
                                                      : FontWeight.w400,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                            ),
                                            if (isSelected)
                                              Icon(
                                                Icons.check_rounded,
                                                color: Colors.redAccent,
                                                size: iconSize * 0.8,
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
