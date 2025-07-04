import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Model/appointment.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final List<Appointment> initialAppointments;
  final Function(int) onRemove;

  const AppointmentDetailScreen({
    super.key,
    required this.initialAppointments,
    required this.onRemove,
  });

  @override
  State<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  late List<Appointment> appointments;
  final Map<String, bool> _expandedCategories = {};

  @override
  void initState() {
    super.initState();
    appointments = List.from(widget.initialAppointments);
  }

  Map<String, List<int>> _groupAppointmentsByCategory(List<Appointment> items) {
    Map<String, List<int>> grouped = {};
    for (int i = 0; i < items.length; i++) {
      final name = items[i].serviceType;
      String category = 'Others';

      if (name.contains("iPhone") ||
          name.contains("Samsung") ||
          name.contains("Xiaomi") ||
          name.contains("Google") ||
          name.contains("Sony") ||
          name.contains("Oppo") ||
          name.contains("Realme") ||
          name.contains("ASUS")) {
        category = 'Phone';
      } else if (name.contains("iPad")) {
        category = 'IPad';
      } else if (name.contains("MacBook") ||
          name.contains("Lenovo") ||
          name.contains("Dell") ||
          name.contains("HP")) {
        category = 'Laptop';
      } else if (name.contains("iMac")) {
        category = 'Desktop';
      }

      grouped.putIfAbsent(category, () => []);
      grouped[category]!.add(i);
    }
    return grouped;
  }

  String _getCategoryIcon(String category) {
    switch (category) {
      case 'Phone':
        return '📱';
      case 'IPad':
        return '📲';
      case 'Laptop':
        return '💻';
      case 'Desktop':
        return '🖥️';
      default:
        return '📦';
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupedAppointments = _groupAppointmentsByCategory(appointments);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details'),
        backgroundColor: Colors.brown.shade800,
        foregroundColor: Colors.white,
      ),
      body:
          appointments.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No appointments found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: groupedAppointments.length,
                itemBuilder: (context, groupIndex) {
                  String category = groupedAppointments.keys.elementAt(
                    groupIndex,
                  );
                  List<int> appointmentIndices = groupedAppointments[category]!;
                  final isExpanded = _expandedCategories[category] ?? true;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        tileColor:
                            isDark ? Colors.grey[800] : Colors.grey.shade300,
                        title: Text(
                          '${_getCategoryIcon(category)} $category (${appointmentIndices.length})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                          ),
                          onPressed: () {
                            setState(() {
                              _expandedCategories[category] = !isExpanded;
                            });
                          },
                        ),
                      ),
                      if (isExpanded)
                        ...appointmentIndices.map((index) {
                          final appointment = appointments[index];
                          return _buildAppointmentCard(appointment);
                        }),
                    ],
                  );
                },
              ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    appointment.serviceType,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteConfirmation(appointment.id),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.location_on,
              'Address: ${appointment.customer.address}',
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.calendar_today,
              'Date: ${DateFormat('MMM dd, yyyy').format(appointment.appointmentDate)}',
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.access_time,
              'Time: ${DateFormat('hh:mm a').format(appointment.appointmentDate)}',
            ),
            const SizedBox(height: 8),
            _buildStatusRow(appointment.status),
            if (appointment.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildDetailRow(Icons.notes, 'Notes: ${appointment.notes}'),
            ],
            if (appointment.productImageUrl != null) ...[
              const SizedBox(height: 12),
              _buildAppointmentImage(appointment.productImageUrl!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
      ],
    );
  }

  Widget _buildStatusRow(String status) {
    final statusColor = _getStatusColor(status);
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          'Status: ${status[0].toUpperCase()}${status.substring(1)}',
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentImage(String imageUrl) {
    return GestureDetector(
      onTap: () => _showImagePopup(imageUrl),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value:
                      loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                ),
              );
            },
            errorBuilder:
                (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'confirmed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  void _showImagePopup(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Hero(
                    tag: 'appointment-image-$imageUrl',
                    child: Image.network(imageUrl),
                  ),
                ),
              ),
            ),
      ),
    );
  }

  void _showDeleteConfirmation(int appointmentId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Deletion'),
            content: const Text(
              'Are you sure you want to delete this appointment?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _removeAppointment(appointmentId);
                  widget.onRemove(appointmentId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Appointment deleted successfully'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _removeAppointment(int id) {
    setState(() {
      appointments.removeWhere((appt) => appt.id == id);
    });
  }
}
