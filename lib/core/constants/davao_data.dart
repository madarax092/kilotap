/// Davao City reference data — barangays, vehicle types, housing types
class DavaoData {
  DavaoData._();

  /// Vehicle types for collectors
  static const vehicleTypes = [
    'Kariton',
    'Tricycle / Sidecar',
    'Multicab / Truck',
    'Single Motorcycle',
  ];

  /// Housing types for households
  static const housingTypes = [
    'House',
    'Boarding House / Apartment',
    'Commercial Building',
  ];

  /// Key Davao City barangays relevant to KiloTap operations
  /// Sorted by district for easier navigation
  static const barangays = [
    // District 1 — Poblacion area
    'Agdao',
    'Buhangin',
    'Cabantian',
    'Maa',
    'Matina',
    'Talomo',

    // District 2
    'Bunawan',
    'Ecoland',
    'Lasang',
    'Mandug',
    'Tibungco',

    // District 3
    'Baguio',
    'Calinan',
    'Daliao',
    'Dumoy',
    'Mintal',
    'Sandawa',
    'Toril',
    'Tugbok',
  ];

  /// District names for reference
  static const districts = [
    'District 1 (Poblacion)',
    'District 2 (Bunawan)',
    'District 3 (Toril/Calinan)',
  ];
}
