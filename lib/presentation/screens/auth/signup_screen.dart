import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gup_shup/config/theme/app_theme.dart';
import 'package:gup_shup/core/common/custom_button.dart';
import 'package:gup_shup/core/common/custom_text_field.dart';
import 'package:gup_shup/core/utils/ui_utils.dart';
import 'package:gup_shup/data/repositories/auth_repository.dart';
import 'package:gup_shup/data/services/service_locator.dart';
import 'package:gup_shup/logic/cubits/auth/auth_cubit.dart';
import 'package:gup_shup/logic/cubits/auth/auth_state.dart';
import 'package:gup_shup/presentation/screens/auth/login_screen.dart';
import 'package:gup_shup/presentation/screens/home/home_screen.dart';
import 'package:gup_shup/router/app_router.dart';

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

  bool _isPasswordVisible = true;

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

  String? _validateUserName(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your Username";
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your Email";
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return "Please enter valid Email";
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your Phone number";
    }
    final phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');
    if (!phoneRegex.hasMatch(value)) {
      return "Please Enter valid number";
    }
    return null;
  }

  Future<void> handleSignUp() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      try {
       await getIt<AuthCubit>().signUp(
          fullName: nameController.text,
          username: userNameController.text,
          email: emailController.text,
          phoneNumber: phoneController.text,
          password: passwordController.text,
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } else {
      print("form validation failed");
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your password";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
        bloc: getIt<AuthCubit>(),
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            getIt<AppRouter>().pushAndRemoveUntil(HomeScreen());
          } else if (state.status  == AuthStatus.error && state.error!= null) {
            UiUtils.showSnackBar(context, message: state.error!);
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 30,),
                        Text(
                          "Create Account",
                          style: Theme
                              .of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Please fill in the details to continue",
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                            color: Colors.grey.shade600,
                          ),
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
                          obscureText: !_isPasswordVisible,
                          prefixIcon: Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),

                          focusNode: _passwordFocus,
                          validator: _validatePassword,
                        ),
                        SizedBox(height: 24),
                        CustomButton(
                          onPressed: handleSignUp,

                          text: ("Create Account"),
                        ),
                        SizedBox(height: 24),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: ("Already have an account? "),
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: Colors.grey.shade600),
                              children: [
                                TextSpan(
                                  text: ("Login"),
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                    color: Theme
                                        .of(context)
                                        .primaryColor,
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
            ),
          );
        }
    );
  }
}
