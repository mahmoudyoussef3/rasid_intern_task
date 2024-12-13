import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'location_state.dart';
import 'package:http/http.dart' as http;

class LocationCubit extends Cubit<LocationState> {
  LocationCubit() : super(LocationInitial());

  Future<void> getCurrentLocation() async {
    emit(LocationLoading());

    try {
      await checkLocationPermissions();

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

  Future<String?> resolveRedirect(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      if (response.isRedirect) {
        return response.headers['location'];
      }
      return null;
    } catch (e) {
      emit(LocationFailure(
          errorMessage: 'Failed to resolve redirect: ${e.toString()}'));
      return null;
    }
  }

  Future<void> extractCoordinatesFromLink(String url) async {
    emit(LocationLoading());
    try {
      if (url.contains('maps.app.goo.gl')) {
        url = await resolveRedirect(url) ?? url;
      }

      final regex = RegExp(r'@([-.\d]+),([-.\d]+)');
      final match = regex.firstMatch(url);
      if (match != null) {
        final lat = double.parse(match.group(1)!);
        final lng = double.parse(match.group(2)!);

        await getLocationFromCoordinates(lat, lng);
      } else {
        emit(LocationFailure(
            errorMessage: 'Invalid URL: No coordinates found.'));
      }
    } catch (e) {
      emit(LocationFailure(
          errorMessage: 'Failed to extract coordinates: ${e.toString()}'));
    }
  }

  Future<void> checkLocationPermissions() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
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
