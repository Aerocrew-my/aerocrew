import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool tripReminders = true;
  bool vanMatched = true;
  bool rosterReminder = true;
  bool marketingEmails = false;
  bool shareLocation = true;
  bool biometricLogin = false;
  bool darkMode = true;
  bool poolChat = true;
  String selectedLanguage = 'English';
  String reminderTiming = '2 hours before pickup';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AeroColors.navy,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AeroColors.navyCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AeroColors.divider, width: 0.5),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SETTINGS',
                          style: TextStyle(
                              fontSize: 11,
                              color: AeroColors.amber,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1)),
                      Text('Preferences',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection('NOTIFICATIONS', [
                      _buildToggle('Trip reminders', 'Notify before pickup',
                          tripReminders, Icons.alarm_outlined,
                          (v) => setState(() => tripReminders = v)),
                      _buildToggle('Van matched', 'When your van is assigned',
                          vanMatched, Icons.directions_car_outlined,
                          (v) => setState(() => vanMatched = v)),
                      _buildToggle(
                          'Roster reminder',
                          'Remind to upload monthly roster',
                          rosterReminder,
                          Icons.calendar_month_outlined,
                          (v) => setState(() => rosterReminder = v)),
                      _buildToggle(
                          'Marketing',
                          'Promotions and announcements',
                          marketingEmails,
                          Icons.mail_outline,
                          (v) => setState(() => marketingEmails = v)),
                    ]),
                    _buildSection('PRIVACY & SECURITY', [
                      _buildToggle(
                          'Share location',
                          'Allow van tracking during trips',
                          shareLocation,
                          Icons.location_on_outlined,
                          (v) => setState(() => shareLocation = v)),
                      _buildToggle(
                          'Biometric login',
                          'Use Face ID or fingerprint',
                          biometricLogin,
                          Icons.fingerprint,
                          (v) => setState(() => biometricLogin = v)),
                    ]),
                    _buildSection('TRIP PREFERENCES', [
                      _buildToggle(
                          'Pool group chat',
                          'Enable messaging with poolmates',
                          poolChat,
                          Icons.chat_bubble_outline,
                          (v) => setState(() => poolChat = v)),
                      _buildDropdownTile(
                          'Reminder timing',
                          reminderTiming,
                          Icons.schedule,
                          [
                            '30 min before pickup',
                            '1 hour before pickup',
                            '2 hours before pickup',
                            '3 hours before pickup',
                          ],
                          (v) => setState(() => reminderTiming = v!)),
                    ]),
                    _buildSection('APP', [
                      _buildToggle(
                          'Dark mode',
                          'Dark theme (recommended)',
                          darkMode,
                          Icons.dark_mode_outlined,
                          (v) => setState(() => darkMode = v)),
                      _buildDropdownTile(
                          'Language',
                          selectedLanguage,
                          Icons.language,
                          ['English', 'Bahasa Malaysia'],
                          (v) =>
                              setState(() => selectedLanguage = v!)),
                    ]),
                    _buildSection('ACCOUNT', [
                      _buildActionTile('Change password',
                          Icons.lock_outline, AeroColors.grey, () {}),
                      _buildActionTile('Delete account',
                          Icons.delete_outline, AeroColors.danger, () {}),
                    ]),
                    const SizedBox(height: 8),
                    Center(
                      child: Text('AeroCrew v1.0.0 · Malaysia',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AeroColors.lightGrey)),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(title, style: AeroText.label),
        ),
        Container(
          decoration: BoxDecoration(
            color: AeroColors.navyCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AeroColors.divider, width: 0.5),
          ),
          child: Column(
            children: children.asMap().entries.map((e) {
              final isLast = e.key == children.length - 1;
              return Column(
                children: [
                  e.value,
                  if (!isLast)
                    Container(
                        height: 0.5,
                        margin:
                            const EdgeInsets.symmetric(horizontal: 16),
                        color: AeroColors.divider),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildToggle(String title, String subtitle, bool value,
      IconData icon, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AeroColors.navy,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AeroColors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: AeroColors.grey)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AeroColors.amber,
            activeTrackColor: AeroColors.amber.withValues(alpha: 0.3),
            inactiveThumbColor: AeroColors.grey,
            inactiveTrackColor: AeroColors.divider,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile(String title, String value, IconData icon,
      List<String> options, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AeroColors.navy,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AeroColors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white)),
          ),
          DropdownButton<String>(
            value: value,
            dropdownColor: AeroColors.navyCard,
            style: const TextStyle(
                color: AeroColors.amber, fontSize: 12),
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down,
                color: AeroColors.grey, size: 16),
            items: options
                .map((o) =>
                    DropdownMenuItem(value: o, child: Text(o)))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: color)),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 13, color: color.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}