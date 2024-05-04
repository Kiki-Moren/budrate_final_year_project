// ignore_for_file: use_build_context_synchronously

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:budrate/services/app.dart';
import 'package:budrate/widgets/input_field.dart';
import 'package:budrate/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SavingBudgetScreen extends ConsumerStatefulWidget {
  const SavingBudgetScreen({super.key});

  @override
  ConsumerState<SavingBudgetScreen> createState() => _SavingBudgetScreenState();
}

class _SavingBudgetScreenState extends ConsumerState<SavingBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    // Dispose the controllers
    _amountController.dispose();
    super.dispose();
  }

  // Top up savings
  void _topUpSavings() async {
    if (_formKey.currentState!.validate()) {
      // Show the loading indicator
      setState(() {
        _isLoading = true;
      });

      // Get the current user's savings
      final savings = await Supabase.instance.client
          .from('savings')
          .select()
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
          .single();

      // Update the savings
      await Supabase.instance.client.from('savings').upsert({
        'id': savings['id'],
        'amount': savings['amount'] +
            double.parse(_amountController.text.replaceAll(',', '')),
      });

      // Hide the loading indicator
      setState(() {
        _isLoading = false;
      });

      // Add activity
      ref.read(appApiProvider).addActivity(
          title: "Topped up savings with ${_amountController.text}");

      // Show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Savings topped up successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  // Reduce savings
  void _reduceSavings() async {
    if (_formKey.currentState!.validate()) {
      // Show the loading indicator
      setState(() {
        _isLoading = true;
      });

      // Get the current user's savings
      final savings = await Supabase.instance.client
          .from('savings')
          .select()
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
          .single();

      // Check if the user has enough funds
      if (savings['amount'] <
          double.parse(_amountController.text.replaceAll(',', ''))) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Insufficient funds"),
            backgroundColor: Colors.red,
          ),
        );

        // Hide the loading indicator
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Update the savings
      await Supabase.instance.client.from('savings').upsert({
        'id': savings['id'],
        'amount': savings['amount'] -
            double.parse(_amountController.text.replaceAll(',', '')),
      });

      // Hide the loading indicator
      setState(() {
        _isLoading = false;
      });

      // Add activity
      ref
          .read(appApiProvider)
          .addActivity(title: "Reduced savings with ${_amountController.text}");

      // Show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Savings reduced up successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffD8EBE9),
        title: const Text(
          "Top Up Savings",
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
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              InputField(
                controller: _amountController,
                hint: "Enter Amount to top up",
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
                validator: (String? value) {
                  if (value!.isEmpty) {
                    return "Amount is required";
                  }
                  return null;
                },
                label: "Amount",
              ),
              SizedBox(height: 20.0.h),
              _isLoading
                  ? Center(
                      child: LoadingAnimationWidget.discreteCircle(
                        color: const Color(0xffD8EBE9),
                        size: 30.0.w,
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            onPressed: _topUpSavings,
                            buttonText: "Top Up Savings",
                          ),
                        ),
                        SizedBox(width: 20.0.w),
                        Expanded(
                          child: PrimaryButton(
                            onPressed: _reduceSavings,
                            buttonText: "Reduce Savings",
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
