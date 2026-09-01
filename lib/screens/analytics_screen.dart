import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/booking.dart';
import '../services/firestore_service.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  Future<_AnalyticsData> _load(FirestoreService svc, List<Booking> completed,
      List<Map<String, dynamic>> collectors) async {
    // Pickup volume: completions per day, last 7 days.
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final volume = days.map((d) {
      final at = completed.where((b) {
        final c = b.completedAt ?? b.createdAt;
        return c.year == d.year && c.month == d.month && c.day == d.day;
      }).length;
      return at;
    }).toList();

    // Material breakdown: sum weight per ScrapClass across all completed items.
    final classWeights = <String, double>{};
    double totalWeight = 0;
    for (final b in completed) {
      final items = await svc.bookingItems(b.bookingId).first;
      for (final i in items) {
        classWeights[i.scrapClass] = (classWeights[i.scrapClass] ?? 0) + i.estimatedWeightKg;
        totalWeight += i.estimatedWeightKg;
      }
    }
    final topClasses = classWeights.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Top collectors by completed-pickup count.
    final completedByCollector = <String, int>{};
    for (final b in completed) {
      if (b.collectorId.isEmpty) continue;
      completedByCollector[b.collectorId] = (completedByCollector[b.collectorId] ?? 0) + 1;
    }
    final ranked = completedByCollector.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCollectors = <_TopCollector>[];
    for (final entry in ranked.take(5)) {
      final account = collectors.firstWhere(
          (c) => c['uid'] == entry.key, orElse: () => const {});
      final name = (account['Display_Name'] as String?) ?? 'Unknown';
      final profile = await svc.collectorProfile(entry.key);
      final rating = (profile?['Avg_Rating'] as num?)?.toDouble() ?? 0;
      topCollectors.add(_TopCollector(name: name, pickups: entry.value, rating: rating));
    }

    return _AnalyticsData(
      volume: volume,
      topClasses: topClasses.take(5).toList(),
      totalWeight: totalWeight,
      topCollectors: topCollectors,
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
          backgroundColor: AppColors.canvas,
          elevation: 0,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context)),
          title: const Text('Analytics',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800))),
      body: StreamBuilder<List<Booking>>(
        stream: firestoreService.allBookings(),
        builder: (context, bookingsSnap) {
          final completed = (bookingsSnap.data ?? const <Booking>[])
              .where((b) => b.status == 'Completed')
              .toList();
          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: firestoreService.listUsers(),
            builder: (context, usersSnap) {
              final collectors = (usersSnap.data ?? const <Map<String, dynamic>>[])
                  .where((u) => u['Role'] == 'Collector' || u['Role'] == 'VerifiedCollector')
                  .toList();
              if (!bookingsSnap.hasData || !usersSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return FutureBuilder<_AnalyticsData>(
                future: _load(firestoreService, completed, collectors),
                builder: (context, dataSnap) {
                  if (!dataSnap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final data = dataSnap.data!;
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    children: [
                      const SizedBox(height: 8),
                      _Card('COMPLETED PICKUPS (Last 7 Days)', [
                        SizedBox(
                          height: 80,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: data.volume
                                .map((v) => Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 2),
                                        decoration: const BoxDecoration(
                                            color: AppColors.buyerBlue,
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(4))),
                                        height: v == 0 ? 2 : v.toDouble() * 12,
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ]),
                      _Card('MATERIAL BREAKDOWN (by weight)', [
                        if (data.topClasses.isEmpty)
                          const Text('No completed pickups yet.',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary))
                        else
                          ...data.topClasses.map((e) => _MatB(
                              e.key,
                              data.totalWeight == 0
                                  ? '0%'
                                  : '${(e.value / data.totalWeight * 100).toStringAsFixed(0)}%')),
                      ]),
                      _Card('TOP COLLECTORS', [
                        if (data.topCollectors.isEmpty)
                          const Text('No completed pickups yet.',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary))
                        else
                          ...data.topCollectors.asMap().entries.map((e) => _TopR(
                              '${e.key + 1}',
                              e.value.name,
                              '${e.value.pickups}',
                              e.value.rating.toStringAsFixed(1))),
                      ]),
                      const SizedBox(height: 30),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _AnalyticsData {
  final List<int> volume;
  final List<MapEntry<String, double>> topClasses;
  final double totalWeight;
  final List<_TopCollector> topCollectors;
  const _AnalyticsData({
    required this.volume,
    required this.topClasses,
    required this.totalWeight,
    required this.topCollectors,
  });
}

class _TopCollector {
  final String name;
  final int pickups;
  final double rating;
  const _TopCollector({required this.name, required this.pickups, required this.rating});
}

class _Card extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Card(this.title, this.children);
  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1)),
        const SizedBox(height: 12),
        ...children
      ]));
}

class _MatB extends StatelessWidget {
  final String label, pct;
  const _MatB(this.label, this.pct);
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
                color: AppColors.buyerBlue, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 8),
        Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 11, color: AppColors.textPrimary))),
        Text(pct,
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary))
      ]));
}

class _TopR extends StatelessWidget {
  final String rank, name, pickups, stars;
  const _TopR(this.rank, this.name, this.pickups, this.stars);
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(
            width: 24,
            child: Text(rank,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.divider))),
        Expanded(
            child: Text(name,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
        Text('★$stars', style: const TextStyle(fontSize: 11, color: AppColors.star)),
        const SizedBox(width: 8),
        Text('$pickups pickups',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))
      ]));
}
