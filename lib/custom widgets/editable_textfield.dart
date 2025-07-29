import 'package:flutter/material.dart';
import 'dart:math';

class EditableGrayTextField extends StatefulWidget {
  final String prompt;
  final double? width;
  final double? height;
  final TextEditingController? controller;
  final bool initiallyEditable;
  final String? initialText;

  const EditableGrayTextField({
    super.key,
    required this.prompt,
    this.width,
    this.height,
    this.controller,
    this.initiallyEditable = false,
    this.initialText,
  });

  @override
  State<EditableGrayTextField> createState() => _EditableGrayTextFieldState();
}

class _EditableGrayTextFieldState extends State<EditableGrayTextField>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  late AnimationController _animationController;

  bool _isEditable = false;
  bool _isFocused = false;
  bool _isControllerInternal = false;

  bool get _hasText => _controller.text.trim().isNotEmpty;
  bool get _showLabel => _hasText || _isFocused;

  @override
  void initState() {
    super.initState();

    _isEditable = widget.initiallyEditable;

    _controller =
        widget.controller ??
        TextEditingController(text: widget.initialText ?? "");
    _isControllerInternal = widget.controller == null;

    if (_controller.text.isEmpty && widget.initialText != null) {
      _controller.text = widget.initialText!;
    }

    _controller.addListener(() => setState(() {}));
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
      _isFocused
          ? _animationController.forward()
          : _animationController.reverse();
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _animationController.dispose();
    if (_isControllerInternal) _controller.dispose();
    super.dispose();
  }

  void _toggleEditable() {
    setState(() {
      _isEditable = !_isEditable;
    });

    Future.delayed(Duration.zero, () {
      _isEditable ? _focusNode.requestFocus() : _focusNode.unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.width ?? MediaQuery.of(context).size.width * 0.85;
    final height = widget.height ?? 60.0;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 14),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: height,
              width: width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isFocused
                      ? [Color(0xFF444444), Color(0xFF222222)]
                      : [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isFocused
                      ? Colors.redAccent.withOpacity(0.7)
                      : Colors.grey.shade800,
                  width: _isFocused ? 2 : 1,
                ),
                boxShadow: [
                  if (_isFocused)
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      enabled: _isEditable,
                      cursorColor: Colors.redAccent,
                      style: TextStyle(
                        color: _isEditable ? Colors.white : Colors.grey[500],
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: !_showLabel ? widget.prompt : null,
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 18,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Icon(
                        _isEditable ? Icons.lock_open : Icons.edit,
                        key: ValueKey(_isEditable),
                        color: _isFocused ? Colors.redAccent : Colors.grey[400],
                      ),
                    ),
                    onPressed: _toggleEditable,
                    splashRadius: 24,
                  ),
                ],
              ),
            ),

            if (_showLabel)
              Positioned(
                left: 20,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.prompt,
                    style: TextStyle(
                      fontSize: 12,
                      color: _isFocused ? Colors.redAccent : Colors.grey[300],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
