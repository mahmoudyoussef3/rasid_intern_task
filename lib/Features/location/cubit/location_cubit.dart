import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  LocationCubit() : super(LocationInitial());

  Future<void> getCurrentLocation() async {
    emit(LocationLoading());

    try {
      await _checkLocationPermissions();

      final position = await Geolocator.getCurrentPosition();

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      emit(LocationSuccess(
        position: position,
        placemark: placemarks.first,
        method: 'Current Location',
      ));
    } catch (e) {
      emit(LocationFailure(errorMessage: e.toString()));
    }
  }

  Future<void> getLocationFromCoordinates(double lat, double lng) async {
    emit(LocationLoading());

    try {
      final position = Position(
        latitude: lat,
        longitude: lng,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );

      final placemarks = await placemarkFromCoordinates(lat, lng);

      emit(LocationSuccess(
        position: position,
        placemark: placemarks.first,
        method: 'Manual Coordinates',
      ));
    } catch (_) {
      emit(LocationFailure(errorMessage: 'Invalid coordinates'));
    }
  }

  Future<void> getLocationFromLink(String link) async {
    emit(LocationLoading());

    try {
      final coordinates = _extractCoordinatesFromLink(link);
      if (coordinates == null) {
        throw Exception('Could not extract coordinates from the link');
      }

      await getLocationFromCoordinates(coordinates[0], coordinates[1]);
    } catch (e) {
      emit(LocationFailure(errorMessage: e.toString()));
    }
  }

  List<double>? _extractCoordinatesFromLink(String link) {
    print('Link: $link');
    final patterns = [
      RegExp(r'@([-.\d]+),([-.\d]+)'),
      RegExp(r'q=([-.\d]+),([-.\d]+)'),
      RegExp(r'([-.\d]+)[,\s]+([-.\d]+)'),
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(link);
      if (match != null) {
        print('Pattern: $pattern, Match: ${match.group(0)}');
        final lat = double.tryParse(match.group(1)!);
        final lng = double.tryParse(match.group(2)!);
        if (lat != null && lng != null) {
          print('Coordinates: $lat, $lng');
          return [lat, lng];
        }
      }
    }

    print('No matching pattern found for the link: $link');
    return null;
  }

  Future<void> _checkLocationPermissions() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Location services are disabled');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }
  }
}
