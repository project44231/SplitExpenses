import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense.freezed.dart';
part 'expense.g.dart';

/// Expense entry for a game (tips, food, etc.)
@freezed
class Expense with _$Expense {
  const factory Expense({
    required String id,
    required String gameId,
    required double amount,
    required ExpenseCategory category,
    String? note,
    required DateTime timestamp,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);
}

/// Category of expense
enum ExpenseCategory {
  tips,
  food,
  other;

  String get displayName {
    switch (this) {
      case ExpenseCategory.tips:
        return 'Tips';
      case ExpenseCategory.food:
        return 'Food & Drinks';
      case ExpenseCategory.other:
        return 'Other';
    }
  }
}
