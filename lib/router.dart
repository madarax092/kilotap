import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'screens/landing/landing_screen.dart';
import 'screens/auth/seller_auth_screen.dart';
import 'screens/auth/buyer_auth_screen.dart';
import 'screens/seller/seller_home_screen.dart';
import 'screens/seller/book_pickup_screen.dart';
import 'screens/seller/seller_history_screen.dart';
import 'screens/seller/seller_settings_screen.dart';
import 'screens/buyer/buyer_home_screen.dart';
import 'screens/buyer/buyer_history_screen.dart';
import 'screens/buyer/buyer_settings_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == '/' ||
          state.matchedLocation == '/seller-auth' ||
          state.matchedLocation == '/buyer-auth';

      // If not logged in and not on auth routes, redirect to landing
      if (!isLoggedIn && !isAuthRoute) return '/';
      return null;
    },
    routes: [
      // ─── Landing ──────────────────────────────────────────────────────────
      GoRoute(
        path: '/',
        name: 'landing',
        builder: (context, state) => const LandingScreen(),
      ),

      // ─── Auth ─────────────────────────────────────────────────────────────
      GoRoute(
        path: '/seller-auth',
        name: 'seller-auth',
        builder: (context, state) => const SellerAuthScreen(),
      ),
      GoRoute(
        path: '/buyer-auth',
        name: 'buyer-auth',
        builder: (context, state) => const BuyerAuthScreen(),
      ),

      // ─── Seller ───────────────────────────────────────────────────────────
      GoRoute(
        path: '/seller-home',
        name: 'seller-home',
        builder: (context, state) => const SellerHomeScreen(),
      ),
      GoRoute(
        path: '/book-pickup',
        name: 'book-pickup',
        builder: (context, state) => const BookPickupScreen(),
      ),
      GoRoute(
        path: '/seller-history',
        name: 'seller-history',
        builder: (context, state) => const SellerHistoryScreen(),
      ),
      GoRoute(
        path: '/seller-settings',
        name: 'seller-settings',
        builder: (context, state) => const SellerSettingsScreen(),
      ),

      // ─── Buyer ────────────────────────────────────────────────────────────
      GoRoute(
        path: '/buyer-home',
        name: 'buyer-home',
        builder: (context, state) => const BuyerHomeScreen(),
      ),
      GoRoute(
        path: '/buyer-history',
        name: 'buyer-history',
        builder: (context, state) => const BuyerHistoryScreen(),
      ),
      GoRoute(
        path: '/buyer-settings',
        name: 'buyer-settings',
        builder: (context, state) => const BuyerSettingsScreen(),
      ),
    ],
  );
});
