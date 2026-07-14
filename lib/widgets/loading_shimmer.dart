import 'package:flutter/material.dart';

class LoadingCard extends StatelessWidget {
  final double height;
  final EdgeInsets margin;
  final double borderRadius;

  const LoadingCard({
    super.key,
    this.height = 100,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class LoadingList extends StatelessWidget {
  final int itemCount;

  const LoadingList({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemBuilder: (context, index) {
        return const LoadingCard();
      },
    );
  }
}

class LoadingStatCard extends StatelessWidget {
  final double width;
  final double height;

  const LoadingStatCard({
    super.key,
    this.width = 100,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
