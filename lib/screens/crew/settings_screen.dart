import 'package:aerocrew/theme/aero_theme.dart';
import 'package:aerocrew/theme/appearance_controller.dart';
import 'package:aerocrew/widgets/aero_components.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _tripReminders = true;
  bool _assignmentUpdates = true;
  bool _rosterReminder = true;
  bool _shareLocation = true;
  bool _poolChat = true;
  String _reminderTiming = '2 hours before pickup';
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AeroAppBar(
        title: 'Settings',
        subtitle: 'App and trip preferences',
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              _sectionTitle('Appearance'),
              AnimatedBuilder(
                animation: AppearanceController.instance,
                builder: (context, _) => AeroCard(
                  padding: EdgeInsets.zero,
                  child: RadioGroup<ThemeMode>(
                    groupValue: AppearanceController.instance.themeMode,
                    onChanged: (mode) {
                      if (mode != null) {
                        AppearanceController.instance.setThemeMode(mode);
                      }
                    },
                    child: const Column(
                      children: [
                        _AppearanceTile(
                          mode: ThemeMode.system,
                          icon: Icons.brightness_auto_outlined,
                          title: 'Use device setting',
                          subtitle: 'Follow Android or system appearance',
                        ),
                        Divider(height: 1),
                        _AppearanceTile(
                          mode: ThemeMode.light,
                          icon: Icons.light_mode_outlined,
                          title: 'Light',
                          subtitle: 'Use the light Skyline Blue theme',
                        ),
                        Divider(height: 1),
                        _AppearanceTile(
                          mode: ThemeMode.dark,
                          icon: Icons.dark_mode_outlined,
                          title: 'Dark',
                          subtitle: 'Use the dark operational theme',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _sectionTitle('Notifications'),
              AeroCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _toggle(
                      icon: Icons.alarm_outlined,
                      title: 'Trip reminders',
                      subtitle: 'Notify before pickup',
                      value: _tripReminders,
                      onChanged: (value) =>
                          setState(() => _tripReminders = value),
                    ),
                    const Divider(height: 1),
                    _toggle(
                      icon: Icons.directions_car_outlined,
                      title: 'Assignment updates',
                      subtitle: 'Operator, driver, and vehicle changes',
                      value: _assignmentUpdates,
                      onChanged: (value) =>
                          setState(() => _assignmentUpdates = value),
                    ),
                    const Divider(height: 1),
                    _toggle(
                      icon: Icons.calendar_month_outlined,
                      title: 'Roster reminder',
                      subtitle: 'Remind me to upload a new roster',
                      value: _rosterReminder,
                      onChanged: (value) =>
                          setState(() => _rosterReminder = value),
                    ),
                  ],
                ),
              ),
              _sectionTitle('Trips and privacy'),
              AeroCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _toggle(
                      icon: Icons.location_on_outlined,
                      title: 'Share trip location',
                      subtitle: 'Only while a transport trip is active',
                      value: _shareLocation,
                      onChanged: (value) =>
                          setState(() => _shareLocation = value),
                    ),
                    const Divider(height: 1),
                    _toggle(
                      icon: Icons.chat_bubble_outline,
                      title: 'Pool group chat',
                      subtitle: 'Message confirmed pool members',
                      value: _poolChat,
                      onChanged: (value) => setState(() => _poolChat = value),
                    ),
                    const Divider(height: 1),
                    _dropdown(
                      icon: Icons.schedule,
                      title: 'Reminder timing',
                      value: _reminderTiming,
                      options: const [
                        '30 minutes before pickup',
                        '1 hour before pickup',
                        '2 hours before pickup',
                        '3 hours before pickup',
                      ],
                      onChanged: (value) =>
                          setState(() => _reminderTiming = value),
                    ),
                  ],
                ),
              ),
              _sectionTitle('App'),
              AeroCard(
                padding: EdgeInsets.zero,
                child: _dropdown(
                  icon: Icons.language,
                  title: 'Language',
                  value: _language,
                  options: const ['English', 'Bahasa Malaysia'],
                  onChanged: (value) => setState(() => _language = value),
                ),
              ),
              const SizedBox(height: AeroSpacing.section),
              Center(
                child: Text(
                  'AeroCrew 1.0.0 · Malaysia',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 10),
    child: Text(title, style: Theme.of(context).textTheme.titleMedium),
  );

  Widget _toggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _dropdown({
    required IconData icon,
    required String title,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(child: Text(title)),
          const SizedBox(width: 12),
          DropdownButton<String>(
            value: value,
            underline: const SizedBox.shrink(),
            borderRadius: BorderRadius.circular(AeroRadius.input),
            items: options
                .map(
                  (option) =>
                      DropdownMenuItem(value: option, child: Text(option)),
                )
                .toList(),
            onChanged: (next) {
              if (next != null) onChanged(next);
            },
          ),
        ],
      ),
    );
  }
}

class _AppearanceTile extends StatelessWidget {
  const _AppearanceTile({
    required this.mode,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final ThemeMode mode;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<ThemeMode>(
      value: mode,
      secondary: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
