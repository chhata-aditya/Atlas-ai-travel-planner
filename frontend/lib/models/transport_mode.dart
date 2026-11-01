import 'package:flutter/material.dart';

enum TransportType {
  flight,
  train,
  bus,
  car,
  ferry,
}

class TransportOption {
  final TransportType type;
  final String title;
  final String subtitle;
  final String durationText;
  final int durationMinutes;
  final double estimatedCostUSD;
  final String costRangeText;
  final double co2Kg;
  final bool isRecommended;
  final String recommendationReason;
  final String? badge; // e.g. "RECOMMENDED", "FASTEST", "BEST VALUE", "ECO CHOICE"
  final IconData icon;
  final Color themeColor;

  const TransportOption({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.durationText,
    required this.durationMinutes,
    required this.estimatedCostUSD,
    required this.costRangeText,
    required this.co2Kg,
    required this.isRecommended,
    required this.recommendationReason,
    this.badge,
    required this.icon,
    required this.themeColor,
  });
}
