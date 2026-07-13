import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';

class VehicleManagementScreen extends StatefulWidget {
  const VehicleManagementScreen({super.key});

  @override
  State<VehicleManagementScreen> createState() =>
      _VehicleManagementScreenState();
}

class _VehicleManagementScreenState extends State<VehicleManagementScreen> {
  final List<Map<String, dynamic>> vehicles = [
    {
      'type': 'Toyota Hiace',
      'plate': 'WXY 1234',
      'capacity': 11,
      'year': 2020,
      'status': 'active',
      'insurance': '31 Dec 2026',
      'roadtax': '31 Mar 2027',
      'psv': '15 Jun 2027',
      'lastService': '1 Apr 2026',
      'nextService': '1 Oct 2026',
      'mileage': 87420,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AeroColors.navy,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ...vehicles.map(_buildVehicleCard),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add another vehicle'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AeroColors.amber,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(
                            color: AeroColors.amber,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AeroColors.navyCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AeroColors.divider, width: 0.5),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MY VEHICLES',
                style: TextStyle(
                  fontSize: 11,
                  color: AeroColors.amber,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'Fleet management',
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
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> v) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AeroColors.navyCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AeroColors.divider, width: 0.5),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AeroColors.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.directions_car,
                    color: AeroColors.amber,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        v['type'] as String,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${v['plate']} · ${v['year']} · ${v['capacity']} pax',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AeroColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AeroColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AeroColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 0.5,
            color: AeroColors.divider,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('DOCUMENTS', style: AeroText.label),
                const SizedBox(height: 10),
                _buildDocRow(
                  'Insurance',
                  v['insurance'] as String,
                  _isExpiringSoon(v['insurance'] as String),
                ),
                _buildDocRow(
                  'Road tax',
                  v['roadtax'] as String,
                  _isExpiringSoon(v['roadtax'] as String),
                ),
                _buildDocRow(
                  'PSV licence',
                  v['psv'] as String,
                  _isExpiringSoon(v['psv'] as String),
                ),
                const SizedBox(height: 12),
                const Text('MAINTENANCE', style: AeroText.label),
                const SizedBox(height: 10),
                _buildMaintenanceRow(
                  'Last service',
                  v['lastService'] as String,
                  false,
                ),
                _buildMaintenanceRow(
                  'Next service',
                  v['nextService'] as String,
                  _isExpiringSoon(v['nextService'] as String),
                ),
                _buildMaintenanceRow(
                  'Mileage',
                  '${(v['mileage'] as int).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} km',
                  false,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AeroColors.amber,
                      side: const BorderSide(color: AeroColors.amber, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Edit details',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AeroColors.amber,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Update docs',
                      style: TextStyle(fontSize: 12),
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

  bool _isExpiringSoon(String dateStr) {
    try {
      final parts = dateStr.split(' ');
      final months = {
        'Jan': 1,
        'Feb': 2,
        'Mar': 3,
        'Apr': 4,
        'May': 5,
        'Jun': 6,
        'Jul': 7,
        'Aug': 8,
        'Sep': 9,
        'Oct': 10,
        'Nov': 11,
        'Dec': 12,
      };
      final day = int.parse(parts[0]);
      final month = months[parts[1]] ?? 1;
      final year = int.parse(parts[2]);
      final date = DateTime(year, month, day);
      final diff = date.difference(DateTime.now()).inDays;
      return diff < 90;
    } catch (_) {
      return false;
    }
  }

  Widget _buildDocRow(String label, String value, bool isExpiringSoon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isExpiringSoon
                ? Icons.warning_amber_outlined
                : Icons.check_circle_outline,
            size: 14,
            color: isExpiringSoon ? AeroColors.amber : AeroColors.success,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AeroColors.grey),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isExpiringSoon ? AeroColors.amber : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceRow(String label, String value, bool isWarning) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.build_outlined,
            size: 14,
            color: isWarning ? AeroColors.amber : AeroColors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AeroColors.grey),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isWarning ? AeroColors.amber : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
