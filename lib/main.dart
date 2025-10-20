import 'package:flutter/material.dart';
import 'package:gup_shup/config/theme/app_theme.dart';
import 'package:gup_shup/data/repositories/auth_repository.dart';
import 'package:gup_shup/presentation/screens/auth/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Messenger App',

      theme: AppTheme.lightTheme,
      home: LoginScreen(),
    );
  }
}

class MyHomePage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("hwello"),
        backgroundColor: Colors.orange,
      ),

    );
  }
}

