import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gup_shup/config/theme/app_theme.dart';
import 'package:gup_shup/core/common/custom_button.dart';
import 'package:gup_shup/core/common/custom_text_field.dart';
import 'package:gup_shup/presentation/screens/auth/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  final _nameFocus = FocusNode();
  final _userNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    nameController.dispose();
    userNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();

    _nameFocus.dispose();
    _userNameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your full name";
    }
    return null;
  }

  String? _validateUserName (String? value){
    if (value == null || value.isEmpty){
      return "Please enter your Username";
    }
    return null;
  }
  String? _validateEmail (String? value){
    if (value == null || value.isEmpty){
      return "Please enter your Username";
    }
    return null;
  }
  String? _validatePhone (String? value){
    if (value == null || value.isEmpty){
      return "Please enter your Username";
    }
    return null;
  }
  String? _validatePassword (String? value){
    if (value == null || value.isEmpty){
      return "Please enter your Username";
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Create Account",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Please fill in the details to continue",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                ),
                SizedBox(height: 30),
                CustomTextField(
                  controller: nameController,
                  hintText: "Full Name",
                  prefixIcon: Icon(Icons.person_outline),
                  focusNode: _nameFocus,
                  validator: _validateName,
                ),
                SizedBox(height: 16),
                CustomTextField(
                  controller: userNameController,
                  hintText: "Usermame",
                  prefixIcon: Icon(Icons.alternate_email_outlined),
                  focusNode: _userNameFocus,
                  validator: _validateUserName,
                ),
                SizedBox(height: 16),
                CustomTextField(
                  controller: emailController,
                  hintText: "Email",
                  prefixIcon: Icon(Icons.email_outlined),
                  focusNode: _emailFocus,
                  validator: _validateEmail,
                ),
                SizedBox(height: 16),
                CustomTextField(
                  controller: phoneController,
                  hintText: "Phone Number",
                  prefixIcon: Icon(Icons.phone_outlined),
                  focusNode: _phoneFocus,
                  validator: _validatePhone,
                ),
                SizedBox(height: 16),
                CustomTextField(
                  controller: passwordController,
                  hintText: "Password",
                  prefixIcon: Icon(Icons.lock_outlined),
                  suffixIcon: Icon(Icons.remove_red_eye_outlined),
                  obscureText: true,
                  focusNode: _passwordFocus,
                  validator: _validatePassword,
                ),
                SizedBox(height: 24),
                CustomButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    if (_formKey.currentState?.validate() ?? false) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    }
                  },
                  text: ("Create Account"),
                ),
                SizedBox(height: 24),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: ("Already have an account? "),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      children: [
                        TextSpan(
                          text: ("Login"),
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pop(context);
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
