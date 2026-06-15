import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';
import 'package:aerocrew/screens/shared/in_app_chat_screen.dart';

class PoolmatesScreen extends StatelessWidget {
  final String flightNumber;
  final String flightDate;

  const PoolmatesScreen({
    super.key,
    this.flightNumber = 'AK6101',
    this.flightDate = 'Mon 16 Jun',
  });

  final List<Map<String, dynamic>> poolmates = const [
    {
      'name': 'Siti Nabilah',
      'airline': 'AirAsia',
      'zone': 'Ara Damansara',
      'pickupTime': '03:20',
      'tripCount': 14,
      'rating': 4.9,
      'initials': 'SN',
      'color': 0xFF378ADD,
    },
    {
      'name': 'Razif Azman',
      'airline': 'AirAsia',
      'zone': 'Subang Jaya',
      'pickupTime': '03:40',
      'tripCount': 8,
      'rating': 4.7,
      'initials': 'RA',
      'color': 0xFF1D9E75,
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
            _buildFlightInfo(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: poolmates.length,
                itemBuilder: (context, i) =>
                    _buildPoolmateCard(context, poolmates[i]),
              ),
            ),
            _buildGroupChatButton(context),
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
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('POOLMATES',
                  style: TextStyle(
                      fontSize: 11,
                      color: AeroColors.amber,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1)),
              Text('$flightNumber · $flightDate',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ],
          ),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AeroColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('${poolmates.length} crew',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AeroColors.success)),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightInfo() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AeroColors.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AeroColors.amber.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Row(
        children: const [
          Icon(Icons.people, color: AeroColors.amber, size: 16),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'You\'re sharing a van with these crew members. Van picks you up first.',
              style: TextStyle(
                  fontSize: 12, color: AeroColors.amber, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoolmateCard(
      BuildContext context, Map<String, dynamic> mate) {
    final color = Color(mate['color'] as int);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AeroColors.navyCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AeroColors.divider, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(mate['initials'] as String,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: color)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mate['name'] as String,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    Text('${mate['airline']} · ${mate['zone']}',
                        style: const TextStyle(
                            fontSize: 12, color: AeroColors.grey)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${mate['rating']} ★',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AeroColors.amber)),
                  Text('${mate['tripCount']} trips',
                      style: const TextStyle(
                          fontSize: 11, color: AeroColors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AeroColors.navy,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.access_time,
                          size: 13, color: AeroColors.grey),
                      const SizedBox(width: 5),
                      Text('Pickup ${mate['pickupTime']}',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AeroColors.greyLight,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => InAppChatScreen(
                              recipientName: mate['name'] as String,
                              recipientInitials:
                                  mate['initials'] as String,
                              recipientColor: color,
                            ))),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: color.withValues(alpha: 0.2), width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          size: 13, color: color),
                      const SizedBox(width: 5),
                      Text('Message',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: color)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupChatButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => InAppChatScreen(
                        recipientName: '$flightNumber Pool Group',
                        recipientInitials: 'GP',
                        recipientColor: AeroColors.amber,
                        isGroup: true,
                      ))),
          icon: const Icon(Icons.group, size: 18),
          label: const Text('Open group chat',
              style:
                  TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AeroColors.amber,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}