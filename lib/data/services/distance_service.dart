import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'location_service.dart';

class DistanceService {
  static const String osrmUrl = 'http://router.project-osrm.org/route/v1/driving';

  static double _getHaversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0; // Earth's radius in km
    final dLat = (lat2 - lat1) * math.pi / 180.0;
    final dLon = (lon2 - lon1) * math.pi / 180.0;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180.0) *
            math.cos(lat2 * math.pi / 180.0) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a));
    return r * c;
  }

  static Future<double> getDistance(String from, String to) async {
    double? lat1, lon1, lat2, lon2;

    try {
      final fromData = await LocationService.searchCities(from);
      final toData = await LocationService.searchCities(to);

      if (fromData.isEmpty || toData.isEmpty) return 0.0;

      lat1 = double.tryParse(fromData[0]['lat']?.toString() ?? '');
      lon1 = double.tryParse(fromData[0]['lon']?.toString() ?? '');
      lat2 = double.tryParse(toData[0]['lat']?.toString() ?? '');
      lon2 = double.tryParse(toData[0]['lon']?.toString() ?? '');

      if (lat1 == null || lon1 == null || lat2 == null || lon2 == null) {
        return 0.0;
      }

      final response = await http.get(
        Uri.parse('$osrmUrl/$lon1,$lat1;$lon2,$lat2?overview=false'),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          return (data['routes'][0]['distance'] / 1000.0);
        }
      }
    } catch (e) {
      print('Error calculating OSRM distance: $e. Using Haversine fallback.');
    }

    // Fallback to Haversine straight-line distance with routing factor
    if (lat1 != null && lon1 != null && lat2 != null && lon2 != null) {
      final distance = _getHaversineDistance(lat1, lon1, lat2, lon2);
      return distance * 1.25; // Estimate real road route distance
    }

    return 0.0;
  }
}
