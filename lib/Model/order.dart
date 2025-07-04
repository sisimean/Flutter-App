import 'customer.dart';

class Order {
  final int id;
  final int customerId;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Customer customer;

  Order({
    required this.id,
    required this.customerId,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.customer,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerId: json['customer_id'],
      totalAmount: double.parse(json['total_amount'].toString()),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      customer: Customer.fromJson(json['customer']),
    );
  }
}