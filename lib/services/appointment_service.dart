import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/appointment.dart';

class AppointmentService {
  static const String _baseUrl = 'http://10.0.2.2:8000/api';

  Future<List<Appointment>> fetchAppointments() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/appointments'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Appointment.fromJson(json)).toList();
      }
      throw Exception('Failed to load appointments: ${response.statusCode}');
    } catch (e) {
      throw Exception('Appointment fetch error: $e');
    }
  }

  Future<Appointment> createAppointment({
    required int customerId,
    required String serviceType,
    required DateTime appointmentDate,
    required String notes,
    String? productImageUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/appointments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'customer_id': customerId,
          'service_type': serviceType,
          'appointment_date': appointmentDate.toIso8601String(),
          'notes': notes,
          'status': 'scheduled',
          'product_image_url': productImageUrl,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        return Appointment.fromJson(json.decode(response.body));
      }
      throw Exception('Failed to create appointment: ${response.statusCode}');
    } catch (e) {
      throw Exception('Appointment creation error: $e');
    }
  }

  Future<void> deleteAppointment(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/appointments/$id'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 204) {
        throw Exception('Failed to delete appointment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Appointment deletion error: $e');
    }
  }
}