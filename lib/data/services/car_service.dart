import 'dart:convert';
import '../models/car_category.dart';
import 'api_service.dart';

class CarService {
  static Future<List<CarCategory>> getCarCategories() async {
    try {
      final response = await ApiService.get('/car-categories');
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => CarCategory.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load car categories');
      }
    } catch (e) {
      print('Error fetching car categories: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> calculatePrice({
    required String rideType,
    required String sourceCity,
    required String destinationCity,
    required String category,
    required double distance,
    int? days,
    String? state,
    double? pickupLat,
    double? pickupLng,
    double? dropLat,
    double? dropLng,
    int? packageHours,
    int? includedKms,
    String? pickupDate,
    String? pickupTime,
    String? returnDate,
    String? returnTime,
    bool? isPetCab,
  }) async {
    try {
      final response = await ApiService.post('/pricing-rules/calculate', {
        'rideType': rideType,
        'sourceCity': sourceCity,
        'destinationCity': destinationCity,
        'category': category,
        'distance': distance,
        'days': days ?? 1,
        'state': state ?? '',
        if (pickupLat != null) 'pickupLat': pickupLat,
        if (pickupLng != null) 'pickupLng': pickupLng,
        if (dropLat != null) 'dropLat': dropLat,
        if (dropLng != null) 'dropLng': dropLng,
        if (packageHours != null) 'packageHours': packageHours,
        if (includedKms != null) 'includedKms': includedKms,
        if (pickupDate != null) 'pickupDate': pickupDate,
        if (pickupTime != null) 'pickupTime': pickupTime,
        if (returnDate != null) 'returnDate': returnDate,
        if (returnTime != null) 'returnTime': returnTime,
        if (isPetCab != null) 'isPetCab': isPetCab,
      });

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      print('Error calculating price: $e');
      return {};
    }
  }
}
