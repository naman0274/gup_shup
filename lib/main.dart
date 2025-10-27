import 'package:flutter/material.dart';
import 'package:gup_shup/config/theme/app_theme.dart';
import 'package:gup_shup/data/services/service_locator.dart';
import 'package:gup_shup/presentation/screens/splash_screen.dart';
import 'package:gup_shup/router/app_router.dart';


void main() async{
  await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: getIt<AppRouter>().navigatorKey,
      title: 'Messenger App',

      theme: AppTheme.lightTheme,
      home: SplashScreen(),
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

