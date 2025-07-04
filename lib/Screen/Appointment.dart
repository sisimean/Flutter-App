import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../Model/appointment.dart';
import '../Model/product.dart';
import '../services/appointment_service.dart';
import 'Appointment/AppointmentDetailScreen.dart';

class AppointmentScreen extends StatefulWidget {
  final Product? product;
  final int? loginId;

  const AppointmentScreen({super.key, this.product, this.loginId});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _appointmentService = AppointmentService();
  int _selectedCustomerId = 1;
  List<Customer> _customers = [];
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final _serviceTypeController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
    if (widget.product != null) {
      _serviceTypeController.text = 'Support for ${widget.product!.name}';
    }
  }

  Future<void> _fetchCustomers() async {
    try {
      final response = await http
          .get(
            Uri.parse('http://10.0.2.2:8000/api/customers'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          _customers =
              (json.decode(response.body) as List)
                  .map((json) => Customer.fromJson(json))
                  .toList();

          if (widget.loginId != null) {
            final matchedCustomer = _customers.firstWhere(
              (c) => c.loginId == widget.loginId,
              orElse: () => _customers.first,
            );

            _selectedCustomerId = matchedCustomer.id;
          } else if (_customers.isNotEmpty) {
            _selectedCustomerId = _customers.first.id;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading customers: \$e')));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme:
                isDark
                    ? const ColorScheme.dark(
                      primary: Colors.deepPurple,
                      onPrimary: Colors.white,
                      surface: Colors.blueGrey,
                      onSurface: Colors.white,
                    )
                    : const ColorScheme.light(
                      primary: Colors.deepPurple,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Colors.black,
                    ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme:
                isDark
                    ? const ColorScheme.dark(
                      primary: Colors.deepPurple,
                      onPrimary: Colors.white,
                      surface: Colors.blueGrey,
                      onSurface: Colors.white,
                    )
                    : const ColorScheme.light(
                      primary: Colors.deepPurple,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Colors.black,
                    ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _bookAppointment(DateTime appointmentDateTime) async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final appointment = await _appointmentService.createAppointment(
          customerId: _selectedCustomerId,
          serviceType: _serviceTypeController.text,
          appointmentDate: appointmentDateTime,
          notes: _notesController.text,
          productImageUrl: widget.product?.imagePath,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment booked successfully!'),
            backgroundColor: Colors.grey,
          ),
        );

        Navigator.pop(context, appointment);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error booking appointment: \$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointmentDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: Colors.brown.shade800,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.product != null) ...[
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap:
                              () => _showImagePopup(
                                context,
                                widget.product!.imagePath,
                              ),
                          child: Hero(
                            tag: 'product-image-\${widget.product?.id}',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child:
                                  widget.product!.imagePath != null
                                      ? Image.network(
                                        widget.product!.imagePath!,
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.broken_image,
                                                  size: 60,
                                                ),
                                      )
                                      : const Icon(
                                        Icons.shopping_cart,
                                        size: 60,
                                      ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.product!.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${widget.product!.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.pink,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (_customers.isNotEmpty)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.location_on,
                      color: Colors.green,
                    ),
                    title: const Text("Current Address"),
                    subtitle: Text(
                      _customers
                          .firstWhere((c) => c.id == _selectedCustomerId)
                          .address,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _serviceTypeController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Service Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.construction,color: Colors.green,),
                ),
                validator:
                    (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.calendar_today,color: Colors.green,),
                      ),
                      controller: TextEditingController(
                        text: DateFormat('dd MMM, yyyy').format(_selectedDate),
                      ),
                      onTap: () => _selectDate(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Time',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.access_time,color: Colors.green,),
                      ),
                      controller: TextEditingController(
                        text: _selectedTime.format(context),
                      ),
                      onTap: () => _selectTime(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.notes,color: Colors.green),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _bookAppointment(appointmentDateTime),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('BOOK APPOINTMENT'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePopup(BuildContext context, String? imageUrl) {
    if (imageUrl == null) return;

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder:
            (context, _, __) => Scaffold(
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
                          tag: 'product-image-\${widget.product?.id}',
                          child: Image.network(
                            imageUrl,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 50,
                                      color: Colors.white,
                                    ),
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
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 30,
                        ),
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
}
