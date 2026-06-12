import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'date_time_picker.dart';
import '../../../widgets/city_autocomplete_field.dart';
import '../../booking/cab_selection_screen.dart';

class PackageBookingDialog extends StatefulWidget {
  final String packageName;
  final String phoneNumber;

  const PackageBookingDialog({
    super.key,
    required this.packageName,
    required this.phoneNumber,
  });

  @override
  State<PackageBookingDialog> createState() => _PackageBookingDialogState();
}

class _PackageBookingDialogState extends State<PackageBookingDialog> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController(); // For beaches
  String _selectedDhamCount = '1 DHAM';
  String _selectedItinerary = 'Yamunotri';

  String startDate = DateFormat('EEE, MMM dd').format(DateTime.now());
  String startTime = '03:00 PM';
  String endDate = DateFormat('EEE, MMM dd').format(DateTime.now().add(const Duration(days: 3)));
  String endTime = '07:00 PM';

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isChardham = widget.packageName.toUpperCase().contains('CHARDHAM');

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with lines
                Row(
                  children: [
                    const Expanded(child: Divider(color: Colors.cyan, thickness: 1.5)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        widget.packageName,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyan.shade700,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: Colors.cyan, thickness: 1.5)),
                  ],
                ),
                const SizedBox(height: 24),
                // Input Fields depending on package type
                if (isChardham) ...[
                  CityAutocompleteField(
                    label: 'FROM',
                    hint: 'Enter pickup city',
                    icon: Icons.location_on_outlined,
                    controller: _fromController,
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownField(
                    Icons.location_on_outlined,
                    'NUMBER OF DHAMS',
                    _selectedDhamCount,
                    ['1 DHAM', '2 DHAMS', '4 DHAMS'],
                    (val) => setState(() => _selectedDhamCount = val!),
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownField(
                    Icons.account_balance,
                    'ITINERARY',
                    _selectedItinerary,
                    ['Yamunotri', 'Gangotri', 'Kedarnath', 'Badrinath', 'All 4 Dhams'],
                    (val) => setState(() => _selectedItinerary = val!),
                  ),
                ] else ...[
                  CityAutocompleteField(
                    label: 'FROM',
                    hint: 'Enter pickup city',
                    icon: Icons.location_on_outlined,
                    controller: _fromController,
                  ),
                  const SizedBox(height: 12),
                  CityAutocompleteField(
                    label: 'TO (BEACH CITY)',
                    hint: 'Enter beach destination (e.g. Goa)',
                    icon: Icons.beach_access,
                    controller: _toController,
                  ),
                ],
                const SizedBox(height: 16),
                // Date Fields Row
                Row(
                  children: [
                    Expanded(
                      child: _buildDateField(context, 'TRIP START', startDate, startTime, (res) {
                        if (res != null) {
                          setState(() {
                            startDate = res['date'];
                            startTime = res['time'];
                          });
                        }
                      }),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDateField(context, 'TRIP END', endDate, endTime, (res) {
                        if (res != null) {
                          setState(() {
                            endDate = res['date'];
                            endTime = res['time'];
                          });
                        }
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Explore Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_fromController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter pickup city')),
                        );
                        return;
                      }

                      String destination;
                      if (isChardham) {
                        destination = 'Chardham ($_selectedItinerary)';
                      } else {
                        if (_toController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter beach destination')),
                          );
                          return;
                        }
                        destination = _toController.text.trim();
                      }

                      // Close the dialog
                      Navigator.pop(context);

                      // Navigate to CabSelectionScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CabSelectionScreen(
                            from: _fromController.text.trim(),
                            to: destination,
                            date: startDate,
                            time: startTime,
                            isOneWay: false,
                            phoneNumber: widget.phoneNumber,
                            rideType: 'Roundtrip',
                            endDate: endDate,
                            endTime: endTime,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      'EXPLORE CABS',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Close Button below dialog
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
    IconData icon,
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.02),
        border: Border.all(color: Colors.amber.shade100),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    isDense: true,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    style: GoogleFonts.outfit(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
                    items: items.map((String val) {
                      return DropdownMenuItem<String>(
                        value: val,
                        child: Text(val),
                      );
                    }).toList(),
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context,
    String label,
    String date,
    String subText,
    Function(Map<String, dynamic>?) onResult,
  ) {
    return GestureDetector(
      onTap: () async {
        final result = await showDialog<Map<String, dynamic>>(
          context: context,
          builder: (context) => DateTimePickerDialog(
            label: label,
            initialDate: date,
            initialTime: subText.contains('M') ? subText : '12:00 PM',
          ),
        );
        onResult(result);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.02),
          border: Border.all(color: Colors.amber.shade100),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, color: Colors.cyan.shade400, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    date,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    subText,
                    style: GoogleFonts.outfit(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}
