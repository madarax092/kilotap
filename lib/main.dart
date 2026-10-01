import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'firebase_options.dart';
import 'router.dart';
import 'core/theme/app_colors.dart';
import 'services/cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Forces hybrid composition instead of the default TextureView rendering —
  // on some Android devices (MIUI/Xiaomi included) the default mode loads
  // the map SDK successfully but never actually paints any tiles.
  if (Platform.isAndroid) {
    final mapsImplementation = GoogleMapsFlutterPlatform.instance;
    if (mapsImplementation is GoogleMapsFlutterAndroid) {
      mapsImplementation.useAndroidViewSurface = true;
    }
  }

  await CacheService.instance.init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true, cacheSizeBytes: 104857600);
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
