import 'package:aerocrew/features/earnings/data/api_operator_earnings_repository.dart';
import 'package:aerocrew/features/earnings/data/operator_earnings_repository.dart';
import 'package:aerocrew/features/earnings/domain/operator_earning.dart';
import 'package:flutter/material.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key, this.repository});
  final OperatorEarningsRepository? repository;
  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  late Future<List<OperatorEarning>> _future;
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _future =
      (widget.repository ?? ApiOperatorEarningsRepository()).getEarnings();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Earnings')),
    body: FutureBuilder<List<OperatorEarning>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _message('Earnings could not be loaded. Pull to try again.');
        }
        final values = snapshot.data!;
        return RefreshIndicator(
          onRefresh: () async {
            setState(_load);
            await _future;
          },
          child: values.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 220),
                    Center(child: Text('No completed-trip earnings yet.')),
                  ],
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            const Text('Operator payable'),
                            Text(
                              _money(
                                values.fold<int>(
                                  0,
                                  (sum, item) =>
                                      sum + item.operatorPayableMinor,
                                ),
                              ),
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            Text('${values.length} completed trips'),
                          ],
                        ),
                      ),
                    ),
                    ...values.map(
                      (item) => Card(
                        child: ListTile(
                          title: Text('Trip ${item.tripId}'),
                          subtitle: Text(
                            '${_date(item.completedAt)} · Gross ${_money(item.bookingValueMinor)}',
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(_money(item.operatorPayableMinor)),
                              Text(
                                _settlement(item.settlementStatus),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    ),
  );
  Widget _message(String text) => Center(child: Text(text));
  static String _money(int minor) => 'RM ${(minor / 100).toStringAsFixed(2)}';
  static String _date(DateTime? value) => value == null
      ? 'Completion date unavailable'
      : '${value.toLocal().day}/${value.toLocal().month}/${value.toLocal().year}';
  static String _settlement(String value) => switch (value) {
    'settled' => 'Settled',
    'ready' => 'Ready for settlement',
    _ => 'Settlement pending',
  };
}
