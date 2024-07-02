 import 'package:flutter/material.dart';

class HourlyForecast extends StatelessWidget {
  final String time;
  final IconData icon;
  final String temp;

  const HourlyForecast({
    super.key, // Added Key? key
    required this.time,
    required this.icon,
    required this.temp,
  }) ; // Set the key in the constructor

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            Text(
              time,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(
              height: 8,
            ),
            Icon(icon,size: 30,), // Fixed
            const SizedBox(
              height: 8,
            ),
            Text(
              temp.toString(),
              style: const TextStyle(
                // fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
