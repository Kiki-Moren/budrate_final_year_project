import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:budrate/features/what_if/widgets/budget_item.dart';
import 'package:budrate/services/app.dart';
import 'package:budrate/state/app_state.dart';
import 'package:budrate/widgets/drop_down_field.dart';
import 'package:budrate/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WhatIfScreen extends ConsumerStatefulWidget {
  const WhatIfScreen({super.key});

  @override
  ConsumerState<WhatIfScreen> createState() => _WhatIfScreenState();
}

class _WhatIfScreenState extends ConsumerState<WhatIfScreen> {
  final _percentageController = TextEditingController();
  double _remainingAmount = 0;
  String? bottomPart;
  String? _selectedCurrency;
  String? _selectedChoice;
  bool _isLoading = false;
  double? _rate;
  Map<String, dynamic>? _user;

  // Get budgets
  final _budgets = Supabase.instance.client
      .from('budgets')
      .stream(primaryKey: ['id'])
      .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
      .order('amount', ascending: true);

  // Get savings
  final _savings = Supabase.instance.client
      .from('savings')
      .stream(primaryKey: ['id']).eq(
          'user_id', Supabase.instance.client.auth.currentUser!.id);
  @override
  void initState() {
    // Get the user
    _getUser();
    super.initState();
  }

  @override
  void dispose() {
    // Dispose the controllers
    _percentageController.dispose();
    super.dispose();
  }

  void _getUser() async {
    // Get the current user
    _user = await Supabase.instance.client
        .from('users')
        .select()
        .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
        .single();
    setState(() {});
  }

  // Get exchange rate
  void _getExchangeRate() async {
    // If percentage is empty or selected currency is empty
    if (_percentageController.text.isEmpty || _selectedCurrency == null) {
      return;
    }

    // Show the loading indicator
    setState(() {
      _isLoading = true;
    });

    // Get the exchange rate
    final appService = ref.read(appApiProvider);
    // Get the exchange rate
    final rate = await appService.getExchangeRate(
      fromCurrency: _selectedCurrency!,
      toCurrency: _user?['base_currency'] ?? _selectedCurrency!,
      ref: ref,
      onError: (String message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      },
    );

    // Hide the loading indicator
    setState(() {
      _isLoading = false;
      _remainingAmount = 0;
      _rate = _selectedChoice == "Up"
          ? rate * ((100 - double.parse(_percentageController.text)) / 100)
          : rate * ((100 + double.parse(_percentageController.text)) / 100);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffD8EBE9),
        title: const Text(
          "What If?",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  // Build the body of the screen
  Widget _buildBody() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            DropDownField(
              data: const ["Up", "Down"],
              hint: "Select Base Currency",
              selected: _selectedChoice,
              label: "Choice",
              onChanged: (String? value) {
                _selectedChoice = value;
                _getExchangeRate();
              },
            ),
            SizedBox(height: 20.0.h),
            InputField(
              controller: _percentageController,
              hint: "percentage",
              validator: (String? value) => null,
              textInputType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              formatters: [
                CurrencyTextInputFormatter.currency(
                  decimalDigits: 2,
                  symbol: '',
                ),
              ],
              onChanged: (String? value) => _getExchangeRate(),
              label:
                  "What if rate is ${_selectedChoice == "Up" ? "up by (in percentage)" : "down by (in percentage)"}",
            ),
            SizedBox(height: 20.0.h),
            DropDownField(
              data: ref.watch(currencies).map((e) => e.currency!).toList(),
              hint: "Select Base Currency",
              selected: _selectedCurrency,
              label: "Quote Currency",
              onChanged: (String? value) {
                _selectedCurrency = value;

                _getExchangeRate();
              },
            ),
            SizedBox(height: 20.0.h),
            _buildLoadedSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedSection() {
    return _isLoading
        ? Center(
            child: LoadingAnimationWidget.discreteCircle(
              color: const Color(0xff165A4A),
              size: 30.0.w,
            ),
          )
        : Expanded(
            child: Column(
              children: [
                _rate == null
                    ? const SizedBox()
                    : Row(
                        children: [
                          Text(
                            "Rate will be: 1 ${_selectedCurrency ?? ""} = ${NumberFormat.currency(locale: "en_US", symbol: _user?['base_currency'] ?? '').format(_rate)}",
                            style: TextStyle(
                              fontSize: 16.0.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(width: 10.0.w),
                          SvgPicture.asset(
                            _selectedChoice == "Up"
                                ? "assets/icons/smile_emoji.svg"
                                : "assets/icons/sad.svg",
                            width: 20.0.w,
                          ),
                        ],
                      ),
                SizedBox(height: 20.0.h),
                Expanded(
                  child: StreamBuilder(
                    stream: _budgets,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox();
                      }
                      final budgets = snapshot.data!;
                      return StreamBuilder(
                        stream: _savings,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox();
                          }
                          final savings = snapshot.data!.first;

                          return ListView.separated(
                            shrinkWrap: true,
                            itemBuilder: (ctx, idx) => BudgetItem(
                              remainingAmount: _remainingAmount,
                              budgets: budgets,
                              choice: _selectedChoice ?? "",
                              currency: _selectedCurrency ?? "",
                              idx: idx,
                              percentage: double.parse(
                                  _percentageController.text.isEmpty
                                      ? "1"
                                      : _percentageController.text),
                              savings: savings,
                              updateRemainingAmount: ({required amount}) {
                                _remainingAmount = amount;
                              },
                            ),
                            separatorBuilder: (ctx, idx) =>
                                SizedBox(height: 10.0.h),
                            itemCount: budgets.length,
                          );
                        },
                      );
                    },
                  ),
                ),
                // FutureBuilder(
                //   future: _calculateTotalAmountLeft(
                //     total: _remainingAmount,
                //     remaining: _remainingAmount,
                //   ),
                //   builder: (context, snapshot) {
                //     if (!snapshot.hasData) {
                //       return const SizedBox();
                //     }

                //     bottomPart = snapshot.data as String;

                //     return Text(
                //       bottomPart ?? '',
                //       style: TextStyle(
                //         color: Colors.black,
                //         fontSize: 16.0.sp,
                //         fontWeight: FontWeight.w400,
                //       ),
                //     );
                //   },
                // ),
              ],
            ),
          );
  }
}
