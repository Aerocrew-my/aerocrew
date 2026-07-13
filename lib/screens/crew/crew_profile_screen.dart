import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';
import 'package:aerocrew/screens/crew/staff_id_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CrewProfileScreen extends StatefulWidget {
  const CrewProfileScreen({super.key});

  @override
  State<CrewProfileScreen> createState() => _CrewProfileScreenState();
}

class _CrewProfileScreenState extends State<CrewProfileScreen> {
  bool isLoading = false;
  String selectedAirline = 'AirAsia';
  String selectedAirport = 'Subang Airport (SZB)';
  final zoneController = TextEditingController();
  final staffIdController = TextEditingController();

  final airlines = [
    'AirAsia',
    'Malaysia Airlines',
    'Batik Air',
    'FireFly',
    'Berjaya Air',
    'Other',
  ];
  final airports = [
    'Subang Airport (SZB)',
    'Kuala Lumpur International Airport (KLIA)',
    'Kuala Lumpur International Airport 2 (KLIA2)',
    'Penang International Airport (PEN)',
  ];

  Future<void> _saveProfile() async {
    if (zoneController.text.isEmpty || staffIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    setState(() => isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'airline': selectedAirline,
        'baseAirport': selectedAirport,
        'homeZone': zoneController.text.trim(),
        'staffId': staffIdController.text.trim(),
        'profileComplete': true,
      });
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const StaffIdScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
    setState(() => isLoading = false);
  }

  Widget _buildProgressDot(bool active) {
    return Container(
      width: active ? 24 : 10,
      height: 10,
      decoration: BoxDecoration(
        color: active ? AeroColors.amber : AeroColors.divider,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  Widget _buildProgressLine() {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        color: AeroColors.divider,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AeroColors.grey),
        prefixIcon: Icon(icon, color: AeroColors.grey, size: 20),
        filled: true,
        fillColor: AeroColors.cardWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AeroColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AeroColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AeroColors.amber, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AeroText.label),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AeroColors.cardWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AeroColors.cardBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AeroColors.grey,
              ),
              items: items
                  .map(
                    (a) => DropdownMenuItem(
                      value: a,
                      child: Text(a, style: const TextStyle(fontSize: 14)),
                    ),
                  )
                  .toList(),
              onChanged: (val) => onChanged(val!),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AeroColors.navy,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AeroColors.amber.withValues(alpha: 0.05),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AeroColors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.flight_takeoff,
                          color: AeroColors.amber,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STEP 1 OF 2',
                            style: TextStyle(
                              fontSize: 11,
                              color: AeroColors.amber,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            'Crew profile',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Complete your profile',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tell us about your flying schedule',
                        style: TextStyle(fontSize: 14, color: AeroColors.grey),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildProgressDot(true),
                          _buildProgressLine(),
                          _buildProgressDot(false),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AeroColors.background,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          _buildDropdown(
                            'AIRLINE',
                            selectedAirline,
                            airlines,
                            (val) => setState(() => selectedAirline = val),
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            'BASE AIRPORT',
                            selectedAirport,
                            airports,
                            (val) => setState(() => selectedAirport = val),
                          ),
                          const SizedBox(height: 16),
                          const Text('HOME AREA / ZONE', style: AeroText.label),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: zoneController,
                            hint: 'e.g. Petaling Jaya, Selangor',
                            icon: Icons.location_on_outlined,
                          ),
                          const SizedBox(height: 16),
                          const Text('STAFF ID', style: AeroText.label),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: staffIdController,
                            hint: 'e.g. AA-12345',
                            icon: Icons.badge_outlined,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AeroColors.amberLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AeroColors.amberBorder),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AeroColors.amber,
                                  size: 18,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'You\'ll upload your staff ID photo on the next step for verification.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AeroColors.amber,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AeroColors.amber,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Continue',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward, size: 18),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
