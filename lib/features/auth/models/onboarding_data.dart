// lib/features/auth/models/onboarding_data.dart

/// Onboarding sırasında toplanan veriler
class OnboardingData {
  final String currency;
  final String accountName;
  final String accountType;
  final double initialBalance;

  OnboardingData({
    required this.currency,
    required this.accountName,
    required this.accountType,
    this.initialBalance = 0,
  });
}