import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class Turf extends StatelessWidget {
  const Turf({super.key});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
        options: CarouselOptions(
          height: 400.0,
          viewportFraction: 1.0,
          enlargeCenterPage: false,
          enableInfiniteScroll: true,
          autoPlay: true,
        ),
        items: ['turf2.jpg', 'turf3.jpg', 'turf4.jpg'].map((imageName) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  // Add decoration properties if needed
                ),
                child: Image.asset(
                  'assets/$imageName', // Assuming the images are in the assets folder
                  fit: BoxFit.cover, // Adjust the fit as per your requirement
                ),
              );
            },
          );
        }).toList(),
      );
  }
}