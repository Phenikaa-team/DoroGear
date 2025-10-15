import 'package:doro_gear/localization/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../services/user_service.dart';
import '../account/signin_page.dart';

class BaseDashboardPage extends StatelessWidget {
  final String title;
  final Color appBarColor;
  final List<Widget> featureCards;

  const BaseDashboardPage({
    super.key,
    required this.title,
    required this.appBarColor,
    required this.featureCards,
  });

  void _signOut(BuildContext context) {
    UserService.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: appBarColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: t.translate('logoutTooltip'),
            onPressed: () => _signOut(context),
          )
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: featureCards,
      ),
    );
  }
}