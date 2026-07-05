import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'router.dart';
import 'core/theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Enable Firestore offline persistence — instant load after first open
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true, cacheSizeBytes: 104857600); // 100 MB
  runApp(const KiloTapApp());
}

class KiloTapApp extends StatelessWidget {
  const KiloTapApp({super.key});

  @override Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KiloTap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.canvas,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.sellerGreen),
        fontFamily: 'Arial',
        useMaterial3: true,
      ),
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: '/',
    );
  }
}
