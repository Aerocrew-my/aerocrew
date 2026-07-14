class AppConfig {
  static const String paymentApiUrl = String.fromEnvironment('PAYMENT_API_URL');
  static const String rosterMatchingApiUrl = String.fromEnvironment(
    'ROSTER_MATCHING_URL',
  );
  static bool get isRosterMatchingConfigured =>
      rosterMatchingApiUrl.trim().isNotEmpty;
  static const String appWebUrl = 'https://aerocrew-96754.web.app';

  // Pricing (RM)
  static const Map<String, Map<String, dynamic>> plans = {
    'aeropool': {
      'name': 'AeroPool',
      'price': 750.0,
      'description': 'Shared transport · Monthly subscription',
      'color': 0xFF2563EB,
    },
    'aeroflex': {
      'name': 'AeroFlex',
      'price': 0.0, // pay per trip
      'description': 'Pay per trip · No commitment',
      'color': 0xFF0EA5E9,
    },
    'aerosolo': {
      'name': 'AeroSolo',
      'price': 1500.0,
      'description': 'Private dedicated transport · Monthly',
      'color': 0xFF1E3A8A,
    },
  };

  // Zone pricing for AeroPool (RM/month)
  static const Map<String, double> zonePricing = {
    'Nilai': 300,
    'Cyberjaya': 350,
    'Putra Heights': 450,
    'Shah Alam': 650,
    'Subang Jaya': 600,
    'Petaling Jaya': 700,
    'Ara Damansara': 750,
    'Damansara': 850,
  };
}
