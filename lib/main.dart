import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ─── Firestore Offline Persistence ─────────────────────────
  // Caches recently-read docs locally — no network needed on revisit
  final db = FirebaseFirestore.instance;
  await db.enablePersistence();

  // ─── Image Cache Config ────────────────────────────────────
  // 200MB disk cache, 200-image memory cache
  PaintingBinding.instance.imageCache.maximumSize = 200;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 200 << 20;

  runApp(
    const ProviderScope(
      child: KiloTapApp(),
    ),
  );
}
