import 'package:doro_gear/localization/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../product/product_manager_page.dart';
import 'customer/customer_management_page.dart';
import 'widgets/dashboard_base.dart';
import 'employee/employee_management_page.dart';
import 'widgets/feature_card.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return BaseDashboardPage(
      title: t.translate('adminDashboard'),
      appBarColor: AppColors.primaryColor,
      featureCards: [
        FeatureCard(
          icon: Icons.inventory_2,
          title: t.translate('productManagement'),
          description: t.translate('productManagementDesc'),
          color: Colors.blueAccent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProductManagementPage()),
            );
          },
        ),
        FeatureCard(
          icon: Icons.store,
          title: t.translate('inventoryManagement'),
          description: t.translate('inventoryManagementDesc'),
          color: Colors.teal,
          onTap: () { /* TODO: Navigate to Inventory Management Page */ },
        ),
        FeatureCard(
          icon: Icons.people,
          title: t.translate('customerManagement'),
          description: t.translate('customerManagementDesc'),
          color: Colors.green,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CustomerManagementPage()),
            );
          },
        ),
        FeatureCard(
          icon: Icons.receipt_long,
          title: t.translate('orderManagement'),
          description: t.translate('orderManagementDesc'),
          color: Colors.amber.shade700,
          onTap: () { /* TODO: Navigate to Order Management Page */ },
        ),
        FeatureCard(
          icon: Icons.badge,
          title: t.translate('staffManagement'),
          description: t.translate('staffManagementDesc'),
          color: Colors.deepOrange,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StaffManagementPage()),
            );
          },
        ),
        FeatureCard(
          icon: Icons.insights,
          title: t.translate('analyticsReports'),
          description: t.translate('analyticsReportsDesc'),
          color: Colors.purple,
          onTap: () { /* TODO: Navigate to Analytics Page */ },
        ),
      ],
    );
  }
}