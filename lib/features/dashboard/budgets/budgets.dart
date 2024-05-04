import 'package:cached_network_image/cached_network_image.dart';
import 'package:budrate/routes.dart';
import 'package:budrate/services/app.dart';
import 'package:budrate/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BudgetTab extends ConsumerStatefulWidget {
  const BudgetTab({super.key});

  @override
  ConsumerState<BudgetTab> createState() => _BudgetTabState();
}

class _BudgetTabState extends ConsumerState<BudgetTab> {
  // User data
  Map<String, dynamic>? _userData;
  // Budgets
  final _budgets = Supabase.instance.client
      .from('budgets')
      .stream(primaryKey: ['id'])
      .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
      .order('amount', ascending: true);

  // Savings
  final _savings = Supabase.instance.client
      .from('savings')
      .stream(primaryKey: ['id']).eq(
          'user_id', Supabase.instance.client.auth.currentUser!.id);

  @override
  void initState() {
    // Get the user data
    _getUser();
    super.initState();
  }

  void _getUser() async {
    // Get the user data
    _userData = await Supabase.instance.client
        .from('users')
        .select()
        .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
        .single();
    setState(() {});
  }

  // Calculate the percentage of the amount spent
  double _calculatePercentage({
    required double amount,
    required double total,
  }) {
    // Check if the amount is greater than the total
    if (amount > total) return 1.0;

    return amount / total;
  }

  // Spread the savings across the budgets
  List<double> _spreadSavings({
    required List<double> budgets,
    required double totalSavings,
    required int index,
  }) {
    // Calculate the remaining amount
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

  // Calculate the current amount in the saved currency
  Future<double> _calculateCurrentAmountInSavedCurrency({
    required double amount,
    required String fromCurrency,
    required String currency,
  }) async {
    // Get the exchange rate
    final rate = await ref.read(appApiProvider).getExchangeRate(
          fromCurrency: fromCurrency,
          toCurrency: currency,
          ref: ref,
          onError: (_) {},
        );

    return amount * rate;
  }

  // Convert the amount to Base Currency
  Future<double> _convertToBaseCurrency({
    required double amount,
    required String baseCurrency,
    required String currency,
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

  // Calculate the remaining amount
  Future<String> _calculateRemainingAmount({
    required double amount,
    required double total,
    required String currency,
    required String baseCurrency,
  }) async {
    // Convert the amount to the base currency
    double remaining = await _convertToBaseCurrency(
      amount: total - amount,
      currency: currency,
      baseCurrency: baseCurrency,
    );
    // Check if the remaining amount is less than or equal to 0
    if (total - amount <= 0) return "Well done you have enough for your budget";

    // Return the remaining amount
    return "You need ${NumberFormat.currency(locale: "en_US", symbol: baseCurrency).format(remaining)} more to reach your goal";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      floatingActionButton: IconButton(
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.addBudget),
        icon: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add),
        ),
        iconSize: 30.0,
      ),
    );
  }

  //  Build the body of the budget screen
  Widget _buildBody() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Center(
              child: Text(
                "My Goals",
                style: TextStyle(
                  fontSize: 24.0.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            SizedBox(height: 20.0.h),
            _buildTotalSavingsContainer(),
            SizedBox(height: 20.0.h),
            Text(
              "Your Budget Today:",
              style: TextStyle(
                fontSize: 24.0.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            FutureBuilder(
              // Get the exchange rate
              future: ref.read(appApiProvider).getExchangeRate(
                    fromCurrency: "GBP",
                    toCurrency: _userData?['base_currency'] ?? "NGN",
                    ref: ref,
                    onError: (_) {},
                  ),
              builder: (ctx, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox();
                }

                // Get the exchange rate
                final rate = snapshot.data as double;

                // Return the exchange rate
                return Text(
                  "Rate Now: 1 GBP = ${NumberFormat.currency(locale: "en_US", symbol: _userData?['base_currency'] ?? "NGN").format(rate)}",
                  style: TextStyle(
                    fontSize: 16.0.sp,
                    fontWeight: FontWeight.w400,
                  ),
                );
              },
            ),
            SizedBox(height: 20.0.h),
            StreamBuilder(
              stream: _budgets,
              builder: (context, snapshot) {
                // Check if the snapshot has data
                if (!snapshot.hasData) {
                  return const SizedBox();
                }
                // Get the budgets
                final budgets = snapshot.data!;
                return StreamBuilder(
                    stream: _savings,
                    builder: (context, snapshot) {
                      // Check if the snapshot has data
                      if (!snapshot.hasData) {
                        return const SizedBox();
                      }
                      // Get the savings
                      final savings = snapshot.data!.first;

                      // Return the list of budgets
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (ctx, idx) {
                          return FutureBuilder(
                            // Calculate the current amount in the saved currency
                            future: _calculateCurrentAmountInSavedCurrency(
                              amount:
                                  double.parse(savings['amount'].toString()),
                              fromCurrency: savings['base_currency'],
                              currency: budgets[idx]['currency'],
                            ),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const SizedBox();
                              }
                              // Get the amount
                              final amount = snapshot.data as double;
                              // Spread the savings across the budgets
                              final remainingBudgets = _spreadSavings(
                                budgets: budgets
                                    .map((e) =>
                                        double.parse(e['amount'].toString()))
                                    .toList(),
                                totalSavings: amount,
                                index: idx,
                              );
                              // Return the budget item
                              return _buildBudgetItem(
                                budget: budgets[idx],
                                index: idx,
                                spent: remainingBudgets[idx],
                                savings: savings,
                              );
                            },
                          );
                        },
                        separatorBuilder: (ctx, idx) =>
                            SizedBox(height: 10.0.h),
                        itemCount: budgets.length,
                      );
                    });
              },
            ),
            SizedBox(height: 20.0.h),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  // Build the bottom section of the budget screen
  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xff82B9AE),
        borderRadius: BorderRadius.circular(20.0.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "But the exchange rate can change and this will affect your budget",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.0.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 20.0.h),
          PrimaryButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.whatIf);
            },
            buttonText: "Find Out More",
          ),
        ],
      ),
    );
  }

  // Build the budget item
  Widget _buildBudgetItem({
    required Map<String, dynamic> budget,
    required int index,
    required double spent,
    required Map<String, dynamic> savings,
  }) {
    // Get the image public URL
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
                  LinearPercentIndicator(
                    width: 180.0.w,
                    lineHeight: 8.0.w,
                    percent: _calculatePercentage(
                      amount: spent,
                      total: double.parse(budget['amount'].toString()),
                    ),
                    barRadius: Radius.circular(10.0.r),
                    backgroundColor: Colors.grey,
                    progressColor: Colors.blue,
                  ),
                  SizedBox(height: 10.0.h),
                  FutureBuilder(
                      // Calculate the remaining amount
                      future: _calculateRemainingAmount(
                        amount: spent,
                        total: double.parse(budget['amount'].toString()),
                        currency: budget['currency'],
                        baseCurrency: savings['base_currency'],
                      ),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox();
                        }
                        // Get the remaining amount
                        final remaining = snapshot.data as String;
                        return Text(
                          remaining,
                          style: TextStyle(
                            color: index % 2 != 0 ? Colors.black : Colors.white,
                            fontSize: 14.0.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        );
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build the total savings container
  Widget _buildTotalSavingsContainer() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.topUpSaving),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage("assets/images/total_savings_bg.png"),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(20.0.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Total Savings",
              style: TextStyle(
                fontSize: 24.0.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20.0.h),
            StreamBuilder(
              stream: _savings,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox();
                }
                final saving = snapshot.data!.first;
                return Text(
                  NumberFormat.currency(
                          locale: "en_US", symbol: saving['base_currency'])
                      .format(saving['amount']),
                  style: TextStyle(
                    fontSize: 24.0.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                );
              },
            ),
            SizedBox(height: 10.0.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.topUpSaving),
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
