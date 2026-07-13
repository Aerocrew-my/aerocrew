import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  final List<Map<String, dynamic>> addresses = [
    {
      'label': 'Home',
      'address': 'No. 12, Jalan PJU 1/3, Petaling Jaya, Selangor',
      'icon': Icons.home_outlined,
      'color': AeroColors.amber,
      'isDefault': true,
    },
    {
      'label': 'Parents',
      'address': 'No. 5, Jalan SS 21/62, Damansara Utama, PJ',
      'icon': Icons.people_outline,
      'color': AeroColors.success,
      'isDefault': false,
    },
    {
      'label': 'Apartment',
      'address': 'Unit 8-12, Ara Damansara Residences, PJ',
      'icon': Icons.apartment_outlined,
      'color': AeroColors.infoText,
      'isDefault': false,
    },
  ];

  bool showAddForm = false;
  final labelController = TextEditingController();
  final addressController = TextEditingController();

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AeroColors.amber.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AeroColors.amber.withValues(alpha: 0.2),
                          width: 0.5,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AeroColors.amber,
                            size: 16,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Your default address is used for all AeroPool pickups. Set it to your most frequent pickup location.',
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
                    const SizedBox(height: 20),
                    const Text('SAVED ADDRESSES', style: AeroText.label),
                    const SizedBox(height: 10),
                    ...addresses.asMap().entries.map((e) {
                      final addr = e.value;
                      final color = addr['color'] as Color;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: addr['isDefault'] == true
                              ? color.withValues(alpha: 0.06)
                              : AeroColors.navyCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: addr['isDefault'] == true
                                ? color.withValues(alpha: 0.3)
                                : AeroColors.divider,
                            width: addr['isDefault'] == true ? 1 : 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                addr['icon'] as IconData,
                                color: color,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        addr['label'] as String,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      if (addr['isDefault'] == true) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: color.withValues(
                                              alpha: 0.12,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            'Default',
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: color,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    addr['address'] as String,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AeroColors.grey,
                                    ),
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              color: AeroColors.navyCard,
                              icon: const Icon(
                                Icons.more_vert,
                                color: AeroColors.grey,
                                size: 18,
                              ),
                              onSelected: (value) {
                                if (value == 'default') {
                                  setState(() {
                                    for (final a in addresses) {
                                      a['isDefault'] = false;
                                    }
                                    addresses[e.key]['isDefault'] = true;
                                  });
                                } else if (value == 'delete') {
                                  setState(() => addresses.removeAt(e.key));
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: 'default',
                                  child: Text(
                                    'Set as default',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: AeroColors.danger,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                    if (showAddForm) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AeroColors.navyCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AeroColors.amber.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ADD ADDRESS', style: AeroText.label),
                            const SizedBox(height: 12),
                            _buildAddField(
                              labelController,
                              'Label (e.g. Home)',
                              Icons.label_outline,
                            ),
                            const SizedBox(height: 10),
                            _buildAddField(
                              addressController,
                              'Full address',
                              Icons.location_on_outlined,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (labelController.text.isNotEmpty &&
                                          addressController.text.isNotEmpty) {
                                        setState(() {
                                          addresses.add({
                                            'label': labelController.text,
                                            'address': addressController.text,
                                            'icon': Icons.location_on,
                                            'color': AeroColors.amber,
                                            'isDefault': false,
                                          });
                                          labelController.clear();
                                          addressController.clear();
                                          showAddForm = false;
                                        });
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AeroColors.amber,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text('Save'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        setState(() => showAddForm = false),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AeroColors.grey,
                                      side: const BorderSide(
                                        color: AeroColors.divider,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text('Cancel'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => setState(() => showAddForm = true),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add new address'),
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
                'SAVED ADDRESSES',
                style: TextStyle(
                  fontSize: 11,
                  color: AeroColors.amber,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'Pickup locations',
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

  Widget _buildAddField(
    TextEditingController ctrl,
    String hint,
    IconData icon,
  ) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AeroColors.grey, fontSize: 13),
        prefixIcon: Icon(icon, color: AeroColors.grey, size: 18),
        filled: true,
        fillColor: AeroColors.navy,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AeroColors.divider, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AeroColors.divider, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AeroColors.amber, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        isDense: true,
      ),
    );
  }
}
