import 'package:geolocator/geolocator.dart';

class LocationData {
  final double latitude;
  final double longitude;
  const LocationData({required this.latitude, required this.longitude});
}

const _hanoiFallback = LocationData(latitude: 21.0285, longitude: 105.8542);

class LocationService {
  /// Returns current device location, or Hanoi coordinates as fallback
  /// if permission is denied, service is off, or an error occurs.
  Future<LocationData> getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return _hanoiFallback;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return _hanoiFallback;
      }
      if (permission == LocationPermission.deniedForever) return _hanoiFallback;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      ).timeout(const Duration(seconds: 10));

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      return _hanoiFallback;
    }
  }
}
