// ignore_for_file: use_build_context_synchronously

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:budrate/services/app.dart';
import 'package:budrate/state/app_state.dart';
import 'package:budrate/widgets/drop_down_field.dart';
import 'package:budrate/widgets/input_field.dart';
import 'package:budrate/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditBudgetScreen extends ConsumerStatefulWidget {
  const EditBudgetScreen({super.key});

  @override
  ConsumerState<EditBudgetScreen> createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends ConsumerState<EditBudgetScreen> {
  Map<String, dynamic>? budget;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String? _currency;
  bool _loading = false;
  bool _loadingDelete = false;

  @override
  void initState() {
    super.initState();
    // Load initial values
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialValues());
  }

  @override
  void dispose() {
    // Dispose the controllers
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // Load initial values
  void _loadInitialValues() async {
    // Get the budget from the arguments
    budget = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _nameController.text = budget!['name'].toString();
    _amountController.text = budget!['amount'].toString();
    _currency = budget!['currency'].toString();
    setState(() {});
  }

  // Update budget to database
  void _update() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });
      // update budget to database
      await Supabase.instance.client.from('budgets').update({
        'name': _nameController.text,
        'currency': _currency,
        'amount': _amountController.text.replaceAll(',', ''),
      }).match({'id': budget!['id']});

      setState(() {
        _loading = false;
      });

      // show success message and clear form
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Budget updated successfully"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Delete budget from database
  void _delete() async {
    // Show loading indicator
    setState(() {
      _loadingDelete = true;
    });

    // delete budget from database
    await Supabase.instance.client
        .from('budgets')
        .delete()
        .eq('id', budget!['id']);

    // Hide loading indicator
    setState(() {
      _loadingDelete = false;
    });

    // Add activity to the user's activity feed
    ref
        .read(appApiProvider)
        .addActivity(title: "Edited budget ${_nameController.text}");

    // show success message and clear form
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Budget deleted successfully"),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffD8EBE9),
        title: const Text(
          "Edit Budget",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  // Build the body of the edit budget screen
  Widget _buildBody() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              InputField(
                controller: _nameController,
                hint: "Enter Budget Name",
                validator: (String? name) {
                  if (name!.isEmpty) {
                    return "Budget name cannot be empty";
                  }
                  return null;
                },
                label: "Budget Name",
              ),
              SizedBox(height: 20.0.h),
              DropDownField(
                data: ref.watch(currencies).map((e) => e.currency!).toList(),
                hint: "Select Currency",
                label: "Currency",
                selected: _currency,
                onChanged: (String? value) {
                  setState(() {
                    _currency = value;
                  });
                },
                validator: (String? value) {
                  if (value!.isEmpty) {
                    return "Currency is required";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0.h),
              InputField(
                controller: _amountController,
                hint: "Enter Amount",
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
                validator: (String? name) {
                  if (name!.isEmpty) {
                    return "Amount is required";
                  }
                  return null;
                },
                label: "Amount",
              ),
              SizedBox(height: 20.0.h),
              PrimaryButton(
                onPressed: _update,
                isLoading: _loading,
                buttonText: "Update Budget",
              ),
              SizedBox(height: 20.0.h),
              TextButton(
                onPressed: _delete,
                child: _loadingDelete
                    ? LoadingAnimationWidget.inkDrop(
                        color: Colors.white,
                        size: 18.0.w,
                      )
                    : const Text(
                        "Delete Budget",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
