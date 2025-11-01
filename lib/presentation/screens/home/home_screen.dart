import 'package:flutter/material.dart';
import 'package:gup_shup/data/services/service_locator.dart';
import 'package:gup_shup/logic/cubits/auth/auth_cubit.dart';
import 'package:gup_shup/presentation/screens/auth/login_screen.dart';
import 'package:gup_shup/router/app_router.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chats", style: TextStyle(fontSize: 24)),
        actions: [
          Padding(
            padding: EdgeInsetsGeometry.only(right: 15),
            child: InkWell(
              onTap: () async {
                await getIt<AuthCubit>().signOut();
                getIt<AppRouter>().pushAndRemoveUntil(const LoginScreen());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out successfully!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Icon(Icons.logout),
            ),
          ),
        ],
      ),
      body: Center(child: Text("User is authenticated ")),
      floatingActionButton: FloatingActionButton(onPressed: () {},child: Icon(Icons.chat,),foregroundColor: Colors.white,),
    );
  }
}
