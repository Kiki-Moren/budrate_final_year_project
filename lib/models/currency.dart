// Country Model
class Country {
  String? currency;
  String? name;
  String? symbol;

  Country({this.currency, this.name, this.symbol});

  Country.fromJson(Map<String, dynamic> json) {
    currency = json['currency'];
    name = json['name'];
    symbol = json['symbol'];
  }
}
