class AppConfig {
// CHIP payment gateway
static const String chipApiKey =
    'fAL-PI5SwRpRY5tLKK1qdiXrU098KluFUzc_AXaK9E-ZwflK1BAEed9IddHsVUbLtrHHW2EoRYFVOngJBRNDcg==';

static const String chipBrandId =
    '6431e43b-8c4d-4106-8f77-b7f2a839cabf';
  
  // Base URLs
  static const String chipBaseUrl = 'https://gate.chip-in.asia/api/v1';
  static const String appWebUrl = 'https://aerocrew-96754.web.app';
  
  // Pricing (RM)
  static const Map<String, Map<String, dynamic>> plans = {
    'aeropool': {
      'name': 'AeroPool',
      'price': 750.0,
      'description': 'Shared transport · Monthly subscription',
      'color': 0xFFBA7517,
    },
    'aeroflex': {
      'name': 'AeroFlex',
      'price': 0.0, // pay per trip
      'description': 'Pay per trip · No commitment',
      'color': 0xFF378ADD,
    },
    'aerosolo': {
      'name': 'AeroSolo',
      'price': 1500.0,
      'description': 'Private dedicated transport · Monthly',
      'color': 0xFFEF9F27,
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