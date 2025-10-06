import 'package:flutter/material.dart';

class ShopFunction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const ShopFunction({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });
}
