import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/date_format.dart';
import '../../core/theme/app_colors.dart';
import '../../models/booking.dart';
import '../../models/booking_item.dart';
import '../../services/auth_state.dart';
import '../../services/firestore_service.dart';

/// Digital transaction pass (paper 2.1.1.7 / 2.1.3.1.12): what a collector
/// shows at a subdivision gate as live proof of an app-verified pickup.
/// Validity and time update on screen, so a screenshot is easy to tell apart.
class BookingPassScreen extends StatefulWidget {
  const BookingPassScreen({super.key});

  @override
  State<BookingPassScreen> createState() => _BookingPassScreenState();
}

class _BookingPassScreenState extends State<BookingPassScreen> {
  final _svc = FirestoreService();
  String? _bookingId;
  Stream<Booking?>? _booking;
  Stream<List<BookingItem>>? _items;
  Future<String>? _householdName;
  String? _householdSellerId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bookingId != null) return;
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            const {};
    _bookingId = args['bookingId'] as String?;
    if (_bookingId != null) {
      _booking = _svc.bookingStream(_bookingId!);
      _items = _svc.bookingItems(_bookingId!);
    }
  }

  Future<String> _nameFor(String sellerId) {
    if (_householdSellerId != sellerId || _householdName == null) {
      _householdSellerId = sellerId;
      _householdName = _svc.displayNameFor(sellerId);
    }
    return _householdName!;
  }

  // Null when the pass is valid; otherwise why it is not.
  String? _invalidReason(Booking b) {
    final auth = AuthState.instance;
    if (b.collectorId != auth.uid) {
      return 'This booking is assigned to another collector.';
    }
    if (auth.verificationStatus != AppConstants.verifyVerified) {
      return 'This collector is not verified.';
    }
    switch (b.status) {
      case AppConstants.statusAccepted:
        return null;
      case AppConstants.statusCompleted:
        return 'This pickup is already completed.';
      case AppConstants.statusCancelled:
        return 'This booking was cancelled.';
      default:
        return 'This booking has not been accepted yet.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: const Text('Booking Pass',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: _booking == null
          ? const Center(child: Text('No booking selected.'))
          : StreamBuilder<Booking?>(
              stream: _booking,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting &&
                    !snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final booking = snap.data;
                if (booking == null) {
                  return const Center(child: Text('Booking not found.'));
                }
                return _buildPass(booking);
              },
            ),
    );
  }

  Widget _buildPass(Booking booking) {
    final reason = _invalidReason(booking);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      children: [
        _StatusBanner(valid: reason == null, reason: reason),
        const SizedBox(height: 16),
        const _CollectorCard(),
        const SizedBox(height: 16),
        _Section(
          title: 'PICKUP',
          child: FutureBuilder<String>(
            future: _nameFor(booking.sellerId),
            builder: (context, nameSnap) {
              return Column(children: [
                _Row('Booking ID', booking.bookingId),
                _Row('Household', nameSnap.data ?? 'Loading...'),
                _Row(
                    'Pickup address',
                    booking.pickupAddress.isEmpty
                        ? 'Address not provided'
                        : booking.pickupAddress),
                _Row('Schedule', pickupScheduleLabel(booking)),
                _Row('Requested', formatDateTime(booking.createdAt)),
              ]);
            },
          ),
        ),
        const SizedBox(height: 16),
        _Section(
          title: 'ITEMS',
          child: StreamBuilder<List<BookingItem>>(
            stream: _items,
            builder: (context, itemSnap) {
              final items = itemSnap.data ?? const <BookingItem>[];
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text('No items listed.',
                      style: TextStyle(color: AppColors.textSecondary)),
                );
              }
              final total =
                  items.fold<double>(0, (s, i) => s + i.estimatedWeightKg);
              return Column(children: [
                for (final i in items)
                  _Row('${i.itemName} x${i.quantity}',
                      '${i.estimatedWeightKg.toStringAsFixed(1)} kg'),
                const Divider(color: AppColors.divider),
                _Row('Total estimated weight',
                    '${total.toStringAsFixed(1)} kg',
                    bold: true),
              ]);
            },
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'For security staff: this pass is live. The status and clock update '
          'automatically, and the pass turns invalid if the booking is '
          'cancelled or completed.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final bool valid;
  final String? reason;
  const _StatusBanner({required this.valid, this.reason});

  @override
  Widget build(BuildContext context) {
    final color = valid ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        Icon(valid ? Icons.verified_user : Icons.block,
            color: Colors.white, size: 36),
        const SizedBox(height: 8),
        Text(valid ? 'VALID PICKUP PASS' : 'NOT VALID',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1)),
        if (reason != null) ...[
          const SizedBox(height: 4),
          Text(reason!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
        const SizedBox(height: 10),
        const _LiveClock(),
      ]),
    );
  }
}

// Ticks every second on its own so the rest of the pass is not rebuilt.
class _LiveClock extends StatefulWidget {
  const _LiveClock();

  @override
  State<_LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<_LiveClock> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seconds = _now.second.toString().padLeft(2, '0');
    final time = formatTime(_now).replaceFirst(' ', ':$seconds ');
    return Text('${formatDate(_now)}  $time',
        style: const TextStyle(
            color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700));
  }
}

class _CollectorCard extends StatelessWidget {
  const _CollectorCard();

  @override
  Widget build(BuildContext context) {
    final auth = AuthState.instance;
    final name =
        auth.displayName.trim().isEmpty ? 'Collector' : auth.displayName;
    final initials = name
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0])
        .join()
        .toUpperCase();
    final verified = auth.verificationStatus == AppConstants.verifyVerified;
    final photo = auth.profilePhotoUrl;
    return _Section(
      title: 'COLLECTOR',
      child: Row(children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: AppColors.buyerBlue,
          backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
          child: photo.isEmpty
              ? Text(initials,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800))
              : null,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Row(children: [
                Icon(verified ? Icons.verified : Icons.error_outline,
                    size: 16,
                    color: verified ? AppColors.success : AppColors.warning),
                const SizedBox(width: 4),
                Text(verified ? 'Verified Collector' : 'Not verified',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color:
                            verified ? AppColors.success : AppColors.warning)),
              ]),
              if (auth.vehicleType.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text('Vehicle: ${auth.vehicleType}',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
              ],
            ],
          ),
        ),
      ]),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _Row(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
          ),
          Expanded(
            flex: 3,
            child: Text(value,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
