import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/booking.dart';
import '../models/addon.dart';
import 'api_service.dart';

class BookingService {
  static Future<List<Booking>> getMyBookings() async {
    try {
      final response = await ApiService.get('/bookings');
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Booking.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load bookings');
      }
    } catch (e) {
      print('Error fetching bookings: $e');
      return [];
    }
  }

  static Future<Booking?> createBooking(Booking booking) async {
    try {
      final response = await ApiService.post('/bookings', booking.toJson());
      if (response.statusCode == 201) {
        return Booking.fromJson(jsonDecode(response.body));
      } else {
        print('Create booking failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error creating booking: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> calculateFare({
    required double distance,
    required String category,
    required String state,
    String? city,
    String? addonId,
  }) async {
    try {
      final response = await ApiService.post('/bookings/calculate-fare', {
        'distance': distance,
        'category': category,
        'state': state,
        'city': city,
        if (addonId != null) 'addonId': addonId,
      });
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error calculating fare: $e');
      return null;
    }
  }

  static Future<List<AddOn>> getActiveAddons() async {
    try {
      final response = await ApiService.get('/addons');
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        final list = data.map<AddOn>((item) => AddOn.fromJson(item)).toList();
        if (list.isNotEmpty) {
          return list;
        }
      }
      throw Exception('Empty or failed response');
    } catch (e) {
      return [
        AddOn(
          id: '60b8d29f12ab3f0015f8a001',
          name: 'Child Seat',
          description: 'Safe and comfortable car seat for children up to 4 years old.',
          price: 300,
          isActive: true,
        ),
        AddOn(
          id: '60b8d29f12ab3f0015f8a002',
          name: 'WiFi Hotspot',
          description: 'High-speed internet connection during your ride.',
          price: 150,
          isActive: true,
        ),
        AddOn(
          id: '60b8d29f12ab3f0015f8a003',
          name: 'Luggage Carrier',
          description: 'Top-roof carrier for extra luggage capacity.',
          price: 200,
          isActive: true,
        ),
      ];
    }
  }

  static Future<bool> saveSearchLead({
    required String pickupLocation,
    required String dropLocation,
    required String journeyDate,
    required String journeyTime,
    required String phoneNumber,
    bool isPetCab = false,
    String? petType,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString('user_name');

      final response = await ApiService.post('/search-leads', {
        'userName': userName,
        'customerMobile': phoneNumber,
        'pickupLocation': pickupLocation,
        'dropLocation': dropLocation,
        'journeyDate': journeyDate,
        'journeyTime': journeyTime,
        'isPetCab': isPetCab,
        if (petType != null) 'petType': petType,
      });
      return response.statusCode == 201;
    } catch (e) {
      print('Error saving search lead: $e');
      return false;
    }
  }
}
