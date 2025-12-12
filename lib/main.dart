import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
//import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/makers_screen.dart';
import 'screens/models_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "",
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
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => MakersScreen()),
        GoRoute(
          path: '/models/:makerId',
          builder: (context, state) {
            final makerId = state.pathParameters['makerId']!;
            final makerName = state.uri.queryParameters['makerName'] ?? '';
            return ModelsScreen(makerId: makerId, makerName: makerName);
          },
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Car Bidding System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
