import 'dart:async';

import 'package:aerocrew/features/trips/data/firebase_trip_repository.dart';
import 'package:aerocrew/features/trips/data/trip_repository.dart';
import 'package:aerocrew/features/trips/domain/trip.dart';
import 'package:aerocrew/features/trips/presentation/legacy_trip_adapter.dart';
import 'package:aerocrew/screens/crew/billing_screen.dart';
import 'package:aerocrew/screens/crew/crew_map_screen.dart';
import 'package:aerocrew/screens/crew/crew_profile_view_screen.dart';
import 'package:aerocrew/screens/crew/notifications_screen.dart';
import 'package:aerocrew/screens/crew/roster_calendar_screen.dart';
import 'package:aerocrew/screens/crew/roster_upload_screen.dart';
import 'package:aerocrew/screens/crew/settings_screen.dart';
import 'package:aerocrew/screens/crew/trip_history_screen.dart';
import 'package:aerocrew/screens/crew/wallet_screen.dart';
import 'package:aerocrew/theme/aero_theme.dart';
import 'package:aerocrew/widgets/aero_components.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CrewDashboardScreen extends StatefulWidget {
  const CrewDashboardScreen({super.key, this.tripRepository});
  final TripRepository? tripRepository;

  @override
  State<CrewDashboardScreen> createState() => _CrewDashboardScreenState();
}

class _CrewDashboardScreenState extends State<CrewDashboardScreen> {
  int _index = 0;
  String _userName = 'Crew';
  bool _isVerified = false;
  bool _loading = true;
  String? _error;
  List<Trip> _trips = const [];
  late final TripRepository _tripRepository;
  StreamSubscription<List<Trip>>? _tripSubscription;

  @override
  void initState() {
    super.initState();
    _tripRepository =
        widget.tripRepository ??
        FirebaseTripRepository(FirebaseFirestore.instance);
    _loadDashboard();
  }

  @override
  void dispose() {
    _tripSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadDashboard() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final profile = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!mounted) return;
      setState(() {
        _userName = profile.data()?['name'] as String? ?? 'Crew';
        _isVerified = profile.data()?['status'] == 'verified';
      });
      await _tripSubscription?.cancel();
      _tripSubscription = _tripRepository
          .watchCrewTrips(user.uid)
          .listen(
            (trips) {
              if (mounted)
                setState(() {
                  _trips = trips;
                  _loading = false;
                  _error = null;
                });
            },
            onError: (_) {
              if (mounted)
                setState(() {
                  _error =
                      'Trips could not be loaded. Check your connection and try again.';
                  _loading = false;
                });
            },
          );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error =
            'Trips could not be loaded. Check your connection and try again.';
        _loading = false;
      });
    }
  }

  String get _firstName => _userName.trim().split(' ').first;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final destinations = const [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Home',
      ),
      NavigationDestination(
        icon: Icon(Icons.calendar_month_outlined),
        selectedIcon: Icon(Icons.calendar_month),
        label: 'Roster',
      ),
      NavigationDestination(
        icon: Icon(Icons.route_outlined),
        selectedIcon: Icon(Icons.route),
        label: 'Trips',
      ),
      NavigationDestination(
        icon: Icon(Icons.account_balance_wallet_outlined),
        selectedIcon: Icon(Icons.account_balance_wallet),
        label: 'Wallet',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];
    final pages = [_home(), _roster(), _tripsPage(), _wallet(), _profile()];

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

  Widget _home() {
    return _page(
      title: '$_greeting, $_firstName',
      action: IconButton(
        tooltip: 'Notifications',
        onPressed: () => _open(const NotificationsScreen()),
        icon: const Icon(Icons.notifications_none),
      ),
      child: _loading
          ? const AeroLoadingState(label: 'Loading your trips')
          : _error != null
          ? AeroErrorState(message: _error!, onRetry: _loadDashboard)
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  if (_isVerified)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: AeroStatusChip(
                          label: 'Verified crew account',
                          color: context.aero.success,
                          icon: Icons.verified_outlined,
                        ),
                      ),
                    ),
                  if (_trips.isEmpty)
                    AeroEmptyState(
                      icon: Icons.flight_takeoff_outlined,
                      title: 'No transport planned',
                      message:
                          'Upload a roster to create your upcoming transport requirements.',
                      action: AeroButton(
                        label: 'Upload roster',
                        icon: Icons.upload_file,
                        onPressed: () => _open(const RosterUploadScreen()),
                      ),
                    )
                  else ...[
                    _nextPickupCard(_trips.first),
                    const SizedBox(height: AeroSpacing.section),
                    AeroSectionHeader(
                      title: 'Upcoming trips',
                      action: TextButton(
                        onPressed: () => setState(() => _index = 2),
                        child: const Text('View all'),
                      ),
                    ),
                    const SizedBox(height: AeroSpacing.sm),
                    ..._trips.skip(1).take(3).map(_tripCard),
                  ],
                  const SizedBox(height: AeroSpacing.section),
                  const AeroSectionHeader(title: 'Roster status'),
                  const SizedBox(height: AeroSpacing.sm),
                  AeroCard(
                    onTap: () => setState(() => _index = 1),
                    child: Row(
                      children: [
                        Icon(
                          Icons.fact_check_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Review your current roster'),
                              SizedBox(height: 2),
                              Text(
                                'Confirm duties before transport is generated.',
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _nextPickupCard(Trip trip) {
    final confirmed =
        trip.assignmentStatus == AssignmentStatus.assigned ||
        trip.assignmentStatus == AssignmentStatus.accepted;
    final pickup = tripTime(trip.scheduledPickupAt);
    final date = tripDate(trip.scheduledPickupAt);
    final origin = trip.pickupStops.isEmpty
        ? 'Pickup location pending'
        : trip.pickupStops.first.address;
    final destination = trip.terminal ?? trip.airport;
    final driver = trip.driverName ?? 'Driver pending';
    final vehicle = trip.vehicleDescription ?? 'Vehicle pending';
    final plate = trip.vehiclePlate ?? 'Plate pending';

    return AeroCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'NEXT PICKUP',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const Spacer(),
              AeroStatusChip(
                label: confirmed ? 'Driver confirmed' : 'Confirmation pending',
                color: confirmed
                    ? context.aero.success
                    : context.aero.information,
                icon: confirmed ? Icons.check_circle_outline : Icons.schedule,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$date · $pickup',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Pickup in ${_countdown(trip.scheduledPickupAt)}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: context.aero.textSecondary),
          ),
          const SizedBox(height: 20),
          _routeLine(origin, destination),
          const SizedBox(height: 20),
          Divider(color: context.aero.border),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: context.aero.blueSurface,
                foregroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(Icons.person_outline),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '$vehicle · $plate',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AeroButton(
            label: confirmed ? 'View trip' : 'View request',
            icon: Icons.arrow_forward,
            expand: true,
            onPressed: () => _open(CrewMapScreen(trip: trip)),
          ),
        ],
      ),
    );
  }

  String _countdown(DateTime pickup) {
    final value = pickup.difference(DateTime.now());
    if (value.isNegative) return 'now';
    if (value.inHours > 0)
      return '${value.inHours}h ${value.inMinutes.remainder(60)}m';
    return '${value.inMinutes}m';
  }

  Widget _routeLine(String origin, String destination) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Column(
        children: [
          Icon(
            Icons.radio_button_checked,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          Container(width: 2, height: 30, color: context.aero.border),
          Icon(
            Icons.flight_land,
            size: 18,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ],
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(origin, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 22),
            Text(destination, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    ],
  );

  Widget _tripCard(Trip trip) => Padding(
    padding: const EdgeInsets.only(bottom: AeroSpacing.sm),
    child: AeroCard(
      onTap: () => _open(CrewMapScreen(trip: trip)),
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
              Icons.flight_takeoff,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${tripDate(trip.scheduledPickupAt)} · ${tripTime(trip.scheduledPickupAt)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${trip.pickupStops.isEmpty ? 'Pickup' : trip.pickupStops.first.address} → ${trip.terminal ?? trip.airport}',
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

  Widget _roster() => _page(
    title: 'Roster',
    child: ListView(
      padding: const EdgeInsets.all(AeroSpacing.screen),
      children: [
        Text(
          'Turn confirmed duties into transport requirements.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: context.aero.textSecondary),
        ),
        const SizedBox(height: AeroSpacing.section),
        AeroCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.document_scanner_outlined,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Upload and validate roster',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                'Upload an image or PDF, review detected duties, then confirm transport needs.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.aero.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              AeroButton(
                label: 'Upload roster',
                icon: Icons.upload_file,
                expand: true,
                onPressed: () => _open(const RosterUploadScreen()),
              ),
            ],
          ),
        ),
        const SizedBox(height: AeroSpacing.sm),
        AeroCard(
          onTap: () => _open(const RosterCalendarScreen()),
          child: const AeroListTile(
            icon: Icons.calendar_month_outlined,
            title: 'Roster calendar',
            subtitle: 'Review confirmed duties and pickup dates',
          ),
        ),
      ],
    ),
  );

  Widget _tripsPage() => _page(
    title: 'Trips',
    action: TextButton(
      onPressed: () => _open(const TripHistoryScreen()),
      child: const Text('History'),
    ),
    child: _loading
        ? const AeroLoadingState()
        : _trips.isEmpty
        ? const AeroEmptyState(
            icon: Icons.route_outlined,
            title: 'No trips yet',
            message: 'Confirmed transport will appear here.',
          )
        : ListView(
            padding: const EdgeInsets.all(20),
            children: _trips.map(_tripCard).toList(),
          ),
  );

  Widget _wallet() => _page(
    title: 'Wallet',
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        AeroCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transport account',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Payments and plan',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              AeroButton(
                label: 'Open wallet',
                expand: true,
                onPressed: () => _open(const WalletScreen()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AeroCard(
          onTap: () => _open(const BillingScreen()),
          child: const AeroListTile(
            icon: Icons.receipt_long_outlined,
            title: 'Billing and subscription',
          ),
        ),
      ],
    ),
  );

  Widget _profile() => _page(
    title: 'Profile',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      _isVerified ? 'Verified crew account' : 'Crew account',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AeroCard(
          onTap: () => _open(const CrewProfileViewScreen()),
          child: const AeroListTile(
            icon: Icons.manage_accounts_outlined,
            title: 'Account details',
          ),
        ),
        const SizedBox(height: 12),
        AeroCard(
          onTap: () => _open(const SettingsScreen()),
          child: const AeroListTile(
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'Appearance, notifications, and privacy',
          ),
        ),
      ],
    ),
  );

  Future<void> _open(Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
}
