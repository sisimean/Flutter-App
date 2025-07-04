import 'package:intl/intl.dart';

class Customer {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final int? loginId; // <-- Add this line

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.loginId, // <-- Add this
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      loginId: json['login_id'], // <-- Add this
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'address': address,
    'login_id': loginId, // <-- Add this
  };
}


class Appointment {
  final int id;
  final int customerId;
  final String serviceType;
  final DateTime appointmentDate;
  final String notes;
  final String status;
  final Customer customer;
  final String? productImageUrl;

  Appointment({
    required this.id,
    required this.customerId,
    required this.serviceType,
    required this.appointmentDate,
    required this.notes,
    required this.status,
    required this.customer,
    this.productImageUrl,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      serviceType: json['service_type'] ?? '',
      appointmentDate: DateTime.parse(json['appointment_date']),
      notes: json['notes'] ?? '',
      status: json['status'] ?? 'scheduled',
      customer: Customer.fromJson(json['customer'] ?? {}),
      productImageUrl: json['product_image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'service_type': serviceType,
      'appointment_date': appointmentDate.toIso8601String(),
      'notes': notes,
      'status': status,
      'customer': customer.toJson(),
    };
  }

  String get formattedDate =>
      DateFormat('MMM dd, yyyy - hh:mm a').format(appointmentDate);
}
