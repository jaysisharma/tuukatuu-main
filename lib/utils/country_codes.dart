class CountryCode {
  final String name;
  final String code;
  final String dialCode;
  final String flag;

  const CountryCode({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
  });

  @override
  String toString() => '$name ($dialCode)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryCode &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

class CountryCodes {
  static const List<CountryCode> countries = [
    // Nepal (default) - placed first
    CountryCode(
      name: 'Nepal',
      code: 'NP',
      dialCode: '+977',
      flag: '🇳🇵',
    ),
    // Other countries
    CountryCode(
      name: 'India',
      code: 'IN',
      dialCode: '+91',
      flag: '🇮🇳',
    ),
    CountryCode(
      name: 'United States',
      code: 'US',
      dialCode: '+1',
      flag: '🇺🇸',
    ),
    CountryCode(
      name: 'United Kingdom',
      code: 'GB',
      dialCode: '+44',
      flag: '🇬🇧',
    ),
    CountryCode(
      name: 'Canada',
      code: 'CA',
      dialCode: '+1',
      flag: '🇨🇦',
    ),
    CountryCode(
      name: 'Australia',
      code: 'AU',
      dialCode: '+61',
      flag: '🇦🇺',
    ),
    CountryCode(
      name: 'Germany',
      code: 'DE',
      dialCode: '+49',
      flag: '🇩🇪',
    ),
    CountryCode(
      name: 'France',
      code: 'FR',
      dialCode: '+33',
      flag: '🇫🇷',
    ),
    CountryCode(
      name: 'Japan',
      code: 'JP',
      dialCode: '+81',
      flag: '🇯🇵',
    ),
    CountryCode(
      name: 'China',
      code: 'CN',
      dialCode: '+86',
      flag: '🇨🇳',
    ),
    CountryCode(
      name: 'South Korea',
      code: 'KR',
      dialCode: '+82',
      flag: '🇰🇷',
    ),
    CountryCode(
      name: 'Singapore',
      code: 'SG',
      dialCode: '+65',
      flag: '🇸🇬',
    ),
    CountryCode(
      name: 'Malaysia',
      code: 'MY',
      dialCode: '+60',
      flag: '🇲🇾',
    ),
    CountryCode(
      name: 'Thailand',
      code: 'TH',
      dialCode: '+66',
      flag: '🇹🇭',
    ),
    CountryCode(
      name: 'Vietnam',
      code: 'VN',
      dialCode: '+84',
      flag: '🇻🇳',
    ),
    CountryCode(
      name: 'Philippines',
      code: 'PH',
      dialCode: '+63',
      flag: '🇵🇭',
    ),
    CountryCode(
      name: 'Indonesia',
      code: 'ID',
      dialCode: '+62',
      flag: '🇮🇩',
    ),
    CountryCode(
      name: 'Bangladesh',
      code: 'BD',
      dialCode: '+880',
      flag: '🇧🇩',
    ),
    CountryCode(
      name: 'Pakistan',
      code: 'PK',
      dialCode: '+92',
      flag: '🇵🇰',
    ),
    CountryCode(
      name: 'Sri Lanka',
      code: 'LK',
      dialCode: '+94',
      flag: '🇱🇰',
    ),
    CountryCode(
      name: 'Maldives',
      code: 'MV',
      dialCode: '+960',
      flag: '🇲🇻',
    ),
    CountryCode(
      name: 'Bhutan',
      code: 'BT',
      dialCode: '+975',
      flag: '🇧🇹',
    ),
    CountryCode(
      name: 'Myanmar',
      code: 'MM',
      dialCode: '+95',
      flag: '🇲🇲',
    ),
    CountryCode(
      name: 'Laos',
      code: 'LA',
      dialCode: '+856',
      flag: '🇱🇦',
    ),
    CountryCode(
      name: 'Cambodia',
      code: 'KH',
      dialCode: '+855',
      flag: '🇰🇭',
    ),
    CountryCode(
      name: 'Brunei',
      code: 'BN',
      dialCode: '+673',
      flag: '🇧🇳',
    ),
    CountryCode(
      name: 'East Timor',
      code: 'TL',
      dialCode: '+670',
      flag: '🇹🇱',
    ),
  ];

  static CountryCode get defaultCountry => countries.first; // Nepal

  static CountryCode? findByCode(String code) {
    try {
      return countries.firstWhere((country) => country.code == code);
    } catch (e) {
      return null;
    }
  }

  static CountryCode? findByDialCode(String dialCode) {
    try {
      return countries.firstWhere((country) => country.dialCode == dialCode);
    } catch (e) {
      return null;
    }
  }

  static List<CountryCode> search(String query) {
    if (query.isEmpty) return countries;
    
    final lowercaseQuery = query.toLowerCase();
    return countries.where((country) =>
        country.name.toLowerCase().contains(lowercaseQuery) ||
        country.code.toLowerCase().contains(lowercaseQuery) ||
        country.dialCode.contains(query)
    ).toList();
  }
}
