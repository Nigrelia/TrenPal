import 'package:flutter/material.dart';

class AnimatedDatePicker extends StatefulWidget {
  final String prompt;
  final TextEditingController? controller;
  final double? width;
  final double? height;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String dateFormat; // "dd/MM/yyyy", "MM/dd/yyyy", "yyyy-MM-dd"
  final void Function(DateTime)? onDateSelected;

  const AnimatedDatePicker({
    super.key,
    required this.prompt,
    this.controller,
    this.width,
    this.height,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.dateFormat = "dd/MM/yyyy",
    this.onDateSelected,
  });

  @override
  _AnimatedDatePickerState createState() => _AnimatedDatePickerState();
}

class _AnimatedDatePickerState extends State<AnimatedDatePicker>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  late final TextEditingController _controller;
  bool _isControllerInternal = false;
  DateTime? _selectedDate;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Focus listener
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
      if (_isFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });

    // Controller setup
    if (widget.controller == null) {
      _controller = TextEditingController();
      _isControllerInternal = true;
    } else {
      _controller = widget.controller!;
    }

    // Set initial date if provided
    if (widget.initialDate != null) {
      _selectedDate = widget.initialDate;
      _controller.text = _formatDate(_selectedDate!);
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

  String _formatDate(DateTime date) {
    switch (widget.dateFormat) {
      case "MM/dd/yyyy":
        return "${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}";
      case "yyyy-MM-dd":
        return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      case "dd/MM/yyyy":
      default:
        return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.redAccent,
              onPrimary: Colors.white,
              surface: Color(0xFF2A2A2A),
              onSurface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: const Color(0xFF2A2A2A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _controller.text = _formatDate(picked);
      });
      widget.onDateSelected?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = widget.width ?? 300;
    double baseHeight = widget.height ?? 60;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GestureDetector(
          onTap: _selectDate,
          child: Container(
            width: baseWidth,
            height: baseHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isFocused
                      ? [const Color(0xFF404040), const Color(0xFF2A2A2A)]
                      : [const Color(0xFF363636), const Color(0xFF1F1F1F)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isFocused
                      ? Colors.redAccent.withOpacity(0.6)
                      : Colors.grey.withOpacity(0.2),
                  width: _isFocused ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Label
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            color: _selectedDate != null || _isFocused
                                ? Colors.redAccent.withOpacity(0.9)
                                : Colors.grey[400],
                            fontSize: _selectedDate != null || _isFocused
                                ? 12
                                : 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                          child: Text(widget.prompt),
                        ),

                        // Selected date or placeholder
                        if (_selectedDate != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            _controller.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Calendar icon with animation
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: AnimatedRotation(
                      turns: _isFocused ? 0.1 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.calendar_today_rounded,
                        color: _isFocused
                            ? Colors.redAccent.withOpacity(0.8)
                            : Colors.grey[400],
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
