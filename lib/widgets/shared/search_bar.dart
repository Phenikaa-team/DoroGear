import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class FakeSearchBar extends StatelessWidget {
  final String? hintText;
  final VoidCallback onTap;

  const FakeSearchBar({super.key, this.hintText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.white, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hintText ?? 'Search...',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
            const CameraSearchButton(),
          ],
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
      onPressed: () { /* TODO: Implement camera search */ },
    );
  }
}