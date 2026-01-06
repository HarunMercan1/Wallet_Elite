// lib/features/auth/models/profile_model.dart

/// Kullanıcı profil modeli (profiles tablosu)
class ProfileModel {
  final String id;
  final String? fullName;
  final String? avatarUrl;
  final bool isPremium;
  final bool onboardingCompleted;
  final DateTime? updatedAt;

  ProfileModel({
    required this.id,
    this.fullName,
    this.avatarUrl,
    this.isPremium = false,
    this.onboardingCompleted = false,
    this.updatedAt,
  });

  /// Supabase'den gelen JSON'u model'e çevir
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isPremium: json['is_premium'] as bool? ?? false,
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Model'i JSON'a çevir (Supabase'e göndermek için)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'is_premium': isPremium,
      'onboarding_completed': onboardingCompleted,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Kopya oluştur (değişiklik yapmak için)
  ProfileModel copyWith({
    String? id,
    String? fullName,
    String? avatarUrl,
    bool? isPremium,
    bool? onboardingCompleted,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isPremium: isPremium ?? this.isPremium,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}