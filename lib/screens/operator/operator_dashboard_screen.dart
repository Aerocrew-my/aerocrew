import 'package:aerocrew/screens/operator/active_job_screen.dart';
import 'package:aerocrew/screens/operator/availability_screen.dart';
import 'package:aerocrew/screens/operator/earnings_screen.dart';
import 'package:aerocrew/screens/operator/operator_live_job_screen.dart';
import 'package:aerocrew/screens/operator/operator_notifications_screen.dart';
import 'package:aerocrew/screens/operator/operator_profile_view_screen.dart';
import 'package:aerocrew/screens/operator/operator_trip_history_screen.dart';
import 'package:aerocrew/screens/operator/route_optimizer_screen.dart';
import 'package:aerocrew/theme/aero_theme.dart';
import 'package:aerocrew/widgets/aero_components.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OperatorDashboardScreen extends StatefulWidget {
  const OperatorDashboardScreen({super.key, this.tripRepository});
  final TripRepository? tripRepository;

  @override
  State<OperatorDashboardScreen> createState() =>
      _OperatorDashboardScreenState();
}

class _OperatorDashboardScreenState extends State<OperatorDashboardScreen> {
  int _index = 0;
  String _operatorName = 'Operator';
  bool _acceptingJobs = true;
  bool _loading = true;
  String? _error;
  List<Trip> _typedJobs = const [];
  List<Map<String, dynamic>> get _jobs => _typedJobs.map(legacyTripView).toList(growable: false);
  late final TripRepository _tripRepository;
  StreamSubscription<List<Trip>>? _jobSubscription;

  @override
  void initState() {
    super.initState();
    _tripRepository = widget.tripRepository ?? FirebaseTripRepository(FirebaseFirestore.instance);
    _loadDashboard();
  }

  @override
  void dispose() { _jobSubscription?.cancel(); super.dispose(); }

  Future<void> _loadDashboard() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final profile = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!mounted) return;
      setState(() {
        _operatorName = profile.data()?['name'] as String? ?? 'Operator';
        _acceptingJobs = profile.data()?['isAvailable'] as bool? ?? true;
      });
      await _jobSubscription?.cancel();
      _jobSubscription = _tripRepository.watchOperatorTrips(user.uid).listen((jobs) {
        if (mounted) setState(() { _typedJobs = jobs; _loading = false; _error = null; });
      }, onError: (_) { if (mounted) setState(() { _error = 'Jobs could not be loaded. Check your connection and try again.'; _loading = false; }); });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error =
            'Jobs could not be loaded. Check your connection and try again.';
        _loading = false;
      });
    }
  }

  String get _firstName => _operatorName.trim().split(' ').first;

  Map<String, dynamic>? get _activeJob {
    for (final job in _jobs) {
      if ([
        'accepted',
        'driverEnRoute',
        'driverArrived',
        'boarding',
        'inTransit',
        'arrived',
      ].contains(job['status'])) {
        return job;
      }
    }
    return _jobs.isEmpty ? null : _jobs.first;
  }

  double get _dailyEarnings => _jobs.fold<double>(
    0,
    (total, job) => total + ((job['earnings'] as num?)?.toDouble() ?? 0),
  );

  @override
  Widget build(BuildContext context) {
    final destinations = const [
      NavigationDestination(
        icon: Icon(Icons.work_outline),
        selectedIcon: Icon(Icons.work),
        label: 'Jobs',
      ),
      NavigationDestination(
        icon: Icon(Icons.calendar_month_outlined),
        selectedIcon: Icon(Icons.calendar_month),
        label: 'Schedule',
      ),
      NavigationDestination(
        icon: Icon(Icons.navigation_outlined),
        selectedIcon: Icon(Icons.navigation),
        label: 'Live',
      ),
      NavigationDestination(
        icon: Icon(Icons.payments_outlined),
        selectedIcon: Icon(Icons.payments),
        label: 'Earnings',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Account',
      ),
    ];
    final pages = [_jobsPage(), _schedule(), _live(), _earnings(), _account()];
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 840;
        final content = IndexedStack(index: _index, children: pages);
        return Scaffold(
          body: SafeArea(
            child: useRail
                ? Row(
                    children: [
                      NavigationRail(
                        selectedIndex: _index,
                        onDestinationSelected: (value) =>
                            setState(() => _index = value),
                        labelType: NavigationRailLabelType.all,
                        destinations: destinations
                            .map(
                              (item) => NavigationRailDestination(
                                icon: item.icon,
                                selectedIcon: item.selectedIcon,
                                label: Text(item.label),
                              ),
                            )
                            .toList(),
                      ),
                      VerticalDivider(width: 1, color: context.aero.border),
                      Expanded(child: content),
                    ],
                  )
                : content,
          ),
          bottomNavigationBar: useRail
              ? null
              : NavigationBar(
                  selectedIndex: _index,
                  onDestinationSelected: (value) =>
                      setState(() => _index = value),
                  destinations: destinations,
                ),
        );
      },
    );
  }

  Widget _page({required String title, Widget? action, required Widget child}) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  action ?? const SizedBox.shrink(),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  Widget _jobsPage() => _page(
    title: 'Good day, $_firstName',
    action: IconButton(
      tooltip: 'Notifications',
      onPressed: () => _open(const OperatorNotificationsScreen()),
      icon: const Icon(Icons.notifications_none),
    ),
    child: _loading
        ? const AeroLoadingState(label: 'Loading assigned jobs')
        : _error != null
        ? AeroErrorState(message: _error!, onRetry: _loadDashboard)
        : RefreshIndicator(
            onRefresh: _loadDashboard,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                _availabilityControl(),
                const SizedBox(height: AeroSpacing.section),
                if (_activeJob == null)
                  const AeroEmptyState(
                    icon: Icons.work_outline,
                    title: 'No assigned jobs',
                    message: 'New work will appear here when it is assigned.',
                  )
                else
                  _priorityJob(_activeJob!),
                if (_jobs.length > 1) ...[
                  const SizedBox(height: AeroSpacing.section),
                  const AeroSectionHeader(title: 'Remaining jobs'),
                  const SizedBox(height: AeroSpacing.sm),
                  ..._jobs.skip(1).map(_jobCard),
                ],
                const SizedBox(height: AeroSpacing.section),
                AeroCard(
                  child: Row(
                    children: [
                      Icon(
                        Icons.payments_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Daily earnings',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        'RM ${_dailyEarnings.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
  );

  Widget _availabilityControl() {
    final active =
        _activeJob != null &&
        [
          'accepted',
          'driverEnRoute',
          'driverArrived',
          'arrived',
          'boarding',
          'inTransit',
        ].contains(_activeJob!['status']);
    final label = active
        ? 'On Active Trip'
        : _acceptingJobs
        ? 'Accepting Jobs'
        : 'Unavailable';
    final color = active
        ? context.aero.information
        : _acceptingJobs
        ? context.aero.success
        : context.aero.textSecondary;
    return AeroCard(
      onTap: active ? null : () => _open(const AvailabilityScreen()),
      child: Row(
        children: [
          AeroStatusChip(
            label: label,
            color: color,
            icon: active
                ? Icons.navigation
                : _acceptingJobs
                ? Icons.check_circle_outline
                : Icons.do_not_disturb_on_outlined,
          ),
          const Spacer(),
          if (!active) const Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  Widget _priorityJob(Map<String, dynamic> job) {
    final status = (job['status'] ?? 'confirmed').toString();
    final crewCount =
        (job['crewCount'] ??
                (job['crew'] is List ? (job['crew'] as List).length : 0))
            .toString();
    final stops =
        (job['pickupStopCount'] ??
                (job['crew'] is List ? (job['crew'] as List).length : 0))
            .toString();
    final action = _actionLabel(status);
    return AeroCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                status == 'active' ? 'ACTIVE JOB' : 'NEXT PICKUP',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const Spacer(),
              AeroStatusChip(
                label: _statusLabel(status),
                color: _statusColor(status),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${job['date'] ?? 'Date pending'} · ${job['pickupTime'] ?? 'Time pending'}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '${job['zone'] ?? 'Pickup zone'} → ${job['terminal'] ?? job['airport'] ?? 'Airport terminal'}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 20,
            runSpacing: 16,
            children: [
              _metric(Icons.groups_outlined, crewCount, 'Crew'),
              _metric(Icons.pin_drop_outlined, stops, 'Pickup stops'),
              _metric(
                Icons.flight_land,
                (job['airport'] ?? 'Pending').toString(),
                'Destination',
              ),
              _metric(
                Icons.schedule,
                (job['arrivalTime'] ?? job['flightTime'] ?? 'Pending')
                    .toString(),
                'Required arrival',
              ),
            ],
          ),
          if (job['delayAlert'] != null) ...[
            const SizedBox(height: 16),
            AeroStatusChip(
              label: job['delayAlert'].toString(),
              color: context.aero.warning,
              icon: Icons.warning_amber,
            ),
          ],
          const SizedBox(height: 20),
          AeroButton(
            label: action,
            icon: Icons.navigation_outlined,
            expand: true,
            onPressed: () => _performNextAction(job),
          ),
        ],
      ),
    );
  }

  Widget _metric(IconData icon, String value, String label) => SizedBox(
    width: 132,
    child: Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _jobCard(Map<String, dynamic> job) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: AeroCard(
      onTap: () => _open(ActiveJobScreen(job: job)),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.aero.blueSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.route_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${job['pickupTime'] ?? 'Time pending'} · ${job['zone'] ?? 'Pickup'}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${job['crewCount'] ?? 0} crew · ${job['airport'] ?? 'Airport pending'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    ),
  );

  Widget _schedule() => _page(
    title: 'Schedule',
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        AeroCard(
          onTap: () => _open(const AvailabilityScreen()),
          child: const AeroListTile(
            icon: Icons.event_available_outlined,
            title: 'Availability',
            subtitle: 'Set working days and blocked times',
          ),
        ),
        const SizedBox(height: 12),
        AeroCard(
          onTap: () => _open(const OperatorTripHistoryScreen()),
          child: const AeroListTile(
            icon: Icons.history,
            title: 'Completed schedule',
            subtitle: 'Review previous operator trips',
          ),
        ),
        if (_jobs.isNotEmpty) ...[
          const SizedBox(height: 24),
          const AeroSectionHeader(title: 'Assigned jobs'),
          const SizedBox(height: 12),
          ..._jobs.map(_jobCard),
        ],
      ],
    ),
  );

  Widget _live() {
    final active = _activeJob;
    return _page(
      title: 'Live operations',
      child: active == null
          ? const AeroEmptyState(
              icon: Icons.navigation_outlined,
              title: 'No live trip',
              message:
                  'An active route will appear here with stop and incident status.',
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _priorityJob(active),
                const SizedBox(height: 12),
                AeroCard(
                  onTap: () => _open(RouteOptimizerScreen(job: active)),
                  child: const AeroListTile(
                    icon: Icons.alt_route,
                    title: 'Review route and pickup stops',
                  ),
                ),
              ],
            ),
    );
  }

  Widget _earnings() => _page(
    title: 'Earnings',
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        AeroCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assigned job value',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'RM ${_dailyEarnings.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 20),
              AeroButton(
                label: 'View earnings',
                expand: true,
                onPressed: () => _open(const EarningsScreen()),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _account() => _page(
    title: 'Account',
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        AeroCard(
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: context.aero.blueSurface,
                foregroundColor: Theme.of(context).colorScheme.primary,
                child: Text(_firstName.characters.first.toUpperCase()),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _operatorName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AeroCard(
          onTap: () => _open(const OperatorProfileViewScreen()),
          child: const AeroListTile(
            icon: Icons.manage_accounts_outlined,
            title: 'Operator account',
            subtitle: 'Profile, vehicles, documents, and support',
          ),
        ),
      ],
    ),
  );

  String _statusLabel(String status) => switch (status) {
    'active' || 'en_route' => 'On Active Trip',
    'arrived' => 'At pickup',
    'boarding' => 'Boarding',
    _ => 'Confirmed',
  };

  Color _statusColor(String status) => switch (status) {
    'active' ||
    'en_route' ||
    'arrived' ||
    'boarding' => context.aero.information,
    _ => context.aero.success,
  };

  void _openJob(Map<String, dynamic> job, String status) {
    if (['accepted', 'driverEnRoute', 'driverArrived', 'arrived', 'boarding', 'inTransit'].contains(status)) {
      _open(OperatorLiveJobScreen(job: job));
    } else {
      _open(ActiveJobScreen(job: job));
    }
  }

  String _actionLabel(String status) => switch (status) {
    'assigned' => 'Accept job', 'accepted' => 'Start route', 'driverEnRoute' => 'Mark driver arrived',
    'driverArrived' => 'Begin boarding', 'boarding' => 'Begin airport journey', 'inTransit' => 'Mark airport arrival',
    'arrived' => 'Complete trip', _ => 'View job',
  };

  Future<void> _performNextAction(Map<String, dynamic> view) async {
    final trip = _typedJobs.where((item) => item.id == view['id']).firstOrNull;
    final user = FirebaseAuth.instance.currentUser;
    if (trip == null || user == null) return;
    final next = TripTransitions.operatorNext(trip.status);
    if (next == null) { _openJob(view, trip.status.name); return; }
    try { await _tripRepository.transitionOperatorTrip(trip: trip, operatorId: user.uid, next: next); }
    catch (_) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('The job status could not be updated.'))); }
  }

  Future<void> _open(Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
}

extension _FirstOrNull<T> on Iterable<T> { T? get firstOrNull => isEmpty ? null : first; }
import 'dart:async';

import 'package:aerocrew/features/trips/data/firebase_trip_repository.dart';
import 'package:aerocrew/features/trips/data/trip_repository.dart';
import 'package:aerocrew/features/trips/domain/trip.dart';
import 'package:aerocrew/features/trips/domain/trip_transitions.dart';
import 'package:aerocrew/features/trips/presentation/legacy_trip_adapter.dart';
