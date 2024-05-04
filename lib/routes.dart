import 'package:budrate/features/authentication/initiate_reset_password.dart';
import 'package:budrate/features/authentication/reset_password.dart';
import 'package:budrate/features/budget/add.dart';
import 'package:budrate/features/budget/edit.dart';
import 'package:budrate/features/change_currency/change_currency.dart';
import 'package:budrate/features/profile/profile.dart';
import 'package:budrate/features/savings/savings.dart';
import 'package:budrate/features/what_if/what_if.dart';
import 'package:flutter/material.dart';

import 'features/authentication/authentication.dart';
import 'features/authentication/sign_in.dart';
import 'features/authentication/sign_up.dart';
import 'features/dashboard/dashboard.dart';

class AppRoutes {
  // Define routes
  static Map<String, WidgetBuilder> routes = {
    authentication: (context) => const AuthenticationScreen(),
    signIn: (context) => const SignInScreen(),
    signUp: (context) => const SignUpScreen(),
    dashboard: (context) => const DashboardScreen(),
    addBudget: (context) => const AddBudgetScreen(),
    editBudget: (context) => const EditBudgetScreen(),
    topUpSaving: (context) => const SavingBudgetScreen(),
    profile: (context) => const ProfileScreen(),
    initiateResetPassword: (context) => const InitiatePasswordResetScreen(),
    resetPassword: (context) => const ResetPasswordScreen(),
    whatIf: (context) => const WhatIfScreen(),
    changeCurrency: (context) => const ChangeCurrencyScreen(),
  };

  // Define paths
  static String authentication = '/';
  static String signIn = '/sign-in';
  static String signUp = '/sign-up';
  static String dashboard = '/dashboard';
  static String addBudget = '/add-budget';
  static String editBudget = '/edit-budget';
  static String topUpSaving = '/top-up-saving';
  static String profile = '/profile';
  static String initiateResetPassword = '/initiate-reset-password';
  static String resetPassword = '/reset-password';
  static String whatIf = '/whatIf';
  static String changeCurrency = '/changeCurrency';
}
