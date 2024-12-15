import 'package:flutter/material.dart';
import 'package:rasid_intern_taks/Features/location/cubit/location_cubit.dart';

import 'build_card.dart';

class BuildMapsInputCard extends StatelessWidget {
  const BuildMapsInputCard(
      {super.key, required this.cubit, required this.mapsLinkController});
  final TextEditingController mapsLinkController;
  final LocationCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BuildCardWidget(
      title: "Google Maps Link",
      subtitle: "Paste a link to fetch location coordinates.",
      child: TextField(
        controller: mapsLinkController,
        decoration: InputDecoration(
          hintText: "Enter Google Maps link",
          prefixIcon: const Icon(Icons.map, color: Color(0xff2195f1)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue[800]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Color(0xff2195f1))),
              onPressed: () =>
                  cubit.extractCoordinatesFromLink(mapsLinkController.text),
            ),
          ),
        ),
      ),
    );
  }
}
