// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:budrate/services/app.dart';
import 'package:budrate/state/app_state.dart';
import 'package:budrate/widgets/drop_down_field.dart';
import 'package:budrate/widgets/input_field.dart';
import 'package:budrate/widgets/primary_button.dart';
import 'package:budrate/widgets/upload_document.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddBudgetScreen extends ConsumerStatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  ConsumerState<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends ConsumerState<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String? _currency;
  bool _loading = false;
  File? _image;
  String? _error;

  @override
  void dispose() {
    // Dispose the controllers
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // Save budget to database
  void _saveBudget() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });

      if (_image == null) return;

      // Get the current user
      final user = Supabase.instance.client.auth.currentUser;
      // Upload image to Supabase Storage
      final imagePath = await uploadImage();
      if (imagePath != null) {
        // Save budget to database
        await Supabase.instance.client.from('budgets').insert({
          'user_id': user!.id,
          'name': _nameController.text,
          'currency': _currency,
          'amount': _amountController.text.replaceAll(',', ''),
          'image': imagePath,
        });

        // Hide the loading indicator
        setState(() {
          _loading = false;
        });

        // Add activity to the user's activity feed
        ref
            .read(appApiProvider)
            .addActivity(title: "Added budget ${_nameController.text}");

        // show success message and clear form
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Budget saved successfully"),
            backgroundColor: Colors.green,
          ),
        );
        // Clear the form
        _amountController.clear();
        _nameController.clear();
      } else {
        // Hide the loading indicator
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // Upload image to Supabase Storage
  Future<String?> uploadImage() async {
    // // Upload image to Supabase Storage
    // // Replace 'imagePath' with the actual path of the image file
    try {
      final response =
          await Supabase.instance.client.storage.from('budrate-images').upload(
                'budgets/${DateTime.now().millisecondsSinceEpoch}.png',
                _image!,
              );
      return response;
    } catch (e) {
      // Show a snackbar if the image upload failed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error uploading image"),
          backgroundColor: Colors.red,
        ),
      );

      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffD8EBE9),
        title: const Text(
          "Add Budget",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  // Build the body of the add budget screen
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
                    return "Budget name is required";
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
              UploadDocumentWidget(
                hint: "Upload Image",
                image: _image,
                error: _error,
                onTap: ({File? file}) {
                  setState(() {
                    _image = file;
                  });
                },
              ),
              SizedBox(height: 20.0.h),
              PrimaryButton(
                onPressed: _saveBudget,
                isLoading: _loading,
                buttonText: "Save",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
