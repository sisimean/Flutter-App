import 'package:flutter/material.dart';

import 'Appointment Management.dart';
import 'Customer Management.dart';
import 'Order Management.dart';

class ManagementScreen extends StatelessWidget {
  const ManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('System Management')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ManagementCard(
              icon: Icons.people,
              title: 'Customer Management',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CustomerManagementScreen()),
              ),
            ),
            const SizedBox(height: 16),
            ManagementCard(
              icon: Icons.shopping_cart,
              title: 'Order Management',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrderManagementScreen()),
              ),
            ),
            const SizedBox(height: 16),
            ManagementCard(
              icon: Icons.calendar_today,
              title: 'Appointment Management',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AppointmentManagementScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ManagementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ManagementCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.brown),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, size: 30),
            ],
          ),
        ),
      ),
    );
  }
}