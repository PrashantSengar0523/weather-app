import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:weather_app/additional_info.dart'; // Import AdditionalInfo widget
import 'package:weather_app/home_screen.dart'; // Import HomeScreen widget
import 'package:weather_app/hourly_forecast.dart'; // Import HourlyForecast widget

class WeatherController extends GetxController {
  final String cityName;
  var weatherData = {}.obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  WeatherController(this.cityName);

  @override
  void onInit() {
    super.onInit();
    getCurrentWeather();
  }

  Future<void> getCurrentWeather() async {
    try {
      isLoading(true);
      final res = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=0034f5b9e81ea4e5489d9a12c1483bca'),
      );

      if (res.statusCode != 200) {
        final data = jsonDecode(res.body);
        if (data['message'] != null) {
          throw data['message']; // API returned an error message
        } else {
          throw 'An unexpected error occurred'; // Handle unexpected error
        }
      }

      final data = jsonDecode(res.body); // Parse response body
      weatherData(data); // Update weather data
    } on http.ClientException {
      errorMessage('Network error. Please check your internet connection.'); // Handle network error
    } on FormatException {
      errorMessage('Data format error. Please try again later.'); // Handle data format error
    } catch (e) {
      errorMessage('An unexpected error occurred: $e'); // Handle unexpected errors
    } finally {
      isLoading(false);
    }
  }
}

class WeatherScreen extends StatelessWidget {
  final String cityName;
  const WeatherScreen({super.key, required this.cityName});

  @override
  Widget build(BuildContext context) {
    final WeatherController weatherController = Get.put(WeatherController(cityName));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          cityName, // Display city name in app bar title
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back(); // Navigate button to go back HomeScreen
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              weatherController.getCurrentWeather(); // Refresh the screen
            },
            icon: const Icon(Icons.refresh), // Refresh icon
          ),
        ],
      ),
      body: Obx(() {
        if (weatherController.isLoading.value) {
          return const Center(child: CircularProgressIndicator()); // Show loading indicator while waiting
        }

        if (weatherController.errorMessage.isNotEmpty) {
          CustomSnackbar.show(
            context,
            'Error',
            weatherController.errorMessage.value, // Show error message if any error occurs
          );
          return Center(
            child: ElevatedButton(
              onPressed: () {
                weatherController.getCurrentWeather(); // Retry fetching data
              },
              child: const Text('Retry'),
            ),
          );
        }

        final data = weatherController.weatherData;
        final currentTemp = data['list'][0]['main']['temp']; // Get current temperature
        final currentTempCelsius = (currentTemp - 273.15).toStringAsFixed(1); 
        final currentSky = data['list'][0]['weather'][0]['main']; // Get current sky condition
        final currentHumidity = data['list'][0]['main']['humidity']; // Get current humidity
        final currentPressure = data['list'][0]['main']['pressure']; // Get current pressure
        final currentWind = data['list'][0]['wind']['speed']; // Get current wind speed

        return Padding(
          padding: const EdgeInsets.all(20.0), // Padding around the main column
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card to display current weather information
              SizedBox(
                width: double.infinity,
                child: Card(
                  elevation: 15,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 5,
                        sigmaY: 5,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Text(
                              '$currentTempCelsius C°', // Display current temperature
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Icon(
                              currentSky == 'Clouds' || currentSky == 'Rain'
                                  ? Icons.cloud
                                  : Icons.wb_sunny, // Display appropriate icon based on sky condition
                              size: 60,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              currentSky, // Display sky condition
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Weather Forecast',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // ListView to display hourly weather forecast
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5, // Number of items to display
                  itemBuilder: (BuildContext context, int index) {
                    final time = DateTime.parse(data['list'][index]['dt_txt'].toString()); // Parse time
                    return HourlyForecast(
                      time: DateFormat.Hm().format(time), // Format time as 'HH:mm'
                      icon: (data['list'][index]['weather'][0]['main'] == 'Clouds' || data['list'][index]['weather'][0]['main'] == 'Rain')
                          ? Icons.cloud
                          : Icons.wb_sunny, // Display appropriate icon based on weather condition
                      temp: data['list'][index]['main']['temp'].toString(), // Display temperature
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Additional Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              // Row to display additional weather information
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AdditionalInfo(
                    icon: Icons.water_drop,
                    text: 'Humidity',
                    temp: currentHumidity.toString(), // Display humidity
                  ),
                  AdditionalInfo(
                    icon: Icons.air,
                    text: 'Wind Speed',
                    temp: currentWind.toString(), // Display wind speed
                  ),
                  AdditionalInfo(
                    icon: Icons.beach_access,
                    text: 'Pressure',
                    temp: currentPressure.toString(), // Display pressure
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
