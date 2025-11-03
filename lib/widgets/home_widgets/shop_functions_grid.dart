import 'package:flutter/material.dart';

import '../../constants/Constants.dart';
import '../../models/shop_function.dart';

class ShopFunctionsGrid extends StatelessWidget {
  final List<ShopFunction> functions;

  const ShopFunctionsGrid({super.key, required this.functions});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _buildRow(functions.sublist(0, 4)),
        // child: Column(
        //   children: [
        //     _buildRow(functions.sublist(0, 4)),
        //     SizedBox(height: 16),
        //     _buildRow(functions.sublist(4, 8)),
        //   ],
        // ),
      ),
    );
  }

  Widget _buildRow(List<ShopFunction> items) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: items
          .map((func) =>
          Expanded(
            child: ShopIconButton(function: func),
          ))
          .toList(),
    );
  }
}

class ShopIconButton extends StatelessWidget {
  final ShopFunction function;

  const ShopIconButton({super.key, required this.function});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: function.onTap ?? () {},
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: Constants.iconButtonSize,
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: function.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(function.icon, color: function.color, size: 28),
            ),
            const SizedBox(height: 6),
            Text(
              function.label,
              style: TextStyle(fontSize: 11, color: Colors.grey[800]),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}