import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pickup_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

// ─── Buyer Online Status ──────────────────────────────────────────────────────
final buyerIsOnlineProvider = StateProvider<bool>((ref) => false);

// ─── Buyer Earnings History ───────────────────────────────────────────────────
final buyerEarningsHistoryProvider = StreamProvider<List<PickupModel>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).getBuyerEarningsHistory(user.uid);
});

// ─── Buyer Today's Earnings ───────────────────────────────────────────────────
final buyerTodayEarningsProvider = FutureProvider<double>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return 0.0;
  try {
    return await ref
        .watch(firestoreServiceProvider)
        .getBuyerTodayEarnings(user.uid);
  } catch (_) {
    return 0.0;
  }
});

// ─── Buyer Total Earnings ─────────────────────────────────────────────────────
final buyerTotalEarningsProvider = Provider<double>((ref) {
  final history = ref.watch(buyerEarningsHistoryProvider).valueOrNull ?? [];
  return history.fold(0.0, (sum, p) => sum + (p.actualValue ?? p.estimatedValue));
});

// ─── Available Pickups (for buyers to accept) ─────────────────────────────────
final availablePickupsProvider = StreamProvider<List<PickupModel>>((ref) {
  final isOnline = ref.watch(buyerIsOnlineProvider);
  if (!isOnline) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).getAvailablePickups();
});

// ─── Accept Pickup Notifier ───────────────────────────────────────────────────
class AcceptPickupNotifier extends StateNotifier<AsyncValue<void>> {
  final FirestoreService _firestoreService;

  AcceptPickupNotifier(this._firestoreService) : super(const AsyncValue.data(null));

  Future<void> acceptPickup({
    required String pickupId,
    required String buyerId,
    required String buyerName,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _firestoreService.updatePickupStatus(
        pickupId,
        PickupStatus.assigned,
        buyerId: buyerId,
        buyerName: buyerName,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> completePickup({
    required String pickupId,
    required double actualWeight,
    required double actualValue,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _firestoreService.updatePickupStatus(pickupId, PickupStatus.completed);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final acceptPickupProvider =
    StateNotifierProvider<AcceptPickupNotifier, AsyncValue<void>>((ref) {
  return AcceptPickupNotifier(ref.watch(firestoreServiceProvider));
});
