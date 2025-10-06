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
  Widget build(BuildContext context) =>
      Stack(
        clipBehavior: Clip.none,
        children: [
          _buildBottomNavBar(),
          _buildFloatingButton(context)
        ],
      );

  Widget _buildBottomNavBar() =>
      Container(
        decoration: const BoxDecoration(color: Colors.white),
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
            _buildButton(
              Icons.home_outlined,
              Icons.home,
              28,
              'Home',
            ),
            _buildButton(
              Icons.shopping_bag_outlined,
              Icons.shopping_bag,
              28,
              'Mall',
            ),
            BottomNavigationBarItem(icon: SizedBox(height: 28), label: ''),
            _buildButton(
              Icons.chat_bubble_outline,
              Icons.chat_bubble,
              28,
              'Tin Nhắn',
            ),
            _buildButton(
                Icons.person_outline,
                Icons.person,
                28,
                'Tài Khoản'
            )
          ],
        ),
      );

  BottomNavigationBarItem _buildButton(IconData icon, IconData activeIcon,
      double size, String label) =>
      BottomNavigationBarItem(
        icon: Icon(icon, size: size),
        activeIcon: Icon(activeIcon, size: size),
        label: label,
      );

  Widget _buildFloatingButton(BuildContext context) =>
      Positioned(
        top: -30,
        left: MediaQuery.of(context).size.width / 2 - 35,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onTap(2),
                  borderRadius: BorderRadius.circular(35),
                  child: const Center(
                    child: Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),
            Text(
              'QR Code',
              style: TextStyle(
                fontSize: 12,
                color: selectedIndex == 2
                    ? AppColors.primaryColor
                    : Colors.grey[600],
                fontWeight: selectedIndex == 2
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      );
}

