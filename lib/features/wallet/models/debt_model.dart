// lib/features/wallet/models/debt_model.dart

/// Borç/Alacak modeli (debts tablosu)
class DebtModel {
  final String id;
  final String userId;
  final String personName;
  final double amount;
  final double remainingAmount;
  final DateTime? dueDate;
  final String type; // 'lend' (alacak) veya 'borrow' (borç)
  final bool isCompleted;
  final String? description;
  final DateTime createdAt;

  DebtModel({
    required this.id,
    required this.userId,
    required this.personName,
    required this.amount,
    required this.remainingAmount,
    this.dueDate,
    required this.type,
    this.isCompleted = false,
    this.description,
    required this.createdAt,
  });

  /// JSON'dan model oluştur
  factory DebtModel.fromJson(Map<String, dynamic> json) {
    return DebtModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      personName: json['person_name'] as String,
      amount: (json['amount'] as num).toDouble(),
      remainingAmount: (json['remaining_amount'] as num).toDouble(),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      type: json['type'] as String,
      isCompleted: json['is_completed'] as bool? ?? false,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Model'i JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'person_name': personName,
      'amount': amount,
      'remaining_amount': remainingAmount,
      'due_date': dueDate?.toIso8601String(),
      'type': type,
      'is_completed': isCompleted,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Alacak mı?
  bool get isLend => type == 'lend';

  /// Borç mu?
  bool get isBorrow => type == 'borrow';

  /// Kopyala ve güncelle
  DebtModel copyWith({
    String? id,
    String? userId,
    String? personName,
    double? amount,
    double? remainingAmount,
    DateTime? dueDate,
    String? type,
    bool? isCompleted,
    String? description,
    DateTime? createdAt,
  }) {
    return DebtModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      personName: personName ?? this.personName,
      amount: amount ?? this.amount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      dueDate: dueDate ?? this.dueDate,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
