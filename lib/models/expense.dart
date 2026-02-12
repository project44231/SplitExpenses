import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense.freezed.dart';
part 'expense.g.dart';

enum ExpenseCategory {
  food,
  transport,
  accommodation,
  utilities,
  groceries,
  entertainment,
  shopping,
  healthcare,
  other,
}

enum SplitMethod {
  equal,
  percentage,
  exactAmount,
  shares,
}

@freezed
class Expense with _$Expense {
  const factory Expense({
    required String id,
    required String eventId,
    required String paidByParticipantId,
    required double amount,
    required String description,
    required DateTime timestamp,
    required ExpenseCategory category,
    required SplitMethod splitMethod,
    // For equal: empty or all participants with equal values
    // For percentage: participantId -> percentage (0-100)
    // For exactAmount: participantId -> exact amount
    // For shares: participantId -> number of shares
    @Default({}) Map<String, double> splitDetails,
    String? receipt, // optional photo URL
    String? notes,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
}

// Extension for category display
extension ExpenseCategoryExtension on ExpenseCategory {
  String get displayName {
    switch (this) {
      case ExpenseCategory.food:
        return 'Food & Dining';
      case ExpenseCategory.transport:
        return 'Transportation';
      case ExpenseCategory.accommodation:
        return 'Accommodation';
      case ExpenseCategory.utilities:
        return 'Utilities';
      case ExpenseCategory.groceries:
        return 'Groceries';
      case ExpenseCategory.entertainment:
        return 'Entertainment';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.healthcare:
        return 'Healthcare';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case ExpenseCategory.food:
        return '🍽️';
      case ExpenseCategory.transport:
        return '🚗';
      case ExpenseCategory.accommodation:
        return '🏠';
      case ExpenseCategory.utilities:
        return '💡';
      case ExpenseCategory.groceries:
        return '🛒';
      case ExpenseCategory.entertainment:
        return '🎬';
      case ExpenseCategory.shopping:
        return '🛍️';
      case ExpenseCategory.healthcare:
        return '⚕️';
      case ExpenseCategory.other:
        return '📝';
    }
  }
}

// Extension for split method display
extension SplitMethodExtension on SplitMethod {
  String get displayName {
    switch (this) {
      case SplitMethod.equal:
        return 'Split Equally';
      case SplitMethod.percentage:
        return 'By Percentage';
      case SplitMethod.exactAmount:
        return 'Exact Amounts';
      case SplitMethod.shares:
        return 'By Shares';
    }
  }
}
