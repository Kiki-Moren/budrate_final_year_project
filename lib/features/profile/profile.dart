// ignore_for_file: use_build_context_synchronously

import 'package:budrate/widgets/input_field.dart';
import 'package:budrate/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Load initial values
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialValues());
  }

  @override
  void dispose() {
    // Dispose the controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Load initial values
  void _loadInitialValues() async {
    // Get the current user
    final user = await Supabase.instance.client
        .from('users')
        .select()
        .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
        .single();

    _firstNameController.text = user['first_name'].toString();
    _lastNameController.text = user['last_name'].toString();
    _usernameController.text = user['username'].toString();
    _emailController.text = user['email'].toString();
  }

  // Update profile
  void _update() async {
    if (_formKey.currentState!.validate()) {
      // Show loading indicator
      setState(() {
        _loading = true;
      });
      // update budget to database
      await Supabase.instance.client.from('users').update({
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'username': _usernameController.text,
        'email': _emailController.text,
      }).match({'user_id': Supabase.instance.client.auth.currentUser!.id});

      // Hide loading indicator
      setState(() {
        _loading = false;
      });

      // show success message and clear form
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Build the body of the screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffD8EBE9),
        title: const Text(
          "Profile Information",
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
                controller: _firstNameController,
                hint: "Enter First Name",
                validator: (String? name) {
                  if (name!.isEmpty) {
                    return "First name cannot be empty";
                  }
                  return null;
                },
                label: "First Name",
              ),
              SizedBox(height: 20.0.h),
              InputField(
                controller: _lastNameController,
                hint: "Enter Last Name",
                validator: (String? name) {
                  if (name!.isEmpty) {
                    return "Last name cannot be empty";
                  }
                  return null;
                },
                label: "Last Name",
              ),
              SizedBox(height: 20.0.h),
              InputField(
                controller: _usernameController,
                hint: "Enter Username",
                validator: (String? name) {
                  if (name!.isEmpty) {
                    return "Username cannot be empty";
                  }
                  return null;
                },
                label: "Username",
              ),
              SizedBox(height: 20.0.h),
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
                onPressed: _update,
                isLoading: _loading,
                buttonText: "Update Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
