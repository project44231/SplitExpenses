import 'package:freezed_annotation/freezed_annotation.dart';

part 'participant.freezed.dart';
part 'participant.g.dart';

@freezed
class Participant with _$Participant {
  const factory Participant({
    required String id,
    required String userId,
    required String name,
    String? email,
    String? phone,
    String? photoUrl,
    String? notes,
    @Default([]) List<String> groupIds,
    @Default(false) bool isFavorite,
    @Default(0) int eventsAttended,
    DateTime? lastEventAt,
    @Default(0.0) double totalPaid,
    @Default(0.0) double totalOwed,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Participant;

  factory Participant.fromJson(Map<String, dynamic> json) => 
      _$ParticipantFromJson(json);
}
