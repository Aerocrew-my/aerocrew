import 'package:aerocrew/features/trip_execution/domain/execution_trip.dart';
import 'package:flutter/material.dart';

/// Status-only until the backend provides real vehicle coordinates and ETA.
class LiveTrackingScreen extends StatelessWidget {
  const LiveTrackingScreen({super.key, required this.trip});
  final Map<String, dynamic> trip;
  @override
  Widget build(BuildContext context) {
    final status = trip['status']?.toString() ?? '';
    final progress = trip['poolProgress'];
    return Scaffold(
      appBar: AppBar(title: const Text('Trip status')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(
            Icons.route_outlined,
            size: 56,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            crewStatusLabel(status),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Text(
            'Live vehicle location and ETA are not available yet. Updates shown here are confirmed trip events.',
            textAlign: TextAlign.center,
          ),
          if (progress is Map) ...[
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Pickup progress: ${progress['resolved'] ?? 0} of ${progress['total'] ?? 0}',
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Service: ${trip['serviceType'] ?? 'Scheduled transport'}',
                  ),
                  Text(
                    'Operator: ${trip['operatorName'] ?? 'Assignment pending'}',
                  ),
                  Text('Driver: ${trip['driverName'] ?? 'Not provided'}'),
                  Text(
                    'Vehicle: ${[trip['vehicleDescription'], trip['vehiclePlate']].whereType<String>().join(' · ')}',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
