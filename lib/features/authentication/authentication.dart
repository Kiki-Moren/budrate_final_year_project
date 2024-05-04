import 'package:budrate/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../routes.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  // Build the authentication screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody());
  }

  // Build the body of the authentication screen
  Widget _buildBody() {
    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30.0.r),
              child: Image.asset(
                "assets/images/app_icon.png",
                width: 180.0.w,
                height: 180.0.w,
              ),
            ),
            SizedBox(height: 100.0.h),
            PrimaryButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.signIn),
              buttonText: "LOG IN",
            ),
            SizedBox(height: 20.0.h),
            PrimaryButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.signUp),
              buttonText: "SIGN UP",
            ),
          ],
        ),
      ),
    );
  }
}
