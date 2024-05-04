import 'package:cached_network_image/cached_network_image.dart';
import 'package:budrate/features/what_if/widgets/remaining_widget.dart';
import 'package:budrate/routes.dart';
import 'package:budrate/services/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BudgetItem extends ConsumerStatefulWidget {
  final String currency;
  final String choice;
  final int idx;
  final List<Map<String, dynamic>> budgets;
  final Map<String, dynamic> savings;
  final double percentage;
  final double remainingAmount;
  final Function({required double amount}) updateRemainingAmount;

  const BudgetItem({
    super.key,
    required this.currency,
    required this.choice,
    required this.idx,
    required this.budgets,
    required this.savings,
    required this.percentage,
    required this.remainingAmount,
    required this.updateRemainingAmount,
  });

  @override
  ConsumerState<BudgetItem> createState() => _BudgetItemState();
}

class _BudgetItemState extends ConsumerState<BudgetItem> {
  // Calculate current amount in saved currency
  Future<double> _calculateCurrentAmountInSavedCurrency({
    required double amount,
    required String currency,
    required String fromCurrency,
  }) async {
    // Get the exchange rate
    final rate = await ref.read(appApiProvider).getExchangeRate(
          fromCurrency: fromCurrency,
          toCurrency: currency,
          ref: ref,
          onError: (_) {},
        );

    // Calculate the amount
    if (widget.choice == "Down") {
      return amount * rate * ((100 - widget.percentage) / 100);
    } else if (widget.choice == "Up") {
      return amount * rate * ((100 + widget.percentage) / 100);
    }
    return amount * rate;
  }

  // Spread savings
  List<double> _spreadSavings({
    required List<double> budgets,
    required double totalSavings,
    required String baseCurrency,
    required int index,
  }) {
    double remainingAmount = totalSavings;
    List<double> remainingBudgets = [];

    // Iterate through each budget
    for (double budget in budgets) {
      // Check if there's enough savings to cover the budget
      if (remainingAmount >= budget) {
        remainingBudgets.add(budget);
        remainingAmount -= budget;
      } else {
        remainingBudgets.add(remainingAmount);
        remainingAmount = 0;
      }
    }

    return remainingBudgets;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _calculateCurrentAmountInSavedCurrency(
        amount: double.parse(widget.savings['amount'].toString()),
        fromCurrency: widget.savings['base_currency'],
        currency: widget.budgets[widget.idx]['currency'],
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final amount = snapshot.data as double;

        final remainingBudgets = _spreadSavings(
          budgets: widget.budgets
              .map((e) => double.parse(e['amount'].toString()))
              .toList(),
          totalSavings: amount,
          index: widget.idx,
          baseCurrency: widget.savings['base_currency'],
        );

        return _buildBudgetItem(
          budget: widget.budgets[widget.idx],
          index: widget.idx,
          spent: remainingBudgets[widget.idx],
          savings: widget.savings,
          total: widget.budgets.length,
        );
      },
    );
  }

  // Build the budget item
  Widget _buildBudgetItem({
    required Map<String, dynamic> budget,
    required int index,
    required int total,
    required double spent,
    required Map<String, dynamic> savings,
  }) {
    // Get the public URL of the image
    final String publicUrl = Supabase.instance.client.storage
        .from('public-bucket')
        .getPublicUrl(budget['image']);

    // Split the URL based on '/'
    List<String> parts = publicUrl.split('/');

    // Iterate through the parts and remove 'public-bucket'
    List<String> updatedParts = [];
    for (String part in parts) {
      if (part != "public-bucket") {
        updatedParts.add(part);
      }
    }

    // Reconstruct the URL
    String updatedUrl = updatedParts.join('/');

    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).pushNamed(
          AppRoutes.editBudget,
          arguments: budget,
        );
        setState(() {});
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0.r),
          color: index % 2 != 0
              ? const Color(0xff82B9AE)
              : const Color(0xff165A4A),
        ),
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: updatedUrl,
              imageBuilder: (context, imageProvider) => Container(
                width: 80.w,
                height: 100.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0.r),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 80.w,
                height: 100.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0.r),
                  color: Colors.grey,
                ),
              ),
            ),
            SizedBox(width: 20.0.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        budget['name'],
                        style: TextStyle(
                          color: index % 2 != 0 ? Colors.black : Colors.white,
                          fontSize: 20.0.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Icon(Icons.navigate_next, color: Colors.white),
                    ],
                  ),
                  SizedBox(height: 10.0.h),
                  Text(
                    "${NumberFormat.currency(locale: "en_US", symbol: budget['currency']).format(spent)} / ${NumberFormat.currency(locale: "en_US", symbol: budget['currency']).format(budget['amount'])}",
                    style: TextStyle(
                      color: index % 2 != 0 ? Colors.black : Colors.white,
                      fontSize: 14.0.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 10.0.h),
                  RemainingWidget(
                    budget: budget,
                    index: index,
                    remainingAmount: widget.remainingAmount,
                    savings: savings,
                    spent: spent,
                    updateRemainingAmount: ({required double amount}) {
                      widget.updateRemainingAmount(amount: amount);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
