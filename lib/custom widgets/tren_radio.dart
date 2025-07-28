import 'package:flutter/material.dart';

class EzRadioController extends ChangeNotifier {
  String? _selectedValue;

  String? get selectedValue => _selectedValue;

  void selectValue(String value) {
    if (_selectedValue != value) {
      _selectedValue = value;
      notifyListeners();
    }
  }

  void clear() {
    _selectedValue = null;
    notifyListeners();
  }
}

class EzRadio extends StatefulWidget {
  final String label;
  final String group;
  final EzRadioController controller;
  final double? width;
  final double? height;

  const EzRadio({
    super.key,
    required this.label,
    required this.group,
    required this.controller,
    this.width,
    this.height,
  });

  @override
  State<EzRadio> createState() => _EzRadioState();
}

class _EzRadioState extends State<EzRadio> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _pressed = false;

  bool get isSelected => widget.controller.selectedValue == widget.label;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    widget.controller.addListener(_onControllerChanged);

    if (isSelected) {
      _animationController.forward();
    }
  }

  void _onControllerChanged() {
    if (mounted) {
      if (isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.controller.selectValue(widget.label);
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    double width = widget.width ?? MediaQuery.of(context).size.width * 0.85;
    double height = widget.height ?? 55.0;

    return GestureDetector(
      onTap: _handleTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [const Color(0xFF404040), const Color(0xFF2A2A2A)]
                : [const Color(0xFF363636), const Color(0xFF1F1F1F)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.redAccent : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.redAccent.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 0),
              ),
            BoxShadow(
              color: Colors.black.withOpacity(_pressed ? 0.5 : 0.3),
              blurRadius: _pressed ? 4 : 8,
              offset: Offset(0, _pressed ? 2 : 4),
            ),
          ],
        ),
        transform: Matrix4.identity()..scale(_pressed ? 0.98 : 1.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Radio circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.redAccent : Colors.grey,
                    width: 2,
                  ),
                  color: isSelected ? Colors.redAccent : Colors.transparent,
                ),
                child: AnimatedScale(
                  scale: isSelected ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: const Center(
                    child: Icon(Icons.circle, size: 8, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Label
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[300],
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  child: Text(widget.label),
                ),
              ),
              // Check icon when selected
              AnimatedScale(
                scale: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.redAccent,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
