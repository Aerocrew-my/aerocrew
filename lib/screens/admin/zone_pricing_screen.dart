import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';

class ZonePricingScreen extends StatefulWidget {
  const ZonePricingScreen({super.key});

  @override
  State<ZonePricingScreen> createState() => _ZonePricingScreenState();
}

class _ZonePricingScreenState extends State<ZonePricingScreen> {
  final List<Map<String, dynamic>> _zones = [
    {
      'id': 'Z001',
      'name': 'KLIA Terminal 1',
      'base': 45.00,
      'perKm': 2.50,
      'surge': 1.0,
      'active': true,
    },
    {
      'id': 'Z002',
      'name': 'KLIA2',
      'base': 40.00,
      'perKm': 2.30,
      'surge': 1.2,
      'active': true,
    },
    {
      'id': 'Z003',
      'name': 'Subang SZB',
      'base': 30.00,
      'perKm': 2.00,
      'surge': 1.0,
      'active': true,
    },
    {
      'id': 'Z004',
      'name': 'Penang PEN',
      'base': 25.00,
      'perKm': 1.80,
      'surge': 1.0,
      'active': false,
    },
    {
      'id': 'Z005',
      'name': 'Kota Kinabalu BKI',
      'base': 28.00,
      'perKm': 1.90,
      'surge': 1.0,
      'active': false,
    },
  ];

  int? _editingIndex;
  final _baseController = TextEditingController();
  final _perKmController = TextEditingController();
  final _surgeController = TextEditingController();

  void _openEditSheet(int index) {
    final zone = _zones[index];
    _baseController.text = zone['base'].toStringAsFixed(2);
    _perKmController.text = zone['perKm'].toStringAsFixed(2);
    _surgeController.text = zone['surge'].toStringAsFixed(1);
    setState(() => _editingIndex = index);

    showModalBottomSheet(
      context: context,
      backgroundColor: AeroColors.navyCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        zone['id'] as String,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AeroColors.amber,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1),
                      ),
                      Text(
                        zone['name'] as String,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: AeroColors.grey),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSheetField('Base fare (RM)', _baseController, 'e.g. 45.00'),
            const SizedBox(height: 14),
            _buildSheetField(
                'Per km rate (RM)', _perKmController, 'e.g. 2.50'),
            const SizedBox(height: 14),
            _buildSheetField(
                'Surge multiplier', _surgeController, 'e.g. 1.2'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _zones[index]['base'] =
                        double.tryParse(_baseController.text) ??
                            _zones[index]['base'];
                    _zones[index]['perKm'] =
                        double.tryParse(_perKmController.text) ??
                            _zones[index]['perKm'];
                    _zones[index]['surge'] =
                        double.tryParse(_surgeController.text) ??
                            _zones[index]['surge'];
                  });
                  Navigator.pop(context);
                  _showSavedSnack(zone['name'] as String);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AeroColors.amber,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Save pricing',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    ).whenComplete(() => setState(() => _editingIndex = null));
  }

  void _showSavedSnack(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AeroColors.navyCard,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline,
                color: AeroColors.amber, size: 18),
            const SizedBox(width: 10),
            Text('$name pricing updated',
                style:
                    const TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildSheetField(
      String label, TextEditingController ctrl, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                color: AeroColors.grey,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(color: AeroColors.grey, fontSize: 13),
            filled: true,
            fillColor: AeroColors.navy,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AeroColors.divider, width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AeroColors.divider, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AeroColors.amber, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _zones.where((z) => z['active'] == true).length;

    return Scaffold(
      backgroundColor: AeroColors.navy,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
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
                        border: Border.all(
                            color: AeroColors.divider, width: 0.5),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ADMIN',
                          style: TextStyle(
                              fontSize: 11,
                              color: AeroColors.amber,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1)),
                      Text('Zone Pricing',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AeroColors.amber.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$activeCount active',
                      style: const TextStyle(
                          fontSize: 12,
                          color: AeroColors.amber,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Summary strip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AeroColors.navyCard,
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: AeroColors.divider, width: 0.5),
                ),
                child: Row(
                  children: [
                    _buildStat('${_zones.length}', 'Total zones'),
                    _buildDivider(),
                    _buildStat('$activeCount', 'Active'),
                    _buildDivider(),
                    _buildStat(
                        '${_zones.length - activeCount}', 'Inactive'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Section label
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('ALL ZONES',
                    style: TextStyle(
                        fontSize: 11,
                        color: AeroColors.grey,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1)),
              ),
            ),
            const SizedBox(height: 10),

            // Zone list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                itemCount: _zones.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _buildZoneCard(i),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneCard(int index) {
    final zone = _zones[index];
    final bool active = zone['active'] as bool;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AeroColors.navyCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: active ? AeroColors.divider : AeroColors.divider,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: active
                      ? AeroColors.amber.withOpacity(0.15)
                      : AeroColors.navy,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: active ? AeroColors.amber : AeroColors.grey,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zone['name'] as String,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: active ? Colors.white : AeroColors.grey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      zone['id'] as String,
                      style: const TextStyle(
                          fontSize: 11, color: AeroColors.grey),
                    ),
                  ],
                ),
              ),
              Switch(
                value: active,
                onChanged: (v) =>
                    setState(() => _zones[index]['active'] = v),
                activeColor: AeroColors.amber,
                activeTrackColor: AeroColors.amber.withOpacity(0.3),
                inactiveThumbColor: AeroColors.grey,
                inactiveTrackColor: AeroColors.navy,
              ),
            ],
          ),
          if (active) ...[
            const SizedBox(height: 12),
            Container(
              height: 0.5,
              color: AeroColors.divider,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildPricePill(
                    'Base', 'RM ${zone['base'].toStringAsFixed(2)}'),
                const SizedBox(width: 8),
                _buildPricePill(
                    '/km', 'RM ${zone['perKm'].toStringAsFixed(2)}'),
                const SizedBox(width: 8),
                _buildPricePill(
                    'Surge', '×${zone['surge'].toStringAsFixed(1)}'),
                const Spacer(),
                GestureDetector(
                  onTap: () => _openEditSheet(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AeroColors.navy,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AeroColors.divider, width: 0.5),
                    ),
                    child: const Text('Edit',
                        style: TextStyle(
                            fontSize: 12,
                            color: AeroColors.amber,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPricePill(String label, String value) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AeroColors.navy,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AeroColors.divider, width: 0.5),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AeroColors.grey)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AeroColors.grey)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
        width: 0.5, height: 32, color: AeroColors.divider);
  }
}
