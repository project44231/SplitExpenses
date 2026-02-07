import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String email,
    String? displayName,
    String? photoUrl,
    String? defaultCurrency,
    required bool isGuest,
    required DateTime createdAt,
    DateTime? lastLoginAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
  
  /// Create a guest user
  factory AppUser.guest() => AppUser(
        id: 'guest',
        email: 'guest@local',
        isGuest: true,
        createdAt: DateTime.now(),
      );
}
