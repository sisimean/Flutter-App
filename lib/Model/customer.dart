// lib/Model/customer.dart
class Customer {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final int loginId;  // Add this field

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.loginId, // Require it in constructor
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      loginId: json['login_id'] ?? 0,  // Map login_id here
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'address': address,
    'login_id': loginId,  // Include in JSON output
  };
}
