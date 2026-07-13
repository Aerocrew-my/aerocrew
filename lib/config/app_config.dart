class AppConfig {
  // CHIP payment gateway. Prefer a server-side payment endpoint for release;
  // this build-time value exists only for compatibility with the current flow.
  static const String chipApiKey = String.fromEnvironment('CHIP_API_KEY');

  static const String chipBrandId = '6431e43b-8c4d-4106-8f77-b7f2a839cabf';

  // Base URLs
  static const String chipBaseUrl = 'https://gate.chip-in.asia/api/v1';
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
