import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../core/api_exception.dart';

class LocationService {
  /// Ambil lokasi saat ini. Melempar [ApiException] dengan pesan yang
  /// ramah pengguna jika GPS mati / izin ditolak / timeout.
  static Future<Position> current() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw ApiException(
        'Location services are turned off. Please enable GPS and try again.',
      );
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied) {
      throw ApiException('Location permission was denied.');
    }
    if (perm == LocationPermission.deniedForever) {
      throw ApiException(
        'Location permission is permanently denied. Please enable it in the app settings.',
      );
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
    } on TimeoutException {
      throw ApiException('Unable to get your location, please try again.');
    }
  }
}
