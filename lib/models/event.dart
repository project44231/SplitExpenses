import 'package:freezed_annotation/freezed_annotation.dart';

part 'event.freezed.dart';
part 'event.g.dart';

enum EventStatus {
  active,
  settled,
  archived,
}

@freezed
class Event with _$Event {
  const factory Event({
    required String id,
    required String userId,
    String? name,
    String? description,
    required String groupId,
    required EventStatus status,
    required String currency,
    @Default([]) List<String> participantIds,
    required DateTime startTime,
    DateTime? endTime,
    String? notes,
    String? shareToken,
    @Default([]) List<String> categoryTags,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Event;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}

/// Participant result in an event (computed, not stored separately)
class ParticipantResult {
  final String participantId;
  final double totalPaid;
  final double totalOwed;
  final double netBalance;
  final int expenseCount;

  ParticipantResult({
    required this.participantId,
    required this.totalPaid,
    required this.totalOwed,
    required this.expenseCount,
  }) : netBalance = totalPaid - totalOwed;

  bool get shouldReceive => netBalance > 0;
  bool get shouldPay => netBalance < 0;
  bool get isSettled => netBalance.abs() < 0.01;
}
