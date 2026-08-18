import 'package:flutter/material.dart';

class RouteOptimizerScreen extends StatelessWidget {
  const RouteOptimizerScreen({super.key, required this.job});
  final Map<String, dynamic> job;
  @override
  Widget build(BuildContext context) {
    final stops = (job['stops'] as List? ?? const []).whereType<Map>().toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Pickup Sequence')),
      body: stops.isEmpty
          ? const Center(child: Text('No pickup stops are available.'))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: stops.length,
              itemBuilder: (context, index) {
                final stop = stops[index];
                final address = stop['address']?.toString().trim();
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(
                      address?.isNotEmpty == true
                          ? address!
                          : 'Pickup stop ${index + 1}',
                    ),
                    subtitle: Text(
                      stop['scheduledAt']?.toString() ??
                          'Scheduled time not provided',
                    ),
                    trailing: Text(stop['status']?.toString() ?? 'pending'),
                  ),
                );
              },
            ),
    );
  }
}
