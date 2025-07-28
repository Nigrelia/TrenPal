import 'package:flutter/material.dart';

class BottomNavItem {
  final String label;
  final IconData icon;
  final int badgeCount;

  const BottomNavItem({
    required this.label,
    required this.icon,
    this.badgeCount = 0,
  });
}

class TrenPalBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItem> items;
  final Color activeColor;
  final Color inactiveColor;
  final double height;

  const TrenPalBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.activeColor = Colors.redAccent,
    this.inactiveColor = Colors.grey,
    this.height = 70.0,
  }) : assert(
         items.length >= 2 && items.length <= 5,
         'BottomNav requires 2-5 items',
       );

  @override
  State<TrenPalBottomNav> createState() => _TrenPalBottomNavState();
}

class _TrenPalBottomNavState extends State<TrenPalBottomNav> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(covariant TrenPalBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      setState(() {
        _selectedIndex = widget.currentIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: widget.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return _NavItem(
            item: item,
            isSelected: _selectedIndex == index,
            activeColor: widget.activeColor,
            inactiveColor: widget.inactiveColor,
            onTap: () {
              setState(() => _selectedIndex = index);
              widget.onTap(index);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final BottomNavItem item;
  final bool isSelected;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 80.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  item.icon,
                  size: 24.0,
                  color: isSelected
                      ? activeColor
                      : inactiveColor.withOpacity(0.7),
                ),
                if (item.badgeCount > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3.0),
                      decoration: BoxDecoration(
                        color: activeColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF121212),
                          width: 2.0,
                        ),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Center(
                        child: Text(
                          item.badgeCount > 9
                              ? '9+'
                              : item.badgeCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9.0,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4.0),
            Text(
              item.label,
              style: TextStyle(
                color: isSelected
                    ? activeColor
                    : inactiveColor.withOpacity(0.7),
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
