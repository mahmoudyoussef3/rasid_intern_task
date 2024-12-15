import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rasid_intern_taks/Features/location/widgets/build_action_button.dart';
import 'package:rasid_intern_taks/Features/location/widgets/build_coordinates_input_card.dart';
import 'package:rasid_intern_taks/Features/location/widgets/build_maps_input_card.dart';
import 'package:rasid_intern_taks/Features/location/widgets/build_title_section.dart';
import '../cubit/location_cubit.dart';
import '../cubit/location_state.dart';

class LocationFetcherScreen extends StatefulWidget {
  LocationFetcherScreen({super.key});

  @override
  State<LocationFetcherScreen> createState() => _LocationFetcherScreenState();
}

class _LocationFetcherScreenState extends State<LocationFetcherScreen> {
  final TextEditingController _mapsLinkController = TextEditingController();

  final TextEditingController _latController = TextEditingController();

  final TextEditingController _longController = TextEditingController();
  @override
  void initState() {
    super.initState();
    context.read<LocationCubit>().checkLocationPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Location Fetcher',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: BlocProvider(
        create: (_) => LocationCubit(),
        child: BlocConsumer<LocationCubit, LocationState>(
          listener: (context, state) {
            if (state is LocationFailure) {
              _showErrorDialog(context, state.errorMessage);
            }
          },
          builder: (context, state) {
            final cubit = context.read<LocationCubit>();

            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo, Colors.blueAccent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const BuildTitleSection(),
                    const SizedBox(height: 10),
                    BuildMapsInputCard(
                        cubit: cubit, mapsLinkController: _mapsLinkController),
                    const SizedBox(height: 20),
                    BuildCoordinatesInputCard(
                      cubit: cubit,
                      latController: _latController,
                      longController: _longController,
                    ),
                    const SizedBox(height: 20),
                    BuildActionButton(
                      label: "Get Current Location",
                      icon: Icons.location_searching,
                      onPressed: () => cubit.getCurrentLocation(),
                    ),
                    const SizedBox(height: 20),
                    _buildLocationDetailsCard(state),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLocationDetailsCard(LocationState state) {
    if (state is LocationLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else if (state is LocationSuccess) {
      return Card(
        elevation: 5,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.blue[800], size: 30),
                  const SizedBox(width: 8),
                  Text(
                    "Location Details",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.map, "Method:", state.method!),
              _buildDetailRow(Icons.my_location, "Latitude:",
                  state.position?.latitude.toString() ?? "Unavailable"),
              _buildDetailRow(Icons.my_location, "Longitude:",
                  state.position?.longitude.toString() ?? "Unavailable"),
              const Divider(height: 20, thickness: 1),
              Row(
                children: [
                  Icon(Icons.home, color: Colors.blue[800], size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    "Address:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${state.placemark?.street}, ${state.placemark?.locality}, '
                '${state.placemark?.administrativeArea}, ${state.placemark?.country}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      );
    } else if (state is LocationFailure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Text(
              "Error: ${state.errorMessage}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox(
        height: 400,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: Color(0xffFD9600), size: 40),
              SizedBox(height: 8),
              Text(
                "No location data available",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xffFD9600),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[700], size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
