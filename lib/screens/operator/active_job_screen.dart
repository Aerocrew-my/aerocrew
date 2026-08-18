import 'package:aerocrew/features/trip_execution/data/api_trip_execution_repository.dart';
import 'package:aerocrew/features/trip_execution/data/trip_execution_repository.dart';
import 'package:aerocrew/features/trip_execution/domain/execution_trip.dart';
import 'package:flutter/material.dart';

class ActiveJobScreen extends StatefulWidget {
  const ActiveJobScreen({super.key, required this.tripId, this.repository});
  final String tripId;
  final TripExecutionRepository? repository;
  @override
  State<ActiveJobScreen> createState() => _ActiveJobScreenState();
}

class _ActiveJobScreenState extends State<ActiveJobScreen> {
  late final TripExecutionRepository _repository =
      widget.repository ?? ApiTripExecutionRepository();
  ExecutionTrip? _trip;
  String? _error;
  bool _loading = true, _submitting = false;
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final trip = await _repository.getTrip(widget.tripId);
      if (mounted) setState(() => _trip = trip);
    } on TripExecutionException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await action();
      await _refresh();
      if (mounted && _trip?.isCompleted == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Trip completed.')));
        Navigator.pop(context, true);
      }
    } on TripExecutionException catch (e) {
      if (e.refreshRequired) await _refresh();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Active assignment')),
    body: _loading && _trip == null
        ? const Center(child: CircularProgressIndicator())
        : _error != null && _trip == null
        ? _message(_error!, retry: true)
        : RefreshIndicator(onRefresh: _refresh, child: _content(_trip!)),
  );
  Widget _message(String text, {bool retry = false}) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text),
        if (retry)
          TextButton(onPressed: _refresh, child: const Text('Try again')),
      ],
    ),
  );
  Widget _content(ExecutionTrip trip) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        _service(trip.serviceType),
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 8),
      Text(
        '${trip.direction ?? 'Scheduled service'} · ${trip.airport ?? 'Airport'}${trip.terminal == null ? '' : ' ${trip.terminal}'}',
      ),
      const SizedBox(height: 16),
      _details(trip),
      const SizedBox(height: 20),
      Text(
        'Status: ${_status(trip.status)}',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      if (trip.isPool) ...[
        const SizedBox(height: 20),
        Text('Pickup Sequence', style: Theme.of(context).textTheme.titleLarge),
        Text('${trip.resolvedStops} of ${trip.stops.length} stops resolved'),
        const SizedBox(height: 8),
        ...trip.stops.map((s) => _stopCard(trip, s)),
      ],
      const SizedBox(height: 20),
      if (_submitting) const LinearProgressIndicator(),
      if (!_submitting) ..._actions(trip),
    ],
  );
  Widget _details(ExecutionTrip trip) {
    final vehicle = [
      trip.vehicleDescription,
      trip.vehiclePlate,
    ].whereType<String>().join(' · ');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pickup: ${_date(trip.scheduledPickupAt)}'),
            Text('Service window ends: ${_date(trip.requiredArrivalAt)}'),
            Text('Vehicle: ${vehicle.isEmpty ? 'Not provided' : vehicle}'),
            Text('Driver: ${trip.driverName ?? 'Not provided'}'),
          ],
        ),
      ),
    );
  }

  Widget _stopCard(ExecutionTrip trip, ExecutionStop stop) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stop ${stop.sequence + 1}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(stop.address ?? 'Pickup location available from dispatch'),
          Text('${_date(stop.scheduledAt)} · ${_stopStatus(stop.status)}'),
          if (!_submitting && stop.status == ExecutionStopStatus.pending)
            Wrap(
              spacing: 8,
              children: [
                FilledButton(
                  onPressed: () =>
                      _run(() => _repository.markStopArrived(trip.id, stop.id)),
                  child: const Text('Arrived'),
                ),
                TextButton(
                  onPressed: () => _exception(trip, stop),
                  child: const Text('No Show / Skip Pickup'),
                ),
              ],
            ),
          if (!_submitting && stop.status == ExecutionStopStatus.arrived)
            Wrap(
              spacing: 8,
              children: [
                FilledButton(
                  onPressed: () =>
                      _run(() => _repository.markStopOnboard(trip.id, stop.id)),
                  child: const Text('Crew Onboard'),
                ),
                TextButton(
                  onPressed: () => _exception(trip, stop),
                  child: const Text('No Show / Skip Pickup'),
                ),
              ],
            ),
        ],
      ),
    ),
  );
  List<Widget> _actions(ExecutionTrip t) => switch (t.status) {
    'accepted' => [
      _button('Start Pickup', () => _repository.startPickup(t.id)),
    ],
    'driverEnRoute' => [
      _button('Arrived at Pickup', () => _repository.arrivePickup(t.id)),
    ],
    'driverArrived' when !t.isPool => [
      _button('Crew Onboard', () => _repository.markCrewOnboard(t.id)),
    ],
    'driverArrived' when t.isPool && t.allStopsResolved => [
      _button('Proceed to Airport', () => _repository.startAirportLeg(t.id)),
    ],
    'boarding' => [
      _button('Proceed to Airport', () => _repository.startAirportLeg(t.id)),
    ],
    'inTransit' || 'arrived' => [
      _button('Complete Trip', () => _repository.completeTrip(t.id)),
    ],
    _ => [],
  };
  Widget _button(String label, Future<void> Function() action) => SizedBox(
    width: double.infinity,
    child: FilledButton(onPressed: () => _run(action), child: Text(label)),
  );
  Future<void> _exception(ExecutionTrip trip, ExecutionStop stop) async {
    StopExceptionReason reason = StopExceptionReason.crewNoShow;
    final note = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('No Show / Skip Pickup'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField(
                initialValue: reason,
                items: const [
                  DropdownMenuItem(
                    value: StopExceptionReason.crewNoShow,
                    child: Text('Crew no show'),
                  ),
                  DropdownMenuItem(
                    value: StopExceptionReason.crewCancelled,
                    child: Text('Crew cancelled'),
                  ),
                  DropdownMenuItem(
                    value: StopExceptionReason.unsafePickup,
                    child: Text('Unsafe pickup'),
                  ),
                  DropdownMenuItem(
                    value: StopExceptionReason.unableToAccess,
                    child: Text('Unable to access'),
                  ),
                  DropdownMenuItem(
                    value: StopExceptionReason.operatorIssue,
                    child: Text('Operator issue'),
                  ),
                  DropdownMenuItem(
                    value: StopExceptionReason.other,
                    child: Text('Other'),
                  ),
                ],
                onChanged: (v) => setDialogState(() => reason = v!),
              ),
              TextField(
                controller: note,
                maxLength: 200,
                decoration: InputDecoration(
                  labelText: reason == StopExceptionReason.other
                      ? 'Note (required)'
                      : 'Note (optional)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                context,
                reason != StopExceptionReason.other ||
                    note.text.trim().isNotEmpty,
              ),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true) {
      await _run(
        () => _repository.markStopException(
          trip.id,
          stop.id,
          reason,
          detail: note.text,
        ),
      );
    }
    note.dispose();
  }

  String _service(String s) => switch (s) {
    'aeroPool' => 'AeroPool',
    'aeroSolo' => 'AeroSolo',
    'aeroFlex' => 'AeroFlex',
    _ => s,
  };
  String _status(String s) => switch (s) {
    'accepted' => 'Ready to start',
    'driverEnRoute' => 'On the way to pickup',
    'driverArrived' => 'At pickup',
    'boarding' => 'Crew onboard',
    'inTransit' => 'En route to destination',
    'arrived' => 'At destination',
    'completed' => 'Completed',
    _ => 'Assignment confirmed',
  };
  String _stopStatus(ExecutionStopStatus s) => switch (s) {
    ExecutionStopStatus.noShow => 'No show',
    _ => s.name,
  };
  String _date(DateTime? value) => value == null
      ? 'Not provided'
      : '${value.toLocal().day}/${value.toLocal().month}/${value.toLocal().year} ${value.toLocal().hour.toString().padLeft(2, '0')}:${value.toLocal().minute.toString().padLeft(2, '0')}';
}
