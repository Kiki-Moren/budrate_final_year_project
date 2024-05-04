// ignore_for_file: use_build_context_synchronously

import 'package:budrate/state/app_state.dart';
import 'package:budrate/widgets/drop_down_field.dart';
import 'package:budrate/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../routes.dart';
import '../../widgets/input_field.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fistNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _currency;
  bool _loading = false;

  @override
  void dispose() {
    // Dispose the controllers
    _fistNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _signUp() async {
    // Validate the form
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });

      // Sign up the user
      try {
        final response = await Supabase.instance.client.auth.signUp(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Hide the loading indicator
        setState(() {
          _loading = false;
        });

        if (response.session != null) {
          // Insert the user into the database
          final user = response.user;
          await Supabase.instance.client.from('users').insert({
            'user_id': user!.id,
            'first_name': _fistNameController.text,
            'last_name': _lastNameController.text,
            'username': _usernameController.text,
            'email': _emailController.text,
            'base_currency': _currency,
          });

          // Navigate to the dashboard
          Navigator.of(context)
              .pushNamedAndRemoveUntil(AppRoutes.dashboard, (route) => false);
        } else {
          // Show a snackbar with the error message
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Sign up failed")));
        }
      } catch (e) {
        AuthException authException = e as AuthException;

        setState(() {
          _loading = false;
        });

        // Show a snackbar with the error message
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(authException.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody());
  }

  // Build the body of the sign up screen
  Widget _buildBody() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 10.0.h),
              Image.asset(
                "assets/images/app_icon1.png",
                width: 180.0.w,
                height: 180.0.w,
              ),
              SizedBox(height: 30.0.h),
              Text(
                "SIGN UP",
                style: TextStyle(
                  fontSize: 32.0.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                "Please sign up to enjoy all BUDRATE features",
                style: TextStyle(
                  fontSize: 16.0.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 20.0.h),
              InputField(
                controller: _usernameController,
                hint: "john",
                label: "Username",
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Username is required";
                  }
                  return null;
                },
              ),
              SizedBox(height: 15.0.h),
              InputField(
                controller: _fistNameController,
                hint: "john",
                label: "First name",
                validator: (value) {
                  if (value!.isEmpty) {
                    return "First name is required";
                  }
                  return null;
                },
              ),
              SizedBox(height: 15.0.h),
              InputField(
                controller: _lastNameController,
                hint: "emeka",
                label: "Last name",
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Last name is required";
                  }
                  return null;
                },
              ),
              SizedBox(height: 15.0.h),
              InputField(
                controller: _emailController,
                hint: "johndoe@gmail.com",
                label: "Email Address",
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Email is required";
                  }
                  return null;
                },
              ),
              SizedBox(height: 15.0.h),
              DropDownField(
                validator: (String? value) {
                  if (value == null) {
                    return "Base Currency is required";
                  }
                  return null;
                },
                data: ref.watch(currencies).map((e) => e.currency!).toList(),
                hint: "Select Base Currency",
                selected: _currency,
                label: "Base Currency",
                onChanged: (String? value) {
                  setState(() {
                    _currency = value;
                  });
                },
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
                controller: _confirmController,
                hint: "**********",
                label: "Confirm Password",
                validator: (value) {
                  if (_passwordController.text != value) {
                    return "Confirm Password does not match";
                  }
                  return null;
                },
              ),
              SizedBox(height: 15.0.h),
              PrimaryButton(
                isLoading: _loading,
                onPressed: _signUp,
                buttonText: "SIGN UP",
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.signIn),
                child: Text(
                  "Have An Account? Sign In",
                  style: TextStyle(
                    fontSize: 16.0.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
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
