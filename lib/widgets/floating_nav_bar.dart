import 'package:flutter/material.dart';

class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.notifCount,
  });

  final int currentIndex;
  final Function(int) onTap;
  final int notifCount;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      {'icon': Icons.luggage, 'label': 'Trips', 'index': 0},
      {'icon': Icons.map, 'label': 'Map', 'index': 1},
      {'icon': Icons.person, 'label': 'Profile', 'index': 2},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Color(0xE6140F0A),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.30),
            blurRadius: 32,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: tabs.map((tab) {
          final index = tab['index'] as int;
          final isActive = currentIndex == index;
          return GestureDetector(
            onTap: () => onTap(index),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 7),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white.withOpacity(0.11)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        tab['icon'] as IconData,
                        size: 22,
                        color: isActive
                            ? Colors.white
                            : Colors.white.withOpacity(0.42),
                      ),
                      if (index == 2 && notifCount > 0)
                        Positioned(
                          top: -2,
                          right: -4,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Color(0xFFFF453A),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Color(0xE6140F0A),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 3),
                  Text(
                    tab['label'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive
                          ? Colors.white
                          : Colors.white.withOpacity(0.42),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
