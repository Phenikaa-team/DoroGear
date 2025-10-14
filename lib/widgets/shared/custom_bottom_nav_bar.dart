import 'package:doro_gear/localization/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        _buildBottomNavBar(context),
        _buildFloatingButton(context)
      ],
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey[600],
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 0,
        items: [
          _buildButton(Icons.home_outlined, Icons.home, t.translate('home')),
          _buildButton(Icons.shopping_bag_outlined, Icons.shopping_bag, t.translate('mall')),
          const BottomNavigationBarItem(icon: SizedBox.shrink(), label: ''),
          _buildButton(Icons.chat_bubble_outline, Icons.chat_bubble, t.translate('messages')),
          _buildButton(Icons.person_outline, Icons.person, t.translate('account')),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildButton(IconData icon, IconData activeIcon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon, size: 28),
      activeIcon: Icon(activeIcon, size: 28),
      label: label,
    );
  }

  Widget _buildFloatingButton(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Positioned(
      top: -25,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: FittedBox(
              child: FloatingActionButton(
                onPressed: () => onTap(2),
                backgroundColor: AppColors.primaryColor,
                elevation: 4.0,
                shape: const CircleBorder(),
                child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 32),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            t.translate('qrCode'),
            style: TextStyle(
              fontSize: 12,
              color: selectedIndex == 2 ? AppColors.primaryColor : Colors.grey[600],
              fontWeight: selectedIndex == 2 ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}