// ... (your existing imports)
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../Model/product.dart';
import '../providers/cart_provider.dart';
import 'cart/cart_screen.dart';

class OrderScreen extends StatefulWidget {
  final Product product;

  const OrderScreen({super.key, required this.product});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _formKey = GlobalKey<FormState>();
  int _quantity = 1;
  int _selectedCustomerId = 1;
  List<Customer> _customers = [];

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/customers'));
      if (response.statusCode == 200) {
        setState(() {
          _customers = (json.decode(response.body) as List)
              .map((json) => Customer.fromJson(json))
              .toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading customers: $e')),
      );
    }
  }

  void _showSuccessAnimation() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Success',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (_, animation, __, ___) {
        return Center(
          child: AnimatedBuilder(
            animation: animation,
            builder: (_, __) {
              return Opacity(
                opacity: animation.value,
                child: Transform.scale(
                  scale: animation.value,
                  child: AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 80),
                        const SizedBox(height: 16),
                        const Text(
                          'Order Placed!',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Your order was placed successfully.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:  Colors.green.shade800,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context); // Close dialog
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const CartScreen()),
                            );
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _submitOrder() async {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      cartProvider.addToCart(widget.product, _quantity, _selectedCustomerId);

      final order = {
        'customer_id': _selectedCustomerId,
        'items': [
          {
            'product_id': widget.product.id,
            'quantity': _quantity,
            'unit_price': widget.product.price,
          }
        ],
      };

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/orders'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(order),
      );

      if (response.statusCode == 201) {
        // ✅ Decrease stock after successful order
        setState(() {
          widget.product.stock -= _quantity;
        });

        _showSuccessAnimation();
      } else {
        throw Exception('Failed to create order');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order ${widget.product.name}', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.brown.shade800,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProductCard(),
              const SizedBox(height: 24),
              _buildQuantitySelector(),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _quantity > 0 ? _submitOrder : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:  Colors.brown.shade800,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Place Order', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              if (widget.product.imagePath != null) {
                _showImagePopup(context, widget.product.imagePath!);
              }
            },
            child: Hero(
              tag: 'product-image-${widget.product.id}',
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: widget.product.imagePath != null
                      ? Image.network(
                    widget.product.imagePath!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, size: 50),
                    ),
                  )
                      : Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 50),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(widget.product.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  '\$${widget.product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    color:  Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(widget.product.description,
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePopup(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, _, __) => Scaffold(
          backgroundColor: Colors.black.withOpacity(0.9),
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Hero(
                      tag: 'product-image-${widget.product.id}',
                      child: Image.network(
                        imageUrl,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.brown,
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 50, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedCustomerId,
      items: _customers.map((customer) {
        return DropdownMenuItem<int>(
          value: customer.id,
          child: Text(customer.name, style: const TextStyle(color: Colors.black)),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedCustomerId = value!),
      decoration: const InputDecoration(
        labelText: 'Customer',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        const Text('Quantity:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  if (_quantity > 1) {
                    setState(() => _quantity--);
                  }
                },
                color: _quantity > 1 ?  Colors.green.shade800 : Colors.grey,
              ),
              Text('$_quantity', style: const TextStyle(fontSize: 18)),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  if (_quantity < widget.product.stock) {
                    setState(() => _quantity++);
                  }
                },
                color: _quantity < widget.product.stock ?  Colors.green.shade800 : Colors.grey,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class Customer {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
