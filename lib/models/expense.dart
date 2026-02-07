import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense.freezed.dart';
part 'expense.g.dart';

enum ExpenseSplitType {
  hostAbsorbs,
  equalSplit,
  customSplit,
}

@freezed
class Expense with _$Expense {
  const factory Expense({
    required String id,
    required String gameId,
    required String description,
    required double amount,
    required ExpenseSplitType splitType,
    @Default([]) List<String> contributorPlayerIds, // For custom split
    required DateTime timestamp,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
}
