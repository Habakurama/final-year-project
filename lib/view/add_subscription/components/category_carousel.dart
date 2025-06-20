// lib/view/add_subscription/components/category_carousel.dart
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:untitled/common/color_extension.dart';

class CategoryCarousel extends StatelessWidget {
  final List<Map<String, String>> categories;

  const CategoryCarousel({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
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
            SizedBox(
              width: media.width,
              height: media.width * 0.5,
              child: CarouselSlider.builder(
                options: CarouselOptions(
                  autoPlay: false,
                  aspectRatio: 1,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: true,
                  viewportFraction: 0.65,
                  enlargeFactor: 0.4,
                  enlargeStrategy: CenterPageEnlargeStrategy.zoom,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index, _) {
                  var sObj = categories[index];
                  return Container(
                    margin: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            sObj["icon"]!,
                            width: media.width * 0.4,
                            height: media.width * 0.4,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          sObj["name"]!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.disabledColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}