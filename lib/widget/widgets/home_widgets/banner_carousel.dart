import 'dart:async';

import 'package:flutter/material.dart';

import '../../constants/Constants.dart';
import '../../constants/app_colors.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int _currentBanner = 0;
  final PageController _controller = PageController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(Constants.bannerAutoScrollDuration, (timer) {
      if (!mounted || !_controller.hasClients) return;

      int currentPage = _controller.page!.round();
      int nextPage = (currentPage + 1) % Constants.bannerCount;

      _controller.animateToPage(
        nextPage,
        duration: Constants.bannerAnimationDuration,
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
    GestureDetector(
      onPanDown: (_) => _timer?.cancel(),
      onPanEnd: (_) => _startAutoScroll(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            _buildPageView(),
            _buildIndicators()
          ],
        ),
      ),
    );


  Widget _buildPageView() =>
    SizedBox(
      height: Constants.bannerHeight,
      child: PageView.builder(
        controller: _controller,
        onPageChanged: (index) {
          setState(() {
            _currentBanner = index;
          });
        },
        itemCount: Constants.bannerCount,
        itemBuilder: (context, index) => BannerItem(index: index),
      ),
    );


  Widget _buildIndicators() =>
    Positioned(
      bottom: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          Constants.bannerCount,
              (index) => BannerIndicator(isActive: _currentBanner == index),
        ),
      ),
    );
}

class BannerItem extends StatelessWidget {
  final int index;

  const BannerItem({super.key, required this.index});

  @override
  Widget build(BuildContext context) =>
    Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.secondaryColor
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'Banner ${index + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
}

class BannerIndicator extends StatelessWidget {
  final bool isActive;

  const BannerIndicator({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) =>
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: isActive ? 24 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(4),
        ),
      );
}