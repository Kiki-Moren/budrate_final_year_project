import 'package:budrate/models/currency.dart';
import 'package:budrate/state/app_state.dart';
import 'package:budrate/state/data.dart';
import 'package:budrate/utilities/exceptions.dart';
import 'package:budrate/utilities/network.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final appApiProvider = Provider<AppService>((ref) => AppService());

class AppService {
  Network network = NetworkImplementation();

  // Get currencies
  Future<void> getCurrencies({
    required WidgetRef ref,
    required void Function(String message) onError,
  }) async {
    List<Country> currencyList = [];

    try {
      for (int i = 0; i < Data.currencies.length; i++) {
        currencyList.add(Country.fromJson(Data.currencies[i]));
      }

      ref.read(currencies.notifier).state = currencyList;
    } on CustomException catch (e) {
      onError(e.toString());
    } catch (e) {
      onError('Network error, check your network connection');
    }
  }

  // Get conversion value
  Future<double> getConversionValue({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
    required WidgetRef ref,
    required void Function(String message) onError,
  }) async {
    try {
      var response = await network.get(
        'https://api.api-ninjas.com/v1/convertcurrency?want=$toCurrency&have=$fromCurrency&amount=$amount',
        incomingHeaders: {
          "X-Api-Key": "gqnmSOwaMx1vKRy5cNoS3w==DH77dB3J7e3cZu7b"
        },
      );

      return response['new_amount'];
    } on CustomException catch (e) {
      onError(e.toString());
      return 0.0;
    } catch (e) {
      onError('Network error, check your network connection');
      return 0.0;
    }
  }

  // Get exchange rate
  Future<double> getExchangeRate({
    required String fromCurrency,
    required String toCurrency,
    required WidgetRef ref,
    required void Function(String message) onError,
  }) async {
    try {
      var response = await network.get(
        'https://api.api-ninjas.com/v1/exchangerate?pair=${fromCurrency}_$toCurrency',
        incomingHeaders: {
          "X-Api-Key": "gqnmSOwaMx1vKRy5cNoS3w==DH77dB3J7e3cZu7b"
        },
      );

      Logger().i(response);

      return response['exchange_rate'];
    } on CustomException catch (e) {
      onError(e.toString());
      Logger().i(e.toString());
      return 0.0;
    } catch (e, s) {
      Logger().i(e.toString());
      onError('Network error, check your network connection');
      return 0.0;
    }
  }

  // Get business quote
  Future<String> getBusinessQuote({
    required WidgetRef ref,
    required void Function(String message) onError,
  }) async {
    try {
      var response = await network.get(
        'https://api.api-ninjas.com/v1/quotes?category=business',
        incomingHeaders: {
          "X-Api-Key": "gqnmSOwaMx1vKRy5cNoS3w==DH77dB3J7e3cZu7b"
        },
      );

      return response[0]['quote'];
    } on CustomException catch (e) {
      onError(e.toString());
      return "";
    } catch (e) {
      onError('Network error, check your network connection');
      return "";
    }
  }

  // Add activity
  Future<void> addActivity({required String title}) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      await Supabase.instance.client.from('activities').insert({
        'user_id': user!.id,
        'title': title,
      });
    } catch (_) {}
  }
}
