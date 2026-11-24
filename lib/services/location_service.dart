import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../core/api_exception.dart';

class LocationService {
  /// Ambil lokasi saat ini. Melempar [ApiException] dengan pesan yang
  /// ramah pengguna jika GPS mati / izin ditolak / timeout.
  static Future<Position> current() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw ApiException('GPS tidak aktif. Aktifkan lokasi lalu coba lagi.');
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied) {
      throw ApiException('Izin lokasi ditolak.');
    }
    if (perm == LocationPermission.deniedForever) {
      throw ApiException(
        'Izin lokasi ditolak permanen. Aktifkan lewat Pengaturan aplikasi.',
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
      throw ApiException('Gagal mendapatkan lokasi, coba lagi.');
    }
  }
}
