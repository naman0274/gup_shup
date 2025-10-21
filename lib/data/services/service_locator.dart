import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:gup_shup/router/app_router.dart';

import '../../firebase_options.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async{
   WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
   );
   getIt.registerLazySingleton(() => AppRouter(),);

}