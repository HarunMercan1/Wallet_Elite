// lib/features/wallet/models/account_model.dart

import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart';

/// Cüzdan hesabı modeli (accounts tablosu)
class AccountModel {
  final String id;
  final String userId;
  final String name;
  final String type; // bank, cash, gold, credit_card
  final double balance;
  final String currency;
  final DateTime createdAt;

  String get currencySymbol {
    switch (currency) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return CurrencyUtils.getSymbol(currency);
    }
  }

  AccountModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.balance,
    required this.currency,
    required this.createdAt,
  });

  /// JSON'dan model oluştur
  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'TRY',
      createdAt: parseServerTimestamp(json['created_at'] as String),
    );
  }

  /// Model'i JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type,
      'balance': balance,
      'currency': currency,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Kopyala ve güncelle
  AccountModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? type,
    double? balance,
    String? currency,
    DateTime? createdAt,
  }) {
    return AccountModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
