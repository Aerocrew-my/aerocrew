import 'package:aerocrew/features/offers/data/operator_offer_repository.dart';
import 'package:aerocrew/features/offers/domain/operator_offer.dart';
import 'package:aerocrew/features/operations/domain/operational_models.dart';
import 'package:aerocrew/features/trips/presentation/legacy_trip_adapter.dart';
import 'package:aerocrew/theme/aero_theme.dart';
import 'package:aerocrew/widgets/aero_components.dart';
import 'package:flutter/material.dart';

typedef EligibleVehicleLoader = Future<List<Vehicle>> Function(int capacity);

class OperatorOfferScreen extends StatefulWidget {
  const OperatorOfferScreen({
    super.key,
    required this.offer,
    required this.repository,
    required this.loadVehicles,
  });
  final OperatorOffer offer;
  final OperatorOfferRepository repository;
  final EligibleVehicleLoader loadVehicles;

  @override
  State<OperatorOfferScreen> createState() => _OperatorOfferScreenState();
}

class _OperatorOfferScreenState extends State<OperatorOfferScreen> {
  List<Vehicle>? _vehicles;
  String? _vehicleId;
  String? _error;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    try {
      final vehicles = await widget.loadVehicles(widget.offer.crewCount);
      if (!mounted) return;
      setState(() {
        _vehicles = vehicles;
        _vehicleId = vehicles.length == 1 ? vehicles.first.id : null;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Eligible vehicles could not be loaded.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;
    return Scaffold(
      appBar: AppBar(
        title: Text(offer.isPool ? 'AeroPool offer' : 'Trip offer'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AeroSpacing.screen),
        children: [
          AeroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AeroStatusChip(
                  label: offer.isPool
                      ? 'AeroPool'
                      : _serviceName(offer.serviceType),
                  color: Theme.of(context).colorScheme.primary,
                  icon: offer.isPool
                      ? Icons.groups_outlined
                      : Icons.route_outlined,
                ),
                const SizedBox(height: 16),
                Text(
                  '${tripDate(offer.pickupAt)} · ${tripTime(offer.pickupAt)}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '${offer.direction ?? 'Airport transfer'} · ${offer.airport}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                _line('Crew', '${offer.crewCount}'),
                _line(
                  'Service window',
                  '${tripTime(offer.pickupAt)}–${tripTime(offer.requiredArrivalAt)}',
                ),
                _line(
                  'Offer expires',
                  '${tripDate(offer.expiresAt)} · ${tripTime(offer.expiresAt)}',
                ),
                if (offer.isPool)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'Compatible pickups are grouped by the server. Private crew details are not included.',
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Vehicle and driver',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'You are assigned as the driver for this phase. Select an eligible operator vehicle.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          if (_vehicles == null && _error == null) const AeroLoadingState(),
          if (_vehicles?.isEmpty == true)
            const AeroEmptyState(
              icon: Icons.no_transfer_outlined,
              title: 'No eligible vehicle',
              message:
                  'No active, verified vehicle has enough capacity for this offer.',
            ),
          if (_vehicles?.isNotEmpty == true)
            DropdownButtonFormField<String>(
              key: const Key('offer_vehicle_selector'),
              initialValue: _vehicleId,
              decoration: const InputDecoration(labelText: 'Eligible vehicle'),
              items: _vehicles!
                  .map(
                    (vehicle) => DropdownMenuItem(
                      value: vehicle.id,
                      child: Text(
                        '${vehicle.makeModel} · ${vehicle.plate} · ${vehicle.capacity} seats',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: _submitting
                  ? null
                  : (value) => setState(() => _vehicleId = value),
            ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: context.aero.danger)),
          ],
          const SizedBox(height: 24),
          AeroButton(
            label: _submitting ? 'Confirming…' : 'Accept and assign',
            icon: Icons.check_circle_outline,
            expand: true,
            onPressed: _submitting || offer.isExpired || _vehicleId == null
                ? null
                : _accept,
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _submitting || !offer.isPending ? null : _decline,
            child: const Text('Decline offer'),
          ),
        ],
      ),
    );
  }

  Widget _line(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(value),
      ],
    ),
  );

  Future<void> _accept() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await widget.repository.accept(widget.offer.id, vehicleId: _vehicleId!);
      if (mounted) Navigator.pop(context, true);
    } on OperatorOfferException catch (error) {
      if (mounted) {
        setState(() {
          _error = error.message;
          _submitting = false;
        });
      }
    }
  }

  Future<void> _decline() async {
    final reason = await showModalBottomSheet<OfferDeclineReason>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: OfferDeclineReason.values
              .map(
                (reason) => ListTile(
                  title: Text(_declineName(reason)),
                  onTap: () => Navigator.pop(context, reason),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (reason == null || !mounted) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await widget.repository.decline(widget.offer.id, reason);
      if (mounted) Navigator.pop(context, true);
    } on OperatorOfferException catch (error) {
      if (mounted) {
        setState(() {
          _error = error.message;
          _submitting = false;
        });
      }
    }
  }
}

String _serviceName(String value) => switch (value) {
  'aeroPool' => 'AeroPool',
  'aeroSolo' => 'AeroSolo',
  _ => 'AeroFlex',
};

String _declineName(OfferDeclineReason reason) => switch (reason) {
  OfferDeclineReason.unavailable => 'Unavailable',
  OfferDeclineReason.capacity => 'Insufficient capacity',
  OfferDeclineReason.schedule => 'Schedule conflict',
  OfferDeclineReason.other => 'Other',
};
