import 'package:cloud_firestore/cloud_firestore.dart';

/// Market price for a specific scrap type
class MarketPriceModel {
  final String scrapTypeId;
  final String scrapTypeName;
  final String icon;
  final double pricePerKg;
  final double changePercent;
  final DateTime updatedAt;

  const MarketPriceModel({
    required this.scrapTypeId,
    required this.scrapTypeName,
    required this.icon,
    required this.pricePerKg,
    required this.changePercent,
    required this.updatedAt,
  });

  bool get isPositive => changePercent >= 0;

  String get priceDisplay => '₱${pricePerKg.toStringAsFixed(0)}/kg';

  String get changeDisplay {
    final sign = isPositive ? '+' : '';
    return '$sign${changePercent.toStringAsFixed(1)}%';
  }

  factory MarketPriceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MarketPriceModel(
      scrapTypeId: doc.id,
      scrapTypeName: data['scrapTypeName'] ?? '',
      icon: data['icon'] ?? '📦',
      pricePerKg: (data['pricePerKg'] as num?)?.toDouble() ?? 0.0,
      changePercent: (data['changePercent'] as num?)?.toDouble() ?? 0.0,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'scrapTypeName': scrapTypeName,
      'icon': icon,
      'pricePerKg': pricePerKg,
      'changePercent': changePercent,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Default market prices (used when Firestore is not configured)
  static List<MarketPriceModel> get defaults => [
        MarketPriceModel(
          scrapTypeId: 'plastic',
          scrapTypeName: 'Plastic',
          icon: '♻️',
          pricePerKg: 15.0,
          changePercent: 2.0,
          updatedAt: DateTime.now(),
        ),
        MarketPriceModel(
          scrapTypeId: 'metals',
          scrapTypeName: 'Metals',
          icon: '🔩',
          pricePerKg: 80.0,
          changePercent: 5.0,
          updatedAt: DateTime.now(),
        ),
        MarketPriceModel(
          scrapTypeId: 'appliances',
          scrapTypeName: 'Appliances',
          icon: '🔌',
          pricePerKg: 50.0,
          changePercent: 3.0,
          updatedAt: DateTime.now(),
        ),
        MarketPriceModel(
          scrapTypeId: 'mixed',
          scrapTypeName: 'Mixed Scrap',
          icon: '📦',
          pricePerKg: 25.0,
          changePercent: -1.0,
          updatedAt: DateTime.now(),
        ),
      ];
}
