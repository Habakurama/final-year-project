import 'package:flutter/material.dart';
import 'package:untitled/common/color_extension.dart';
import 'package:untitled/view/add_subscription/components/spending_carousel.dart';

class SpendingHeader extends StatelessWidget {
  final List<Map<String, String>> carouselItems;
  final double screenWidth;

  const SpendingHeader({
    super.key,
    required this.carouselItems,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Image.asset(
                      "assets/img/back.png",
                      width: 25,
                      height: 25,
                      color: theme.disabledColor,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    "Add new spending",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: TColor.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            SpendingCarousel(
              items: carouselItems,
              width: screenWidth,
            ),
          ],
        ),
      ),
    );
  }
}