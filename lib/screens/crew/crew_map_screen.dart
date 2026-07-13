import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';

class CrewMapScreen extends StatelessWidget {
  final Map<String, dynamic> trip;

  const CrewMapScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AeroColors.navy,
      appBar: AppBar(
        backgroundColor: AeroColors.navy,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Trip Map',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// MAP CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: AeroDecoration.darkCard,
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AeroColors.navy.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),

                      Icon(
                        Icons.map_outlined,
                        size: 160,
                        color: AeroColors.grey.withValues(alpha: 0.15),
                      ),

                      Positioned(
                        left: 80,
                        top: 90,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AeroColors.amber,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Icon(
                            Icons.local_taxi,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      Positioned(
                        right: 90,
                        top: 70,
                        child: Icon(
                          Icons.location_on,
                          color: AeroColors.success,
                          size: 42,
                        ),
                      ),

                      const Icon(
                        Icons.route,
                        color: AeroColors.amber,
                        size: 100,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Live Trip Tracking",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    trip['flight'] ?? 'No Flight Assigned',
                    style: const TextStyle(
                      color: AeroColors.amber,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// STATUS CARD
            Container(
              padding: const EdgeInsets.all(18),
              decoration: AeroDecoration.darkCard,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AeroColors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.schedule, color: AeroColors.amber),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Waiting for route activation',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Driver location and ETA will appear once the operator starts the trip.',
                          style: TextStyle(
                            color: AeroColors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// TRIP INFO CARD
            Container(
              padding: const EdgeInsets.all(18),
              decoration: AeroDecoration.darkCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Trip Information",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 16),

                  _infoRow(
                    Icons.flight,
                    "Flight",
                    trip['flight']?.toString() ?? '-',
                  ),

                  const SizedBox(height: 14),

                  _infoRow(Icons.location_city, "Status", "Pending Dispatch"),

                  const SizedBox(height: 14),

                  _infoRow(Icons.directions_car, "Driver", "Not Assigned"),

                  const SizedBox(height: 14),

                  _infoRow(Icons.access_time, "ETA", "-- min"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AeroColors.amber, size: 18),

        const SizedBox(width: 10),

        Text("$label:", style: const TextStyle(color: AeroColors.grey)),

        const Spacer(),

        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
