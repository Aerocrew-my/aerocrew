import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';
import 'package:aerocrew/screens/operator/operator_documents_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OperatorProfileScreen extends StatefulWidget {
  const OperatorProfileScreen({super.key});

  @override
  State<OperatorProfileScreen> createState() => _OperatorProfileScreenState();
}

class _OperatorProfileScreenState extends State<OperatorProfileScreen> {
  bool isLoading = false;
  String selectedVehicle = 'Toyota Hiace';
  final nameController = TextEditingController();
  final plateController = TextEditingController();
  final zonesController = TextEditingController();
  final capacityController = TextEditingController();

  final vehicles = [
    'Toyota Hiace',
    'Toyota Alphard',
    'Toyota Vellfire',
    'Honda Odyssey',
    'Nissan Serena',
    'Toyota Innova',
    'Other MPV',
  ];

  Future<void> _saveProfile() async {
    if (nameController.text.isEmpty ||
        plateController.text.isEmpty ||
        zonesController.text.isEmpty ||
        capacityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    setState(() => isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'companyName': nameController.text.trim(),
        'vehicleType': selectedVehicle,
        'plateNumber': plateController.text.trim().toUpperCase(),
        'coverageZones': zonesController.text.trim(),
        'capacity': int.tryParse(capacityController.text.trim()) ?? 8,
        'profileComplete': true,
        'status': 'pending_documents',
      });
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OperatorDocumentsScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
    setState(() => isLoading = false);
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
                          Icons.directions_car,
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
                            'Operator profile',
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Tell us about\nyour vehicle.',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
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
                          const Text(
                            'COMPANY / FULL NAME',
                            style: AeroText.label,
                          ),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: nameController,
                            hint: 'Ahmad Hassan Transport',
                            icon: Icons.business_outlined,
                          ),
                          const SizedBox(height: 16),
                          const Text('VEHICLE TYPE', style: AeroText.label),
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
                                value: selectedVehicle,
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: AeroColors.grey,
                                ),
                                items: vehicles
                                    .map(
                                      (v) => DropdownMenuItem(
                                        value: v,
                                        child: Text(
                                          v,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) =>
                                    setState(() => selectedVehicle = val!),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text('PLATE NUMBER', style: AeroText.label),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: plateController,
                            hint: 'WXY 1234',
                            icon: Icons.confirmation_number_outlined,
                          ),
                          const SizedBox(height: 16),
                          const Text('COVERAGE ZONES', style: AeroText.label),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: zonesController,
                            hint: 'e.g. PJ, Shah Alam, Subang Jaya',
                            icon: Icons.location_on_outlined,
                          ),
                          const SizedBox(height: 16),
                          const Text('MAX PASSENGERS', style: AeroText.label),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: capacityController,
                            hint: '8',
                            icon: Icons.people_outline,
                            type: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AeroColors.infoLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AeroColors.infoText.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AeroColors.infoText,
                                  size: 18,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'You\'ll upload SSM, PSV licence and operator permit on the next step.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AeroColors.infoText,
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
                                          'Continue to documents',
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
}
