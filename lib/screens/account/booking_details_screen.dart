import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/models/booking.dart';

class BookingDetailsScreen extends StatelessWidget {
  final Booking booking;

  const BookingDetailsScreen({super.key, required this.booking});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(booking.status ?? 'Pending');

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Booking Details',
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and ID Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BOOKING ID',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.bookingId ?? 'TX000000',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      booking.status ?? 'Pending',
                      style: GoogleFonts.outfit(
                        color: statusColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Route details (From -> To) Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ROUTE',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade800,
                    ),
                  ),
                  const Divider(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 4),
                          const Icon(Icons.circle, size: 10, color: Colors.amber),
                          Container(height: 36, width: 2, color: Colors.grey.shade300),
                          const Icon(Icons.location_on, size: 14, color: Colors.orange),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pickup Address',
                              style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade500),
                            ),
                            Text(
                              booking.pickupAddress,
                              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Drop Address',
                              style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade500),
                            ),
                            Text(
                              booking.dropAddress,
                              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Trip Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TRIP DETAILS',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade800,
                    ),
                  ),
                  const Divider(height: 20),
                  _buildDetailRow('Service Type', booking.serviceType),
                  _buildDetailRow('Way Type', booking.wayType ?? 'Oneway'),
                  _buildDetailRow('Vehicle Type', booking.vehicleCategory),
                  _buildDetailRow('Seating Capacity', '${booking.seater} Seater'),
                  _buildDetailRow('Pickup Date', booking.pickupDate),
                  _buildDetailRow('Pickup Time', booking.pickupTime),
                  if (booking.returnDate != null) ...[
                    _buildDetailRow('Return Date', booking.returnDate!),
                    _buildDetailRow('Return Time', booking.returnTime ?? 'N/A'),
                  ],
                  if (booking.isPetCab) ...[
                    _buildDetailRow('Pet Cab Ride', 'Yes (${booking.petType ?? 'N/A'})'),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Driver/Pilot Card if assigned
            if (booking.driverName != null && booking.driverName!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DRIVER & PILOT INFO',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade800,
                      ),
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.amber.shade50,
                          child: Icon(Icons.person, color: Colors.amber.shade700, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.driverName!,
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Cab No: ${booking.carNo ?? 'N/A'}',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Calling pilot at ${booking.driverNumber}...'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.phone_in_talk, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Add-On Section if present
            if (booking.addonId != null && booking.addonName != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ADD-ON SELECTIONS',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade800,
                      ),
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          booking.addonName!,
                          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '₹${booking.addonPrice?.toInt() ?? 0}',
                          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Fare breakdown Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BILL DETAILS',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade800,
                    ),
                  ),
                  const Divider(height: 20),
                  _buildDetailPriceRow('Total Fare', '₹${booking.fare.toInt()}', isBold: true),
                  _buildDetailPriceRow('Advance Paid', '₹${booking.advance.toInt()}', color: Colors.green.shade700),
                  const Divider(),
                  _buildDetailPriceRow(
                    'Remaining Due (to driver)',
                    '₹${booking.dueFare.toInt()}',
                    color: Colors.orange.shade800,
                    isBold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Timeline Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RIDE STATUS TIMELINE',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade800,
                    ),
                  ),
                  const Divider(height: 20),
                  if (booking.timeline.isEmpty) ...[
                    _buildTimelineTile(
                      'Booking Placed',
                      'We have received your ride request.',
                      booking.pickupDate,
                      isLast: true,
                    ),
                  ] else ...[
                    ...booking.timeline.asMap().entries.map((entry) {
                      int idx = entry.key;
                      var item = entry.value;
                      bool isLast = idx == booking.timeline.length - 1;
                      String timeStr = DateFormat('hh:mm a, dd MMM').format(item.timestamp);
                      return _buildTimelineTile(
                        item.status,
                        item.message,
                        timeStr,
                        isLast: isLast,
                      );
                    }),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey.shade600)),
          Text(value, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildDetailPriceRow(String label, String value, {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              color: isBold ? Colors.black87 : Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: isBold ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineTile(String title, String message, String time, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.amber, size: 20),
            if (!isLast) Container(width: 2, height: 48, color: Colors.amber.shade200),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                  ),
                  Text(
                    time,
                    style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                message,
                style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
