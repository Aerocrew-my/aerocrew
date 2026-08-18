import 'package:shared_preferences/shared_preferences.dart';

abstract interface class RosterJobStore {
  Future<String?> load();
  Future<void> save(String jobId);
}

class PreferencesRosterJobStore implements RosterJobStore {
  static const _key = 'current_roster_job_id';

  @override
  Future<String?> load() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_key);
  }

  @override
  Future<void> save(String jobId) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key, jobId);
  }
}
