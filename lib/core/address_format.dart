import 'constants/davao_barangays.dart';

// Addresses are stored as one string in the shape
// "<street / block / lot>, <barangay>, <city>" (ScrapSeller.Address,
// ScrapCollector.Address, bookings.PickupAddress). These helpers build and
// take that string apart so the address form can be re-opened and edited
// without nesting the previous address inside the street field.

const String _barangayPrefix = 'Barangay ';

// Numbered Poblacion barangays are already named "Barangay 1-A"; everything
// else ("Talomo") needs the word added when displayed.
String formatBarangay(String barangay) {
  return barangay.startsWith(_barangayPrefix)
      ? barangay
      : '$_barangayPrefix$barangay';
}

String composeAddress({
  required String street,
  required String barangay,
  required String city,
}) {
  final parts = <String>[
    if (street.trim().isNotEmpty) street.trim(),
    formatBarangay(barangay),
    city,
  ];
  return parts.join(', ');
}

class ParsedAddress {
  final String street;
  final String? barangay;
  final String? city;
  const ParsedAddress({required this.street, this.barangay, this.city});
}

// Splits a stored address back into street / barangay / city. An address that
// doesn't end in a known barangay and city (older free-text entries) comes
// back whole in [street] so nothing the user typed is lost.
ParsedAddress parseAddress(String address) {
  final trimmed = address.trim();
  final parts = trimmed.split(',').map((p) => p.trim()).toList();
  if (parts.length < 2) return ParsedAddress(street: trimmed);

  final city = parts.last;
  if (!supportedCities.contains(city)) return ParsedAddress(street: trimmed);

  final barangayPart = parts[parts.length - 2];
  // Also try with the prefix stripped (once or twice) — earlier versions
  // wrote "Barangay Barangay 1-A" for numbered barangays.
  final candidates = <String>{barangayPart};
  var stripped = barangayPart;
  for (var i = 0; i < 2; i++) {
    if (stripped.startsWith(_barangayPrefix)) {
      stripped = stripped.substring(_barangayPrefix.length);
      candidates.add(stripped);
    }
  }
  final match = candidates.firstWhere(davaoCityBarangays.contains,
      orElse: () => '');
  if (match.isEmpty) return ParsedAddress(street: trimmed);

  final street = parts.sublist(0, parts.length - 2).join(', ');
  return ParsedAddress(street: street, barangay: match, city: city);
}

// The barangay + city of an address, or null if it isn't in the standard
// shape. A saved map pin is only trusted while this stays the same.
String? addressArea(String address) {
  final p = parseAddress(address);
  if (p.barangay == null || p.city == null) return null;
  return '${p.barangay}|${p.city}';
}
