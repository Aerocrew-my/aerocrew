import 'package:aerocrew/features/earnings/data/api_operator_earnings_repository.dart';
import 'package:aerocrew/features/earnings/data/operator_earnings_repository.dart';
import 'package:aerocrew/features/earnings/domain/operator_earning.dart';
import 'package:flutter/material.dart';

class OperatorTripHistoryScreen extends StatelessWidget {
  const OperatorTripHistoryScreen({super.key, this.repository});
  final OperatorEarningsRepository? repository;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Completed trips')),
    body: FutureBuilder<List<OperatorEarning>>(
      future: (repository ?? ApiOperatorEarningsRepository()).getEarnings(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Trip history could not be loaded.'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.isEmpty) {
          return const Center(child: Text('No completed trips yet.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final item = snapshot.data![index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text('Trip ${item.tripId}'),
                subtitle: Text(
                  '${_date(item.completedAt)} · Completed\n${_settlement(item.settlementStatus)}',
                ),
                isThreeLine: true,
                trailing: Text(
                  'RM ${(item.operatorPayableMinor / 100).toStringAsFixed(2)}',
                ),
              ),
            );
          },
        );
      },
    ),
  );
  static String _date(DateTime? value) => value == null
      ? 'Date unavailable'
      : '${value.toLocal().day}/${value.toLocal().month}/${value.toLocal().year}';
  static String _settlement(String value) => value == 'settled'
      ? 'Settled'
      : value == 'ready'
      ? 'Ready for settlement'
      : 'Settlement pending';
}
