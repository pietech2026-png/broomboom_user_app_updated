import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DateTimePickerDialog extends StatefulWidget {
  final String label;
  final String initialDate;
  final String initialTime;

  const DateTimePickerDialog({
    super.key,
    required this.label,
    this.initialDate = '',
    this.initialTime = '03:45 PM',
  });

  @override
  State<DateTimePickerDialog> createState() => _DateTimePickerDialogState();
}

class _DateTimePickerDialogState extends State<DateTimePickerDialog> {
  late List<String> dates;
  late List<String> displayDates;
  late List<String> hours;
  late List<String> minutes;
  late List<String> periods;

  late int selectedDateIndex;
  late int selectedHourIndex;
  late int selectedMinuteIndex;
  late int selectedPeriodIndex;

  @override
  void initState() {
    super.initState();
    dates = _generateDates(false);
    displayDates = _generateDates(true);
    hours = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'];
    minutes = ['00', '15', '30', '45'];
    periods = ['AM', 'PM'];

    // Initialize indices based on initial values if provided
    selectedDateIndex = 0;
    if (widget.initialDate.isNotEmpty) {
      final cleanInitial = widget.initialDate.replaceAll(',', '').trim().toLowerCase();
      for (int i = 0; i < dates.length; i++) {
        if (dates[i].replaceAll(',', '').trim().toLowerCase() == cleanInitial) {
          selectedDateIndex = i;
          break;
        }
      }
    }

    // Safe Parse initial time "HH:MM AM/PM"
    try {
      String time = widget.initialTime;
      if (time.contains(':') && time.contains(' ')) {
        String h = time.split(':')[0];
        String m = time.split(':')[1].split(' ')[0];
        String p = time.split(' ')[1];

        selectedHourIndex = hours.indexOf(h);
        selectedMinuteIndex = minutes.indexOf(m);
        selectedPeriodIndex = periods.indexOf(p);
      } else {
        throw Exception("Invalid format");
      }
    } catch (e) {
      selectedHourIndex = 2; // Default 3
      selectedMinuteIndex = 3; // Default 45
      selectedPeriodIndex = 1; // Default PM
    }

    if (selectedHourIndex == -1) selectedHourIndex = 2;
    if (selectedMinuteIndex == -1) selectedMinuteIndex = 3;
    if (selectedPeriodIndex == -1) selectedPeriodIndex = 1;
  }

  List<String> _generateDates(bool forDisplay) {
    List<String> d = [];
    DateTime now = DateTime.now();
    for (int i = 0; i < 90; i++) {
      DateTime date = now.add(Duration(days: i));
      if (forDisplay && i == 0) {
        d.add('Today');
      } else {
        d.add(DateFormat('EEE, MMM dd').format(date));
      }
    }
    return d;
  }

  String _getDialogTitle() {
    final labelLower = widget.label.toLowerCase();
    if (labelLower.contains('start')) {
      return 'Select Trip Start Date & Time';
    } else if (labelLower.contains('end')) {
      return 'Select Trip End Date & Time';
    }
    return 'Select ${widget.label} Date & Time';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _getDialogTitle(),
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.black87, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    padding: const EdgeInsets.all(4),
                    minimumSize: const Size(32, 32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 180,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildPickerColumn(displayDates, selectedDateIndex, (i) => setState(() => selectedDateIndex = i), flex: 3),
                          _buildPickerColumn(hours, selectedHourIndex, (i) => setState(() => selectedHourIndex = i), flex: 1),
                          Text(':', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.amber.shade800)),
                          _buildPickerColumn(minutes, selectedMinuteIndex, (i) => setState(() => selectedMinuteIndex = i), flex: 1),
                          _buildPickerColumn(periods, selectedPeriodIndex, (i) => setState(() => selectedPeriodIndex = i), flex: 1),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.02),
                        border: Border.all(color: Colors.amber.shade100),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.label.toUpperCase(),
                            style: GoogleFonts.outfit(fontSize: 10, color: Colors.amber, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dates[selectedDateIndex],
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(
                            '${hours[selectedHourIndex]}:${minutes[selectedMinuteIndex]} ${periods[selectedPeriodIndex]}',
                            style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          String resultDate = dates[selectedDateIndex];
                          String resultTime = '${hours[selectedHourIndex]}:${minutes[selectedMinuteIndex]} ${periods[selectedPeriodIndex]}';
                          Navigator.pop(context, {'date': resultDate, 'time': resultTime});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade400,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text(
                          'CONFIRM',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerColumn(List<String> items, int selectedIndex, Function(int) onSelected, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.08),
              border: Border.all(color: Colors.amber.shade200, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          ListWheelScrollView.useDelegate(
            itemExtent: 40,
            perspective: 0.003,
            diameterRatio: 1.5,
            physics: const FixedExtentScrollPhysics(),
            controller: FixedExtentScrollController(initialItem: selectedIndex),
            onSelectedItemChanged: onSelected,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: items.length,
              builder: (context, index) {
                bool isSelected = index == selectedIndex;
                return Center(
                  child: Text(
                    items[index],
                    style: GoogleFonts.outfit(
                      fontSize: isSelected ? 16 : 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.amber.shade800 : Colors.grey.shade400,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
