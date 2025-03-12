import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';

class BottomNavigationItem extends StatelessWidget {
  final int index;
  final String label;
  final bool isSelected;
  final bool isMiddle;
  final PageController pageController;
  final Function(int) onTap;

  const BottomNavigationItem({
    super.key,
    required this.index,
    required this.label,
    required this.isSelected,
    required this.pageController,
    required this.onTap,
    this.isMiddle = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap(index);
        pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        width: isMiddle ? MediaQuery.of(context).size.width * 0.4 : MediaQuery.of(context).size.width * 0.25,
        decoration: BoxDecoration(
          color: isSelected ? HomeCareTheme.primaryColor : HomeCareTheme.secondaryColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 500),
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14.0),
          ),
        ),
      ),
    );
  }
}
