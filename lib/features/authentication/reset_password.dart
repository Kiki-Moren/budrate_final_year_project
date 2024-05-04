// ignore_for_file: use_build_context_synchronously

import 'package:budrate/routes.dart';
import 'package:budrate/widgets/input_field.dart';
import 'package:budrate/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // set the email of the user on the screen after loading the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emailController.text =
          ModalRoute.of(context)!.settings.arguments as String;
    });
  }

  @override
  void dispose() {
    // dispose controllers
    _emailController.dispose();
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _resetPassword() async {
    // Validate the form
    if (_formKey.currentState!.validate()) {
      // Show the loading indicator
      setState(() {
        _loading = true;
      });

      // Send the password reset email
      try {
        await Supabase.instance.client.auth.verifyOTP(
          email: _emailController.text,
          token: _tokenController.text,
          type: OtpType.recovery,
        );

        // Update the user's password
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(password: _passwordController.text),
        );

        // navigate to the sign in screen
        Navigator.of(context)
            .pushNamedAndRemoveUntil(AppRoutes.signIn, (route) => false);
      } catch (e) {
        // Show a snackbar if the password reset failed
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Password reset failed")));
      }

      // Hide the loading indicator
      setState(() {
        _loading = false;
      });
    }
  }

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
                hint: "",
                notEditable: true,
                validator: (String? email) {
                  if (email!.isEmpty) {
                    return "Email cannot be empty";
                  }
                  return null;
                },
                label: "Email",
              ),
              SizedBox(height: 15.0.h),
              InputField(
                controller: _tokenController,
                hint: "Teset Token",
                validator: (String? email) {
                  if (email!.isEmpty) {
                    return "Token cannot be empty";
                  }
                  return null;
                },
                label: "Token",
              ),
              SizedBox(height: 15.0.h),
              InputField(
                controller: _passwordController,
                hint: "**********",
                label: "Password",
                validator: (value) {
                  if (value!.isEmpty && value.length < 6) {
                    return "Password is required and must be at least 6 characters";
                  }
                  return null;
                },
              ),
              SizedBox(height: 15.0.h),
              InputField(
                controller: _confirmPassword,
                hint: "**********",
                label: "Confirm Password",
                validator: (value) {
                  if (_passwordController.text != value) {
                    return "Confirm Password does not match";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0.h),
              PrimaryButton(
                onPressed: _resetPassword,
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
