import 'package:doro_gear/screens/account/signin_page.dart';
import 'package:flutter/material.dart';

import 'constants/app_colors.dart';

void main() {
  runApp(const DoroGear());
}

class DoroGear extends StatelessWidget {
  const DoroGear({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DoroGear',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
        useMaterial3: true,
      ),
      home: const SignInPage(),
    );
  }
}