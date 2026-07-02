import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

Widget stubScreen(String title, Color accent, {String? subtitle}) {
  return Scaffold(
    backgroundColor: AppColors.canvas,
    appBar: AppBar(backgroundColor: AppColors.canvas, elevation: 0, title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)), leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), onPressed: () => Navigator.pop(ctx)))),
    body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.construction, size: 48, color: accent),
      const SizedBox(height: 12),
      Text(subtitle ?? 'Coming soon', style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
    ])),
  );
}
