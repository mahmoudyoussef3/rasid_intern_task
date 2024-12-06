import 'package:flutter/material.dart';

import '../cubit/location_cubit.dart';
import 'build_card.dart';

class BuildCoordinatesInputCard extends StatelessWidget {
  const BuildCoordinatesInputCard(
      {super.key,
      required this.cubit,
      required this.latController,
      required this.longController});
  final TextEditingController latController;
  final TextEditingController longController;
  final LocationCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BuildCardWidget(
      title: "Enter Coordinates",
      subtitle: "Input latitude and longitude to find a location.",
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: latController,
              decoration: InputDecoration(
                hintText: "Latitude",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blueAccent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: longController,
              decoration: InputDecoration(
                hintText: "Longitude",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blueAccent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.blueAccent),
            onPressed: () => cubit.getLocationFromCoordinates(
              double.tryParse(latController.text) ?? 0.0,
              double.tryParse(longController.text) ?? 0.0,
            ),
          ),
        ],
      ),
    );
  }
}
