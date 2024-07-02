import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Using Get for navigation
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:weather_app/weather_screen.dart'; // Import path for weather screen

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();

    // Function to validate city name
    Future<bool> validateCityName(String cityName) async {
      try {
        final response = await http.get(
          Uri.parse(
              'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=0034f5b9e81ea4e5489d9a12c1483bca'),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['cod'] == 200;
        } else {
          return false;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error validating city name: $e');
        }
        return false;
      }
    }

    // Function to handle search and navigate to weather screen
    void searchWeather() async {
      final searchText = searchController.text.trim();
      if (kDebugMode) {
        print('Search text: $searchText');
      } // Debug log for search text

      if (searchText.isEmpty) {
        // Show custom snackbar if search text is empty
        CustomSnackbar.show(
          context,
          'Empty Search',
          'Please enter a city or state to search',
        );
        return; // Stop execution if search text is empty
      }

      // Check if the search text is an integer
      if (int.tryParse(searchText) != null) {
        // Show custom snackbar if search text is an integer
        CustomSnackbar.show(
          context,
          'Invalid Input',
          'Please enter a valid city name, not an integer.',
        );
        return; // Stop execution if search text is an integer
      }

      // Validate city name
      bool isValid = await validateCityName(searchText);
      if (!isValid) {
        // Show custom snackbar if city name is invalid
        CustomSnackbar.show(
          // ignore: use_build_context_synchronously
          context,
          'Invalid City',
          'The entered city name is invalid. Please try again.',
        );
        return; // Stop execution if city name is invalid
      }

      if (searchText.isNotEmpty) {
        Get.to(() => WeatherScreen(cityName: searchText)); // Navigate to weather screen with city name
        searchController.clear();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'), // Title of the app bar
        centerTitle: true, // Center align the title
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 600;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding for the main column
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0), // Padding for the search TextField
                  child: TextField(
                    controller: searchController, // Controller for the search input
                    decoration: InputDecoration(
                      labelText: 'Search by city or state', // Label for the search input
                      border: OutlineInputBorder( // Border decoration for the input
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: const Icon(Icons.search_rounded), // Icon before the input field
                      suffixIcon: GestureDetector(
                        onTap: searchWeather, // Trigger search function on tap
                        child: const Icon(Icons.arrow_right), // Icon for search action
                      ),
                    ),
                    onSubmitted: (_) => searchWeather(), // Trigger search function on submit
                  ),
                ),
                const SizedBox(height: 60), // Spacer between search and image

                // Placeholder image container
                SizedBox(
                  height: isSmallScreen ?500 : 400,
                  width: isSmallScreen ? 500 : 900,
                  child: CachedNetworkImage(
                    imageUrl: 'https://i.postimg.cc/1RDkzyYQ/urban-line-moving-coordinate-grid-1.gif', // Image URL
                    placeholder: (context, url) => const TShimmerEffect(height: 400, width: 400,), // Placeholder while loading
                    errorWidget: (context, url, error) => const Icon(Icons.error), // Error widget if image fails to load
                    fit: BoxFit.cover, // Image fit within container
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


// Shimmer effect class for loading placeholder
class TShimmerEffect extends StatelessWidget {
  const TShimmerEffect({
    super.key,
    required this.width,
    required this.height,
    this.radius = 15,
    this.color,
  });

  final double width, height, radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[850]!,
      highlightColor: Colors.grey[700]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

// Custom snackbar class for displaying messages
class CustomSnackbar {
  static void show(BuildContext context, String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        action: SnackBarAction(
          label: '',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
