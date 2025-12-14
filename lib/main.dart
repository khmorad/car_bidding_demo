import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';

//import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'router/app_router.dart';
import 'bloc/auth_cubit.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyCcg47oBxp8GYlBe7QaQQVv8-I4kKDdPxM",
        authDomain: "car-bidding-demo.firebaseapp.com",
        projectId: "car-bidding-demo",
        storageBucket: "car-bidding-demo.firebasestorage.app",
        messagingSenderId: "159466669112",
        appId: "1:159466669112:web:83642a4652d7990c8712cd",
        measurementId: "G-44B35KCTY4",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(AuthService()),
      child: MaterialApp.router(
        title: 'Car Bidding System',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
