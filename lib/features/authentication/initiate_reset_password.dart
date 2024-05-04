// ignore_for_file: use_build_context_synchronously

import 'package:budrate/routes.dart';
import 'package:budrate/widgets/input_field.dart';
import 'package:budrate/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InitiatePasswordResetScreen extends ConsumerStatefulWidget {
  const InitiatePasswordResetScreen({super.key});

  @override
  ConsumerState<InitiatePasswordResetScreen> createState() =>
      _InitiatePasswordResetScreenState();
}

class _InitiatePasswordResetScreenState
    extends ConsumerState<InitiatePasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    // Dispose the controllers
    _emailController.dispose();
    super.dispose();
  }

  void _initiate() async {
    // Validate the form
    if (_formKey.currentState!.validate()) {
      // Show the loading indicator
      setState(() {
        _loading = true;
      });
      // Send the password reset email
      await Supabase.instance.client.auth.resetPasswordForEmail(
        _emailController.text,
      );
      // Hide the loading indicator
      setState(() {
        _loading = false;
      });
      // Navigate to the reset password screen
      Navigator.of(context).pushNamed(
        AppRoutes.resetPassword,
        arguments: _emailController.text,
      );
    }
  }

  // Build the body of the reset password screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffD8EBE9),
        title: const Text(
          "Buddrate Reset Password",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  // Build the body of the reset password screen
  Widget _buildBody() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              InputField(
                controller: _emailController,
                hint: "Enter Email",
                validator: (String? email) {
                  if (email!.isEmpty) {
                    return "Email cannot be empty";
                  }
                  return null;
                },
                label: "Email",
              ),
              SizedBox(height: 20.0.h),
              PrimaryButton(
                onPressed: _initiate,
                isLoading: _loading,
                buttonText: "Reset Password",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
