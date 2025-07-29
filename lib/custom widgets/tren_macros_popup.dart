import 'package:flutter/material.dart';

class MacrosPopup extends StatefulWidget {
  final int initialProtein;
  final int initialCarbs;
  final int initialFats;
  final void Function(int protein, int carbs, int fats) onUpdate;

  const MacrosPopup({
    super.key,
    this.initialProtein = 0,
    this.initialCarbs = 0,
    this.initialFats = 0,
    required this.onUpdate,
  });

  @override
  State<MacrosPopup> createState() => _MacrosPopupState();
}

class _MacrosPopupState extends State<MacrosPopup> {
  late TextEditingController _proteinCtrl;
  late TextEditingController _carbsCtrl;
  late TextEditingController _fatsCtrl;

  final int maxProtein = 1000;
  final int maxCarbs = 1000;
  final int maxFats = 1000;

  @override
  void initState() {
    super.initState();
    _proteinCtrl = TextEditingController(
      text: widget.initialProtein.toString(),
    );
    _carbsCtrl = TextEditingController(text: widget.initialCarbs.toString());
    _fatsCtrl = TextEditingController(text: widget.initialFats.toString());
  }

  @override
  void dispose() {
    _proteinCtrl.dispose();
    _carbsCtrl.dispose();
    _fatsCtrl.dispose();
    super.dispose();
  }

  int _parseValue(TextEditingController ctrl, int max) {
    int? val = int.tryParse(ctrl.text);
    if (val == null) return 0;
    if (val < 0) return 0;
    if (val > max) return max;
    return val;
  }

  Widget _buildNeonInput({
    required String label,
    required int max,
    required TextEditingController controller,
    required Color neonColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ${_parseValue(controller, max)} / $max g',
            style: TextStyle(
              color: neonColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              shadows: [
                Shadow(
                  color: neonColor.withOpacity(0.7),
                  blurRadius: 12,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            maxLength: 3,
            style: TextStyle(
              color: neonColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              shadows: [
                Shadow(
                  color: neonColor.withOpacity(0.8),
                  blurRadius: 10,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            cursorColor: neonColor,
            decoration: InputDecoration(
              counterText: '',
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: neonColor.withOpacity(0.7),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: neonColor, width: 3),
                borderRadius: BorderRadius.circular(10),
              ),
              fillColor: Colors.black87,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (text) {
              // Clamp values
              int? val = int.tryParse(text);
              if (val == null) return;
              if (val > max) {
                controller.text = max.toString();
                controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.text.length),
                );
              } else if (val < 0) {
                controller.text = '0';
                controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.text.length),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _onUpdatePressed() {
    final protein = _parseValue(_proteinCtrl, maxProtein);
    final carbs = _parseValue(_carbsCtrl, maxCarbs);
    final fats = _parseValue(_fatsCtrl, maxFats);

    widget.onUpdate(protein, carbs, fats);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1B0000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.redAccent.withOpacity(0.8), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'MACROS TRACKER',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              _buildNeonInput(
                label: 'Carbs',
                max: maxCarbs,
                controller: _carbsCtrl,
                neonColor: Colors.cyanAccent.shade400,
              ),
              _buildNeonInput(
                label: 'Protein',
                max: maxProtein,
                controller: _proteinCtrl,
                neonColor: Colors.greenAccent.shade400,
              ),
              _buildNeonInput(
                label: 'Fats',
                max: maxFats,
                controller: _fatsCtrl,
                neonColor: Colors.pinkAccent.shade400,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _onUpdatePressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.shade700,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  shadowColor: Colors.redAccent.shade400,
                  elevation: 10,
                ),
                child: const Text(
                  'UPDATE',
                  style: TextStyle(
                    fontSize: 18,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
