import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //test
  // Web requires FirebaseOptions
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBsKijSegp3LDk21xCqNL-RMcMULVmMsGQ",
        authDomain: "car-bidding-demo.firebaseapp.com",
        projectId: "car-bidding-demo",
        storageBucket: "car-bidding-demo.firebasestorage.app",
        messagingSenderId: "159466669112",
        appId: "1:159466669112:web:83642a4652d7990c8712cd",
        measurementId: "G-44B35KCTY4",
      ),
    );
  } else {
    // Android/iOS/macOS use google-services.json or plist
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Bidding System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Car Bidding System')),
      body: const Center(
        child: Text(
          "Firebase Connected ✔ (Web)",
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
