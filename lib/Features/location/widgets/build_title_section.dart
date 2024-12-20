import 'package:flutter/material.dart';

class BuildTitleSection extends StatelessWidget {
  const BuildTitleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Find Your Location",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Icon(
                Icons.location_on,
                size: 30,
                color: Colors.white,
              ),
            ],
          ),
          SizedBox(height: 5),
          Text(
            "Enter coordinates or a link, or fetch directly!",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
