import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import Get package for navigation
import 'package:weather_app/home_screen.dart'; // Import HomeScreen class

void main() {
  runApp(const WeatherApp()); // Entry point of the application
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false, // Disable debug banner
      theme: ThemeData.dark(
        useMaterial3: true, // Use Material 3 theme
      ),
      home: const HomeScreen(), // Set HomeScreen as the initial route
    );
  }
}
