import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class SpendingCarousel extends StatelessWidget {
  final List<Map<String, String>> items;
  final double width;

  const SpendingCarousel({
    super.key,
    required this.items,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: width,
      height: width * 0.5,
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
        itemCount: items.length,
        itemBuilder: (context, index, _) {
          var item = items[index];
          return Container(
            margin: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    item["icon"]!,
                    width: width * 0.4,
                    height: width * 0.4,
                    fit: BoxFit.cover,
                  ),
                ),
                const Spacer(),
                Text(
                  item["name"]!,
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
    );
  }
}
