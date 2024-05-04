import 'package:budrate/models/currency.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Currencies state
final currencies = StateProvider<List<Country>>((ref) => []);
