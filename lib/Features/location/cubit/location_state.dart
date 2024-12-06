import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

abstract class LocationState {}


class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationSuccess extends LocationState {
  Position? position;
  Placemark? placemark;
  String? method;

  LocationSuccess({
    required this.position,
    required this.placemark,
    required this.method,
  });
}

class LocationFailure extends LocationState {
  String errorMessage;

  LocationFailure({required this.errorMessage});
}
