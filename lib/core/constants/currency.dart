/// Supported currencies
class Currency {
  final String code;
  final String symbol;
  final String name;
  final int decimalPlaces;

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
    this.decimalPlaces = 2,
  });

  @override
  String toString() => code;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Currency &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

/// Available currencies
class AppCurrencies {
  static const Currency usd = Currency(
    code: 'USD',
    symbol: '\$',
    name: 'US Dollar',
  );

  static const Currency eur = Currency(
    code: 'EUR',
    symbol: '€',
    name: 'Euro',
  );

  static const Currency gbp = Currency(
    code: 'GBP',
    symbol: '£',
    name: 'British Pound',
  );

  static const Currency cad = Currency(
    code: 'CAD',
    symbol: 'CA\$',
    name: 'Canadian Dollar',
  );

  static const Currency aud = Currency(
    code: 'AUD',
    symbol: 'A\$',
    name: 'Australian Dollar',
  );

  static const Currency jpy = Currency(
    code: 'JPY',
    symbol: '¥',
    name: 'Japanese Yen',
    decimalPlaces: 0,
  );

  static const Currency inr = Currency(
    code: 'INR',
    symbol: '₹',
    name: 'Indian Rupee',
  );

  static const Currency cny = Currency(
    code: 'CNY',
    symbol: '¥',
    name: 'Chinese Yuan',
  );

  static const List<Currency> all = [
    usd,
    eur,
    gbp,
    cad,
    aud,
    jpy,
    inr,
    cny,
  ];

  static Currency fromCode(String code) {
    return all.firstWhere(
      (currency) => currency.code == code,
      orElse: () => usd,
    );
  }
}
