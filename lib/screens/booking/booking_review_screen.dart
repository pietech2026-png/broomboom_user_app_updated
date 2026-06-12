import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/services/booking_service.dart';
import '../../data/models/booking.dart';
import '../../data/models/addon.dart';
import '../home/home_screen.dart';
import 'booking_success_screen.dart';

class BookingReviewScreen extends StatefulWidget {
  final String from;
  final String to;
  final List<String> stops;
  final String date;
  final String time;
  final bool isOneWay;
  final String carName;
  final String price;
  final String phoneNumber;
  final String rideType;
  final double? advance;
  final double? dueFare;
  final String? state;
  final int? packageHours;
  final int? includedKms;
  final String? pickupDate;
  final String? pickupTime;
  final String? returnDate;
  final String? returnTime;
  final bool isPetCab;
  final String? petType;

  const BookingReviewScreen({
    super.key,
    required this.from,
    required this.to,
    this.stops = const [],
    required this.date,
    required this.time,
    required this.isOneWay,
    required this.carName,
    required this.price,
    required this.phoneNumber,
    required this.rideType,
    this.advance,
    this.dueFare,
    this.state,
    this.packageHours,
    this.includedKms,
    this.pickupDate,
    this.pickupTime,
    this.returnDate,
    this.returnTime,
    this.isPetCab = false,
    this.petType,
  });

  @override
  State<BookingReviewScreen> createState() => _BookingReviewScreenState();
}

class _BookingReviewScreenState extends State<BookingReviewScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pickupLocationController = TextEditingController();
  final TextEditingController _dropLocationController = TextEditingController();
  late TextEditingController _phoneController;

  // Add-on States (Backend Driven)
  List<AddOn> _addons = [];
  final Set<String> _selectedAddonIds = {};
  bool _loadingAddons = true;

  // Coupon & Price State
  late double _basePrice;
  double _discount = 0;
  String _appliedCoupon = '';
  final TextEditingController _couponController = TextEditingController();
  int _selectedPaymentType = 1; // 0 = Book at ₹0, 1 = Pay default advance (e.g. 25%), 2 = Pay 100%

  @override
  void initState() {
    super.initState();
    String displayPhone = widget.phoneNumber;
    if (displayPhone.startsWith('91') && displayPhone.length > 10) {
      displayPhone = displayPhone.substring(2);
    }
    _phoneController = TextEditingController(text: displayPhone);
    _pickupLocationController.text = widget.from + (widget.stops.isNotEmpty ? " (via ${widget.stops.join(', ')})" : "");
    _dropLocationController.text = widget.to;

    // Initialize price (parsing '₹ 3243' -> 3243.0)
    _basePrice = double.tryParse(widget.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;

    _fetchAddons();
  }

  Future<void> _fetchAddons() async {
    try {
      final list = await BookingService.getActiveAddons();
      if (mounted) {
        setState(() {
          _addons = list;
          _loadingAddons = false;
        });
      }
    } catch (e) {
      print('Error fetching active addons in UI: $e');
      if (mounted) {
        setState(() {
          _loadingAddons = false;
        });
      }
    }
  }

  void _applyCoupon() {
    String code = _couponController.text.toUpperCase().trim();
    setState(() {
      if (code == 'BROOMBOOM10') {
        _discount = _basePrice * 0.10;
        _appliedCoupon = code;
      } else if (code == 'FIRST500') {
        _discount = 500.0;
        _appliedCoupon = code;
      } else {
        _discount = 0;
        _appliedCoupon = '';
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid Coupon Code'), backgroundColor: Colors.red),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Coupon $code Applied Successfully!'), backgroundColor: Colors.green),
      );
    });
  }

  double get _addonsTotal {
    double total = 0;
    for (var addon in _addons) {
      if (_selectedAddonIds.contains(addon.id)) {
        total += addon.price;
      }
    }
    return total;
  }

  double get _finalPrice => (_basePrice + _addonsTotal) - _discount;

  double get _defaultAdvancePercentage {
    if (widget.advance != null && widget.advance! > 0) {
      double basePriceFromWidget = double.tryParse(widget.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
      if (basePriceFromWidget > 0) {
        return (widget.advance! / basePriceFromWidget) * 100;
      }
    }
    return 25.0;
  }

  double get _advancePercentage {
    if (_selectedPaymentType == 0) return 0.0;
    if (_selectedPaymentType == 2) return 100.0;
    return _defaultAdvancePercentage;
  }

  double get _advancePrice {
    if (_selectedPaymentType == 0) return 0.0;
    if (_selectedPaymentType == 2) return _finalPrice;
    if (widget.advance != null && widget.advance! > 0) {
      double basePriceFromWidget = double.tryParse(widget.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
      if (basePriceFromWidget > 0) {
        double ratio = widget.advance! / basePriceFromWidget;
        return _finalPrice * ratio;
      }
    }
    return _finalPrice * 0.25;
  }

  double get _duePrice => _finalPrice - _advancePrice;

  bool _isCreatingBooking = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _pickupLocationController.dispose();
    _dropLocationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirmBooking() async {
    if (_nameController.text.isEmpty || _pickupLocationController.text.isEmpty || _dropLocationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() {
      _isCreatingBooking = true;
    });

    final selectedAddons = _addons.where((a) => _selectedAddonIds.contains(a.id)).toList();
    final String? addonId = selectedAddons.isNotEmpty ? selectedAddons.first.id : null;
    final String? addonName = selectedAddons.isNotEmpty 
        ? selectedAddons.map((a) => a.name).join(', ') 
        : null;
    final double addonPrice = selectedAddons.isNotEmpty ? selectedAddons.first.price : 0.0;
    final double totalAddonAmount = _addonsTotal;

    final booking = Booking(
      customerName: _nameController.text,
      customerMobile: widget.phoneNumber,
      customerEmail: _emailController.text,
      serviceType: widget.rideType,
      wayType: widget.isOneWay ? 'One Way' : 'Round Trip',
      rentalPackage: widget.packageHours != null ? '${widget.packageHours} hrs / ${widget.includedKms} kms' : null,
      state: widget.state ?? 'Default',
      pickupAddress: _pickupLocationController.text,
      dropAddress: _dropLocationController.text,
      pickupDate: widget.pickupDate ?? widget.date,
      pickupTime: widget.pickupTime ?? widget.time,
      returnDate: widget.returnDate,
      returnTime: widget.returnTime,
      vehicleCategory: widget.carName,
      seater: 4,
      fare: _finalPrice,
      advance: _advancePrice,
      dueFare: _duePrice,
      isPetCab: widget.isPetCab,
      petType: widget.petType,
      addonId: addonId,
      addonName: addonName,
      addonPrice: addonPrice,
      totalAddonAmount: totalAddonAmount,
    );

    final result = await BookingService.createBooking(booking);

    if (mounted) {
      setState(() {
        _isCreatingBooking = false;
      });

      if (result != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => BookingSuccessScreen(
              bookingId: result.bookingId ?? '',
              phoneNumber: widget.phoneNumber,
            ),
          ),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to confirm booking. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Review Your Booking',
          style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.amber.shade400, size: 30),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(),
                  _buildAdvancePaymentInfo(),
                  const SizedBox(height: 12),
                  _buildCancellationPolicy(),
                  const SizedBox(height: 20),
                  _buildContactForm(),
                  const SizedBox(height: 24),
                  _buildCouponsSection(),
                  const SizedBox(height: 24),
                  _buildPersonalizeSection(),
                  const SizedBox(height: 24),
                  _buildInclusionsExclusionsSection(),
                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),
          _buildBottomPaymentBar(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    String routeText = '${widget.from} -> ${widget.to}';
    if (widget.stops.isNotEmpty) {
      routeText = '${widget.from} -> ${widget.stops.join(' -> ')} -> ${widget.to}';
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$routeText (${widget.isOneWay ? "Oneway" : "Roundtrip"})',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildSummaryItem('Car Type:', '${widget.carName} or Equivalent'),
          _buildSummaryItem('Pickup Date:', '${widget.date} ${widget.time}'),
          _buildSummaryItem('Kms included:', widget.includedKms != null ? '${widget.includedKms} kms' : '260 kms'),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        children: [
          Text('$label ', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13)),
          Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildCancellationPolicy() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time_filled, color: Colors.orange.shade700, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Free cancellation till 1 hr of departure',
              style: GoogleFonts.outfit(color: Colors.brown.shade700, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Details',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 24),
          _buildTextField('Full Name', _nameController),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 70,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Text('+91', style: GoogleFonts.outfit(color: Colors.grey.shade600)),
                    const Icon(Icons.keyboard_arrow_down, size: 14, color: Colors.grey),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Mobile No.',
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    Positioned(
                      top: -2,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        color: Colors.grey.shade100,
                        child: Text('Mobile No.', style: GoogleFonts.outfit(fontSize: 10, color: Colors.amber)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField('Email ID', _emailController),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildFormButton(Icons.add, 'Alternate Email'),
              const SizedBox(width: 12),
              _buildFormButton(Icons.add, 'Add GST'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: GoogleFonts.outfit(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildFormButton(IconData icon, String label) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 16, color: Colors.amber.shade400),
        label: Text(label, style: GoogleFonts.outfit(color: Colors.amber.shade400, fontSize: 12)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.amber.shade300),
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildCouponsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Coupons & Offers', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _appliedCoupon.isNotEmpty ? Colors.green.shade300 : Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _couponController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'ENTER A COUPON (Try BROOMBOOM10)',
                    hintStyle: GoogleFonts.outfit(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _applyCoupon,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade400,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('APPLY', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        if (_appliedCoupon.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 4),
            child: Text(
              'Applied: $_appliedCoupon (-₹${_discount.toStringAsFixed(0)})',
              style: GoogleFonts.outfit(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildPersonalizeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.stars, color: Colors.amber.shade400, size: 20),
              const SizedBox(width: 8),
              Text('Personalize Your Journey', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber.shade600)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Enhance your travel experience with our premium add-ons', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade700)),
          const Divider(height: 32),
          if (_loadingAddons)
            const Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: CircularProgressIndicator(),
            ))
          else if (_addons.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text('No add-ons available.', style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey)),
            )
          else
            ..._addons.map((addon) => _buildAddonItem(
                  addon.name,
                  '₹ ${addon.price.toStringAsFixed(0)}',
                  isSelected: _selectedAddonIds.contains(addon.id),
                  description: addon.description,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedAddonIds.add(addon.id);
                      } else {
                        _selectedAddonIds.remove(addon.id);
                      }
                    });
                  },
                )),
        ],
      ),
    );
  }

  Widget _buildAddonItem(String title, String price, {bool isPopular = false, bool isSelected = false, String? description, ValueChanged<bool?>? onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.grey.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? Colors.amber.shade100 : Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: onChanged ?? (val) {},
                activeColor: Colors.amber.shade400,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
                    if (isPopular) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(4)),
                        child: Text('Most Popular', style: GoogleFonts.outfit(fontSize: 10, color: Colors.orange.shade700, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
              ),
              Text(price, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          if (description != null && isSelected) ...[
            const Padding(
              padding: EdgeInsets.only(left: 48, top: 8),
              child: Divider(),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 48, top: 4),
              child: Text(description, style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade700, height: 1.4)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInclusionsExclusionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Inclusions/Exclusions', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('INCLUSIONS', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
              const SizedBox(height: 8),
              _buildInclusionPoint(Icons.check_circle, 'Fuel Charges', true),
              _buildInclusionPoint(Icons.check_circle, 'Driver Allowance', true),
              if (!widget.isOneWay) ...[
                _buildInclusionPoint(Icons.check_circle, 'Driver Driving Allowance', true),
                _buildInclusionPoint(Icons.check_circle, 'Hour Charges', true),
              ],
              const Divider(height: 24),
              Text('EXCLUSIONS', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red)),
              const SizedBox(height: 8),
              _buildInclusionPoint(Icons.cancel, 'Toll / State Tax', false),
              _buildInclusionPoint(Icons.cancel, 'GST (5%)', false),
              _buildInclusionPoint(Icons.cancel, 'Parking Charges', false),
              const Divider(height: 32),
              Text(
                'Terms and Conditions',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                '• Night allowance is applicable from 10 PM to 6 AM.\n• Extra kms will be charged at ₹14.5/km.\n• Toll and state tax will be extra as per actuals.',
                style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade700, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInclusionPoint(IconData icon, String text, bool isIncluded) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isIncluded ? Colors.green : Colors.red),
          const SizedBox(width: 8),
          Text(text, style: GoogleFonts.outfit(fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildBottomPaymentBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('Total Fare ', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                  Icon(Icons.info_outline, size: 16, color: Colors.grey.shade400),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_discount > 0)
                    Text(
                      '₹ ${_basePrice.toStringAsFixed(0)}',
                      style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey, decoration: TextDecoration.lineThrough),
                    ),
                  Text('₹ ${_finalPrice.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildPayOption(
                'Book at ₹0',
                isSelected: _selectedPaymentType == 0,
                onTap: () {
                  setState(() {
                    _selectedPaymentType = 0;
                  });
                },
              ),
              const SizedBox(width: 8),
              _buildPayOption(
                'Pay ${_defaultAdvancePercentage.toStringAsFixed(0)}%',
                isSelected: _selectedPaymentType == 1,
                onTap: () {
                  setState(() {
                    _selectedPaymentType = 1;
                  });
                },
              ),
              const SizedBox(width: 8),
              _buildPayOption(
                'Pay 100%',
                isSelected: _selectedPaymentType == 2,
                onTap: () {
                  setState(() {
                    _selectedPaymentType = 2;
                  });
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isCreatingBooking ? null : _handleConfirmBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: _isCreatingBooking
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Pay Now',
                                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('₹ ${_advancePrice.toStringAsFixed(0)}',
                                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 14)),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPayOption(String label, {bool isSelected = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber.shade400 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? Colors.amber.shade400 : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancePaymentInfo() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment_outlined, color: Colors.amber.shade800, size: 20),
              const SizedBox(width: 8),
              Text(
                'Fare & Advance Summary',
                style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
              ),
            ],
          ),
          const Divider(height: 20, color: Colors.amber),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Ride Fare:', style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade700)),
              Text('₹ ${_finalPrice.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Advance Booking %:', style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade700)),
              Text('${_advancePercentage.toStringAsFixed(0)}%', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.amber.shade800)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Advance Amount Payable:', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
              Text('₹ ${_advancePrice.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Due Amount (Payable to pilot):', style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade700)),
              Text('₹ ${_duePrice.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
            ],
          ),
        ],
      ),
    );
  }
}
