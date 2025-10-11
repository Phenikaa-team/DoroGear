import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Tìm kiếm sản phẩm...',
          hintStyle: TextStyle(color: Colors.white, fontSize: 16),
          prefixIcon: Icon(Icons.search, color: Colors.white, size: 32),
          suffixIcon: CameraSearchButton(),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}

class CameraSearchButton extends StatelessWidget {
  const CameraSearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.photo_camera, color: Colors.white),
      onPressed: () {},
    );
  }
}
