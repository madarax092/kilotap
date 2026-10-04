// Davao City's 182 barangays (PSA/PSGC-sourced). The city uses numbered
// barangays ("Barangay 1-A" .. "40-D") for its urban Poblacion district
// alongside named ones elsewhere — _compareBarangay sorts those numerically
// against each other instead of lexicographically (so "2-A" comes before
// "10-A"), while everything else just sorts alphabetically.
const List<String> _rawDavaoCityBarangays = [
  'Acacia', 'Agdao', 'Alambre', 'Alejandra Navarro', 'Alfonso Angliongto Sr.',
  'Angalan', 'Atan-awe', 'Baganihan', 'Bago Aplaya', 'Bago Gallera',
  'Bago Oshiro', 'Baguio', 'Balengaeng', 'Baliok', 'Bangkas Heights',
  'Bantol', 'Baracatan', 'Barangay 1-A', 'Barangay 2-A', 'Barangay 3-A',
  'Barangay 4-A', 'Barangay 5-A', 'Barangay 6-A', 'Barangay 7-A',
  'Barangay 8-A', 'Barangay 9-A', 'Barangay 10-A', 'Barangay 11-B',
  'Barangay 12-B', 'Barangay 13-B', 'Barangay 14-B', 'Barangay 15-B',
  'Barangay 16-B', 'Barangay 17-B', 'Barangay 18-B', 'Barangay 19-B',
  'Barangay 20-B', 'Barangay 21-C', 'Barangay 22-C', 'Barangay 23-C',
  'Barangay 24-C', 'Barangay 25-C', 'Barangay 26-C', 'Barangay 27-C',
  'Barangay 28-C', 'Barangay 29-C', 'Barangay 30-C', 'Barangay 31-D',
  'Barangay 32-D', 'Barangay 33-D', 'Barangay 34-D', 'Barangay 35-D',
  'Barangay 36-D', 'Barangay 37-D', 'Barangay 38-D', 'Barangay 39-D',
  'Barangay 40-D',
  'Bato', 'Bayabas', 'Biao Escuela', 'Biao Guianga', 'Biao Joaquin',
  'Binugao', 'Bucana', 'Buda', 'Buhangin', 'Bunawan', 'Cabantian',
  'Cadalian', 'Calinan', 'Callawa', 'Camansi', 'Carmen', 'Catalunan Grande',
  'Catalunan Pequeño', 'Catigan', 'Cawayan', 'Centro', 'Colosas', 'Communal',
  'Crossing Bayabas', 'Dacudao', 'Dalag', 'Dalagdag', 'Daliao',
  'Daliaon Plantation', 'Datu Salumay', 'Dominga', 'Dumoy', 'Eden', 'Fatima',
  'Gatungan', 'Gov. Paciano Bangoy', 'Gov. Vicente Duterte', 'Gumalang',
  'Gumitan', 'Ilang', 'Inayangan', 'Indangan', 'Kap. Tomas Monteverde, Sr.',
  'Kilate', 'Lacson', 'Lamanan', 'Lampianao', 'Langub', 'Lapu-lapu',
  'Leon Garcia, Sr.', 'Lizada', 'Los Amigos', 'Lubogan', 'Lumiad', 'Ma-a',
  'Mabuhay', 'Magsaysay', 'Magtuod', 'Mahayag', 'Malabog', 'Malagos',
  'Malamba', 'Manambulan', 'Mandug', 'Manuel Guianga', 'Mapula',
  'Marapangi', 'Marilog', 'Matina Aplaya', 'Matina Biao', 'Matina Crossing',
  'Matina Pangi', 'Megkawayan', 'Mintal', 'Mudiang', 'Mulig', 'New Carmen',
  'New Valencia', 'Pampanga', 'Panacan', 'Panalum', 'Pandaitan', 'Pangyan',
  'Paquibato', 'Paradise Embak', 'Rafael Castillo', 'Riverside', 'Salapawan',
  'Salaysay', 'Saloy', 'San Antonio', 'San Isidro', 'Santo Niño', 'Sasa',
  'Sibulan', 'Sirawan', 'Sirib', 'Suawan', 'Subasta', 'Sumimao', 'Tacunan',
  'Tagakpan', 'Tagluno', 'Tagurano', 'Talandang', 'Talomo', 'Talomo River',
  'Tamayong', 'Tambobong', 'Tamugan', 'Tapak', 'Tawan-tawan', 'Tibuloy',
  'Tibungco', 'Tigatto', 'Toril', 'Tugbok', 'Tungakalan', 'Ubalde', 'Ula',
  'Vicente Hizon Sr.', 'Waan', 'Wangan', 'Wilfredo Aquino', 'Wines',
];

int? _barangayNumber(String name) {
  final match = RegExp(r'^Barangay (\d+)-').firstMatch(name);
  return match != null ? int.parse(match.group(1)!) : null;
}

int _compareBarangay(String a, String b) {
  final numA = _barangayNumber(a);
  final numB = _barangayNumber(b);
  if (numA != null && numB != null) return numA.compareTo(numB);
  return a.compareTo(b);
}

final List<String> davaoCityBarangays = List<String>.from(
    _rawDavaoCityBarangays)
  ..sort(_compareBarangay);

// Cities currently supported by the structured address form — this app is
// explicitly scoped to Davao City (see CLAUDE.md), so that's the only entry
// today. Kept as a list (not a hardcoded single value) so it's a real
// dropdown and can grow if the service area ever expands — note that doing
// so would also need each new city's own barangay list, which this file
// doesn't have yet.
const List<String> supportedCities = ['Davao City'];
