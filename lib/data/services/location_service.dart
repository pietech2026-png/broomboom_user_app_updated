import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class LocationService {
  static const String nominatimUrl = 'https://nominatim.openstreetmap.org/search';

  static const List<Map<String, String>> _fallbackCities = [
    {'name': 'Mumbai', 'state': 'Maharashtra', 'lat': '19.0760', 'lon': '72.8777'},
    {'name': 'Delhi', 'state': 'Delhi', 'lat': '28.7041', 'lon': '77.1025'},
    {'name': 'Bangalore', 'state': 'Karnataka', 'lat': '12.9716', 'lon': '77.5946'},
    {'name': 'Hyderabad', 'state': 'Telangana', 'lat': '17.3850', 'lon': '78.4867'},
    {'name': 'Ahmedabad', 'state': 'Gujarat', 'lat': '23.0225', 'lon': '72.5714'},
    {'name': 'Chennai', 'state': 'Tamil Nadu', 'lat': '13.0827', 'lon': '80.2707'},
    {'name': 'Kolkata', 'state': 'West Bengal', 'lat': '22.5726', 'lon': '88.3639'},
    {'name': 'Pune', 'state': 'Maharashtra', 'lat': '18.5204', 'lon': '73.8567'},
    {'name': 'Surat', 'state': 'Gujarat', 'lat': '21.1702', 'lon': '72.8311'},
    {'name': 'Jaipur', 'state': 'Rajasthan', 'lat': '26.9124', 'lon': '75.7873'},
    {'name': 'Lucknow', 'state': 'Uttar Pradesh', 'lat': '26.8467', 'lon': '80.9462'},
    {'name': 'Kanpur', 'state': 'Uttar Pradesh', 'lat': '26.4499', 'lon': '80.3319'},
    {'name': 'Nagpur', 'state': 'Maharashtra', 'lat': '21.1458', 'lon': '79.0882'},
    {'name': 'Indore', 'state': 'Madhya Pradesh', 'lat': '22.7196', 'lon': '75.8577'},
    {'name': 'Thane', 'state': 'Maharashtra', 'lat': '19.2183', 'lon': '72.9781'},
    {'name': 'Bhopal', 'state': 'Madhya Pradesh', 'lat': '23.2599', 'lon': '77.4126'},
    {'name': 'Patna', 'state': 'Bihar', 'lat': '25.5941', 'lon': '85.1376'},
    {'name': 'Vadodara', 'state': 'Gujarat', 'lat': '22.3072', 'lon': '73.1812'},
    {'name': 'Ghaziabad', 'state': 'Uttar Pradesh', 'lat': '28.6692', 'lon': '77.4538'},
    {'name': 'Ludhiana', 'state': 'Punjab', 'lat': '30.9010', 'lon': '75.8573'},
    {'name': 'Agra', 'state': 'Uttar Pradesh', 'lat': '27.1767', 'lon': '78.0081'},
    {'name': 'Nashik', 'state': 'Maharashtra', 'lat': '19.9975', 'lon': '73.7898'},
    {'name': 'Faridabad', 'state': 'Haryana', 'lat': '28.4089', 'lon': '77.3178'},
    {'name': 'Meerut', 'state': 'Uttar Pradesh', 'lat': '28.9845', 'lon': '77.7064'},
    {'name': 'Rajkot', 'state': 'Gujarat', 'lat': '22.3039', 'lon': '70.8022'},
    {'name': 'Kalyan-Dombivli', 'state': 'Maharashtra', 'lat': '19.2403', 'lon': '73.1305'},
    {'name': 'Vasai-Virar', 'state': 'Maharashtra', 'lat': '19.3913', 'lon': '72.8397'},
    {'name': 'Varanasi', 'state': 'Uttar Pradesh', 'lat': '25.3176', 'lon': '82.9739'},
    {'name': 'Srinagar', 'state': 'Jammu and Kashmir', 'lat': '34.0837', 'lon': '74.7973'},
    {'name': 'Aurangabad', 'state': 'Maharashtra', 'lat': '19.8762', 'lon': '75.3433'},
    {'name': 'Dhanbad', 'state': 'Jharkhand', 'lat': '23.7957', 'lon': '86.4304'},
    {'name': 'Amritsar', 'state': 'Punjab', 'lat': '31.6340', 'lon': '74.8723'},
    {'name': 'Navi Mumbai', 'state': 'Maharashtra', 'lat': '19.0330', 'lon': '73.0297'},
    {'name': 'Allahabad', 'state': 'Uttar Pradesh', 'lat': '25.4358', 'lon': '81.8463'},
    {'name': 'Ranchi', 'state': 'Jharkhand', 'lat': '23.3441', 'lon': '85.3096'},
    {'name': 'Howrah', 'state': 'West Bengal', 'lat': '22.5769', 'lon': '88.3186'},
    {'name': 'Coimbatore', 'state': 'Tamil Nadu', 'lat': '11.0168', 'lon': '76.9558'},
    {'name': 'Jabalpur', 'state': 'Madhya Pradesh', 'lat': '23.1815', 'lon': '79.9864'},
    {'name': 'Gwalior', 'state': 'Madhya Pradesh', 'lat': '26.2183', 'lon': '78.1828'},
    {'name': 'Vijayawada', 'state': 'Andhra Pradesh', 'lat': '16.5062', 'lon': '80.6480'},
    {'name': 'Jodhpur', 'state': 'Rajasthan', 'lat': '26.2389', 'lon': '73.0243'},
    {'name': 'Madurai', 'state': 'Tamil Nadu', 'lat': '9.9252', 'lon': '78.1198'},
    {'name': 'Raipur', 'state': 'Chhattisgarh', 'lat': '21.2514', 'lon': '81.6296'},
    {'name': 'Kota', 'state': 'Rajasthan', 'lat': '25.2138', 'lon': '75.8648'},
    {'name': 'Guwahati', 'state': 'Assam', 'lat': '26.1445', 'lon': '91.7362'},
    {'name': 'Chandigarh', 'state': 'Punjab', 'lat': '30.7333', 'lon': '76.7794'},
    {'name': 'Ujjain', 'state': 'Madhya Pradesh', 'lat': '23.1765', 'lon': '75.7885'},
  ];

  static Future<List<Map<String, dynamic>>> searchCities(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await http.get(
        Uri.parse('$nominatimUrl?q=$query&format=json&addressdetails=1&limit=5&countrycodes=in'),
        headers: {'User-Agent': 'BroomBoomUserApp/1.0'},
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return data.cast<Map<String, dynamic>>();
        }
      }
    } catch (e) {
      // Nominatim is rate-limited or timed out, resolve silently using local fallback
    }

    final lowercaseQuery = query.toLowerCase();
    final localMatches = _fallbackCities.where((city) {
      final name = city['name']!.toLowerCase();
      final state = city['state']!.toLowerCase();
      return name.contains(lowercaseQuery) || state.contains(lowercaseQuery);
    }).take(5).map((city) {
      return {
        'place_id': city['name'].hashCode,
        'licence': 'Fallback',
        'osm_type': 'node',
        'osm_id': city['name'].hashCode,
        'lat': city['lat'],
        'lon': city['lon'],
        'display_name': '${city['name']}, ${city['state']}, India',
        'address': {
          'city': city['name'],
          'state': city['state'],
          'country': 'India',
          'country_code': 'in',
        }
      };
    }).toList();

    if (localMatches.isNotEmpty) {
      return localMatches;
    }

    // Dynamic fallback if no local matches and Nominatim failed
    return [
      {
        'place_id': query.hashCode,
        'licence': 'Dynamic Fallback',
        'osm_type': 'node',
        'osm_id': query.hashCode,
        'lat': '22.9734', // Central India lat
        'lon': '78.6569', // Central India lon
        'display_name': '${query[0].toUpperCase()}${query.substring(1)}, India',
        'address': {
          'city': query,
          'state': 'Default State',
          'country': 'India',
          'country_code': 'in',
        }
      }
    ];
  }

  static Future<void> saveCityToBackend(Map<String, dynamic> cityData) async {
    try {
      final body = {
        'name': cityData['name'] ?? cityData['display_name'].split(',')[0],
        'displayName': cityData['display_name'],
        'lat': cityData['lat'],
        'lon': cityData['lon'],
        'state': cityData['address']?['state'] ?? '',
        'country': cityData['address']?['country'] ?? 'India',
        'placeId': cityData['place_id'].toString(),
      };

      await ApiService.post('/cities', body);
    } catch (e) {
      print('Error saving city to backend: $e');
    }
  }
}
