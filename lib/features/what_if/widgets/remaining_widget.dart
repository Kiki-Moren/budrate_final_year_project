import 'package:budrate/services/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class RemainingWidget extends ConsumerStatefulWidget {
  final Map<String, dynamic> savings;
  final Map<String, dynamic> budget;
  final int index;
  final double spent;
  final double remainingAmount;
  final Function({required double amount}) updateRemainingAmount;

  const RemainingWidget({
    super.key,
    required this.savings,
    required this.budget,
    required this.index,
    required this.spent,
    required this.remainingAmount,
    required this.updateRemainingAmount,
  });

  @override
  ConsumerState<RemainingWidget> createState() => _RemainingWidgetState();
}

class _RemainingWidgetState extends ConsumerState<RemainingWidget> {
  // Convert to Base currency
  Future<double> _convertToBaseCurrency({
    required double amount,
    required String currency,
    required String baseCurrency,
  }) async {
    // Get the exchange rate
    final rate = await ref.read(appApiProvider).getExchangeRate(
          fromCurrency: currency,
          toCurrency: baseCurrency,
          ref: ref,
          onError: (_) {},
        );

    return amount * rate;
  }

  // Calculate percentage
  double _calculatePercentage({
    required double amount,
    required double total,
  }) {
    // If amount is greater than total
    if (amount > total) return 1.0;

    return amount / total;
  }

  // Calculate remaining amount
  Future<String> _calculateRemainingAmount({
    required double amount,
    required double total,
    required String currency,
    required String baseCurrency,
  }) async {
    // Convert to base currency
    double remaining = await _convertToBaseCurrency(
      amount: total - amount,
      currency: currency,
      baseCurrency: baseCurrency,
    );

    // If remaining is less than or equal to 0
    if (remaining <= 0) {
      return "Well done you have enough for your budget!";
    }

    // Update remaining amount
    widget.updateRemainingAmount(amount: remaining);

    return "You need ${NumberFormat.currency(locale: "en_US", symbol: baseCurrency).format(remaining)} more to reach your goal";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _calculateRemainingAmount(
        amount: widget.spent,
        total: double.parse(widget.budget['amount'].toString()),
        currency: widget.budget['currency'],
        baseCurrency: widget.savings['base_currency'],
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        // Get remaining amount
        final remaining = snapshot.data as String;

        return Column(
          children: [
            LinearPercentIndicator(
              width: 180.0.w,
              lineHeight: 8.0.w,
              percent: _calculatePercentage(
                amount: widget.spent,
                total: double.parse(widget.budget['amount'].toString()),
              ),
              barRadius: Radius.circular(10.0.r),
              backgroundColor: Colors.grey,
              progressColor: Colors.blue,
            ),
            SizedBox(height: 10.0.h),
            Text(
              remaining,
              style: TextStyle(
                color: widget.index % 2 != 0 ? Colors.black : Colors.white,
                fontSize: 14.0.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        );
      },
    );
  }
}
