import 'package:flutter/material.dart';

class CrewMapScreen extends StatelessWidget {
  final Map<String, dynamic> trip;

  const CrewMapScreen({
    super.key,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Map'),
      ),
      body: Center(
        child: Text(
          'Map screen coming soon\nFlight: ${trip['flight'] ?? ''}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}