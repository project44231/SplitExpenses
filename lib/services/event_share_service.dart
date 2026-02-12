import 'package:uuid/uuid.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../models/event.dart';

class EventShareService {
  // Firebase Hosting domain - update this with your actual domain
  static const String _webAppDomain = 'splitexpenses.web.app';

  /// Generate a unique share token for an event
  String generateShareToken() {
    return const Uuid().v4();
  }

  /// Build shareable URL for an event
  String buildShareUrl(String eventId, String shareToken) {
    return 'https://$_webAppDomain/share/$eventId/$shareToken';
  }

  /// Share event via system share dialog
  Future<void> shareEvent({
    required Event event,
    required String shareToken,
    String? message,
  }) async {
    final url = buildShareUrl(event.id, shareToken);
    final shareMessage = message ??
        'Join our live event!\n\nView real-time expenses:\n$url';

    await Share.share(
      shareMessage,
      subject: 'Live Event - SplitExpenses',
    );
  }

  /// Copy share URL to clipboard
  Future<void> copyShareUrl({
    required String eventId,
    required String shareToken,
  }) async {
    final url = buildShareUrl(eventId, shareToken);
    await Clipboard.setData(ClipboardData(text: url));
  }

  /// Revoke share access by clearing the token
  Future<void> revokeShareAccess(Event event) async {
    // This would be handled by the event provider
    // Clearing the shareToken effectively revokes access
    // Implementation is in the event provider's updateEvent method
  }

  /// Validate share token format
  bool isValidShareToken(String token) {
    // UUID v4 format validation
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(token);
  }
}
