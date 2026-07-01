import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pickup_model.dart';
import '../models/market_price_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

// ─── Market Prices ────────────────────────────────────────────────────────────
final marketPricesProvider = StreamProvider<List<MarketPriceModel>>((ref) {
  try {
    return ref.watch(firestoreServiceProvider).getMarketPrices();
  } catch (_) {
    // Return defaults when Firestore is not configured
    return Stream.value(MarketPriceModel.defaults);
  }
});

// ─── Seller Pickups ───────────────────────────────────────────────────────────
final sellerPickupsProvider = StreamProvider<List<PickupModel>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).getSellerRecentPickups(user.uid);
});

final sellerPickupHistoryProvider = StreamProvider<List<PickupModel>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).getSellerPickupHistory(user.uid);
});

// ─── Seller Total Earnings ────────────────────────────────────────────────────
final sellerTotalEarningsProvider = Provider<double>((ref) {
  final history = ref.watch(sellerPickupHistoryProvider).valueOrNull ?? [];
  return history.fold(0.0, (sum, p) => sum + (p.actualValue ?? p.estimatedValue));
});

// ─── Book Pickup Notifier ─────────────────────────────────────────────────────
class BookPickupNotifier extends StateNotifier<AsyncValue<void>> {
  final FirestoreService _firestoreService;

  BookPickupNotifier(this._firestoreService) : super(const AsyncValue.data(null));

  Future<bool> bookPickup({
    required String sellerId,
    required String sellerName,
    required String scrapType,
    required String scrapTypeIcon,
    required double estimatedWeightKg,
    required double estimatedValue,
    required String address,
    required DateTime scheduledAt,
    required String timeSlot,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      final pickup = PickupModel(
        id: '',
        sellerId: sellerId,
        sellerName: sellerName,
        scrapType: scrapType,
        scrapTypeIcon: scrapTypeIcon,
        estimatedWeightKg: estimatedWeightKg,
        estimatedValue: estimatedValue,
        address: address,
        scheduledAt: scheduledAt,
        timeSlot: timeSlot,
        status: PickupStatus.pending,
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestoreService.createPickup(pickup);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final bookPickupProvider =
    StateNotifierProvider<BookPickupNotifier, AsyncValue<void>>((ref) {
  return BookPickupNotifier(ref.watch(firestoreServiceProvider));
});
