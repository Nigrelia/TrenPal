import 'package:flutter/material.dart';

class TrenAlerts {
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 60,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder(
            duration: Duration(milliseconds: 400),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, double value, child) {
              return Transform.translate(
                offset: Offset(0, -50 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isError
                            ? [Color(0xFFE53E3E), Color(0xFFD53F8C)]
                            : [Color(0xFF38A169), Color(0xFF319795)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (isError ? Colors.red : Colors.green)
                              .withOpacity(0.4),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isError
                                ? Icons.warning_rounded
                                : Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            message,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  static void error(BuildContext context, String message) {
    show(context, message, isError: true);
  }

  static void success(BuildContext context, String message) {
    show(context, message, isError: false);
  }
}
