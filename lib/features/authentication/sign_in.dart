// ignore_for_file: use_build_context_synchronously

import 'package:budrate/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../routes.dart';
import '../../widgets/input_field.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    // Dispose the controllers
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _logIn() async {
    // Validate the form
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });

      // Sign in the user
      try {
        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Hide the loading indicator
        setState(() {
          _loading = false;
        });

        if (response.session != null) {
          // Navigate to the dashboard
          Navigator.of(context)
              .pushNamedAndRemoveUntil(AppRoutes.dashboard, (route) => false);
        } else {
          // Show a snackbar with the error message
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Sign in failed")));
        }
      } catch (error) {
        AuthException authException = error as AuthException;

        // Hide the loading indicator
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

  // Build the body of the authentication screen
  Widget _buildBody() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 10.0.h),
              Center(
                child: Container(
                  width: 270.0.w,
                  height: 240.0.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0.r),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 3.0),
                        blurRadius: 5.0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "WELCOME\nBACK",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24.0.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30.0.h),
              Text(
                "SIGN IN",
                style: TextStyle(
                  fontSize: 32.0.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 20.0.h),
              InputField(
                controller: _emailController,
                hint: "johndoe@gmail.com",
                label: "Email",
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Email is required";
                  }
                  return null;
                },
              ),
              SizedBox(height: 15.0.h),
              InputField(
                controller: _passwordController,
                hint: "**********",
                label: "Password",
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Password is required";
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed(AppRoutes.initiateResetPassword);
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        fontSize: 16.0.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15.0.h),
              PrimaryButton(
                onPressed: _logIn,
                isLoading: _loading,
                buttonText: "SIGN IN",
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.signUp),
                child: Text(
                  "Don't Have An Account? Sign Up",
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
