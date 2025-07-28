import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'combo_box.dart';
import 'tren_button.dart';

class TrenPalPopup extends StatefulWidget {
  final String title;
  final String buttonText;
  final Function(int) onSubmit;
  final List<String>? comboBoxItems;
  final String? comboBoxHint;
  final int initialValue;
  final int minValue;
  final int maxValue;
  final int step;

  const TrenPalPopup({
    super.key,
    required this.title,
    required this.buttonText,
    required this.onSubmit,
    this.comboBoxItems,
    this.comboBoxHint,
    this.initialValue = 0,
    this.minValue = 0,
    this.maxValue = 1000,
    this.step = 1,
  });

  @override
  State<TrenPalPopup> createState() => _TrenPalPopupState();
}

class _TrenPalPopupState extends State<TrenPalPopup> {
  late int _currentValue;
  late TextEditingController _textController;
  String? _selectedComboValue;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    _textController = TextEditingController(text: _currentValue.toString());

    // Listen to text changes and update value
    _textController.addListener(() {
      final text = _textController.text;
      if (text.isNotEmpty) {
        final parsed = int.tryParse(text);
        if (parsed != null && parsed != _currentValue) {
          setState(() {
            _currentValue = parsed.clamp(widget.minValue, widget.maxValue);
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _increment() {
    if (_currentValue < widget.maxValue) {
      setState(() {
        _currentValue = (_currentValue + widget.step).clamp(
          widget.minValue,
          widget.maxValue,
        );
        _textController.text = _currentValue.toString();
      });
    }
  }

  void _decrement() {
    if (_currentValue > widget.minValue) {
      setState(() {
        _currentValue = (_currentValue - widget.step).clamp(
          widget.minValue,
          widget.maxValue,
        );
        _textController.text = _currentValue.toString();
      });
    }
  }

  void _validateAndUpdateValue() {
    final text = _textController.text;
    if (text.isEmpty) {
      setState(() {
        _currentValue = widget.minValue;
        _textController.text = _currentValue.toString();
      });
      return;
    }

    final parsed = int.tryParse(text);
    if (parsed != null) {
      final clampedValue = parsed.clamp(widget.minValue, widget.maxValue);
      if (clampedValue != _currentValue) {
        setState(() {
          _currentValue = clampedValue;
          _textController.text = _currentValue.toString();
        });
      }
    } else {
      // Invalid input, revert to current value
      _textController.text = _currentValue.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1F1F1F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.redAccent.withOpacity(0.6), width: 1.5),
      ),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              widget.title,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Combo Box (if items provided)
            if (widget.comboBoxItems != null) ...[
              AnimatedComboBox(
                prompt: widget.comboBoxHint ?? 'Select an option',
                options: widget.comboBoxItems!,
                selectedValue: _selectedComboValue,
                onChanged: (value) {
                  setState(() {
                    _selectedComboValue = value;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],

            // Number Spinner
            Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF363636), Color(0xFF1F1F1F)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.redAccent.withOpacity(0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Decrement Button
                  _NumberSpinnerButton(
                    icon: Icons.remove,
                    onPressed: _currentValue > widget.minValue
                        ? _decrement
                        : null,
                    isDisabled: _currentValue <= widget.minValue,
                  ),

                  // Value Display/Input
                  Expanded(
                    child: Center(
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onSubmitted: (value) {
                          _validateAndUpdateValue();
                          _focusNode.unfocus();
                        },
                        onTapOutside: (event) {
                          _validateAndUpdateValue();
                          _focusNode.unfocus();
                        },
                        onEditingComplete: () {
                          _validateAndUpdateValue();
                        },
                      ),
                    ),
                  ),

                  // Increment Button
                  _NumberSpinnerButton(
                    icon: Icons.add,
                    onPressed: _currentValue < widget.maxValue
                        ? _increment
                        : null,
                    isDisabled: _currentValue >= widget.maxValue,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            TrenPalButton(
              text: widget.buttonText,
              onPressed: () async {
                // Ensure the current text value is validated before submitting
                _validateAndUpdateValue();
                widget.onSubmit(_currentValue);
                Navigator.of(context).pop();
              },
              showLoading: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberSpinnerButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isDisabled;

  const _NumberSpinnerButton({
    required this.icon,
    required this.onPressed,
    required this.isDisabled,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.horizontal(
          left: icon == Icons.remove ? const Radius.circular(12) : Radius.zero,
          right: icon == Icons.add ? const Radius.circular(12) : Radius.zero,
        ),
        splashColor: Colors.redAccent.withOpacity(0.1),
        highlightColor: Colors.redAccent.withOpacity(0.05),
        child: Container(
          width: 50,
          height: 60,
          decoration: BoxDecoration(
            color: isDisabled
                ? Colors.grey.withOpacity(0.1)
                : Colors.redAccent.withOpacity(0.1),
            borderRadius: BorderRadius.horizontal(
              left: icon == Icons.remove
                  ? const Radius.circular(12)
                  : Radius.zero,
              right: icon == Icons.add
                  ? const Radius.circular(12)
                  : Radius.zero,
            ),
            border: Border(
              right: icon == Icons.remove
                  ? BorderSide(color: Colors.grey.withOpacity(0.3), width: 1)
                  : BorderSide.none,
              left: icon == Icons.add
                  ? BorderSide(color: Colors.grey.withOpacity(0.3), width: 1)
                  : BorderSide.none,
            ),
          ),
          child: Icon(
            icon,
            color: isDisabled ? Colors.grey[600] : Colors.redAccent,
            size: 24,
          ),
        ),
      ),
    );
  }
}
