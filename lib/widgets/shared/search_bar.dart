import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class CustomSearchBar extends StatelessWidget {
  final String? hintText;

  const CustomSearchBar({super.key, this.hintText});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText ?? 'Search...',
          hintStyle: const TextStyle(color: Colors.white70, fontSize: 16),
          prefixIcon: const Icon(Icons.search, color: Colors.white, size: 28),
          suffixIcon: const CameraSearchButton(),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
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
      icon: const Icon(Icons.photo_camera_outlined, color: Colors.white),
      onPressed: () {
        // TODO: Implement camera search functionality
      },
    );
  }
}