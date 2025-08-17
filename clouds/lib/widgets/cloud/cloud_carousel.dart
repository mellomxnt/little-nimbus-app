import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:clouds/theme/app_colors.dart';

class CloudCarousel extends StatefulWidget {
  @override
  _CloudCarouselState createState() => _CloudCarouselState();
}

class _CloudCarouselState extends State<CloudCarousel> {
  int _current = 0;

  final List<Map<String, String>> cloudData = [
    {'image': 'assets/stratus.jpg', 'name': 'Stratus'},
    {'image': 'assets/stratocumulus.jpg', 'name': 'Stratocumulus'},
    {'image': 'assets/nimbostratus.jpg', 'name': 'Nimbostratus'},
    {'image': 'assets/cumulus.jpg', 'name': 'Cumulus'},
    {'image': 'assets/cumulonimbus.jpg', 'name': 'Cumulonimbus'},
    {'image': 'assets/cirrus.jpg', 'name': 'Cirrus'},
    {'image': 'assets/cirrostratus.jpg', 'name': 'Cirrostratus'},
    {'image': 'assets/cirrocumulus.jpg', 'name': 'Cirrocumulus'},
    {'image': 'assets/altostratus.jpg', 'name': 'Altostratus'},
    {'image': 'assets/altocumulus.jpg', 'name': 'Altocumulus'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // ป้องกันล้นพื้นที่
      children: [
        CarouselSlider.builder(
          itemCount: cloudData.length,
          itemBuilder: (context, index, realIndex) {
            final cloud = cloudData[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    cloud['image']!,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Text(
                      cloud['name']!,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            offset: Offset(1, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          options: CarouselOptions(
            height: 220,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.8,
            aspectRatio: 16 / 9,
            autoPlayInterval: Duration(seconds: 4),
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: cloudData.asMap().entries.map((entry) {
            bool isActive = _current == entry.key;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              height: 10.0,
              width: isActive ? 20.0 : 10.0,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.lavender
                    : AppColors.lavender.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
