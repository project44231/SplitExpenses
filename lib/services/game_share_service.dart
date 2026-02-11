import 'package:uuid/uuid.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../models/game.dart';

class GameShareService {
  // Firebase Hosting domain
  static const String _webAppDomain = 'splitpot.web.app';

  /// Generate a unique share token for a game
  String generateShareToken() {
    return const Uuid().v4();
  }

  /// Build shareable URL for a game
  String buildShareUrl(String gameId, String shareToken) {
    return 'https://$_webAppDomain/share/$gameId/$shareToken';
  }

  /// Share game via system share dialog
  Future<void> shareGame({
    required Game game,
    required String shareToken,
    String? message,
  }) async {
    final url = buildShareUrl(game.id, shareToken);
    final shareMessage = message ??
        'Join our live game!\n\nView real-time standings:\n$url';

    await Share.share(
      shareMessage,
      subject: 'Live Game - SplitPot',
    );
  }

  /// Copy share URL to clipboard
  Future<void> copyShareUrl({
    required String gameId,
    required String shareToken,
  }) async {
    final url = buildShareUrl(gameId, shareToken);
    await Clipboard.setData(ClipboardData(text: url));
  }

  /// Revoke share access by clearing the token
  Future<void> revokeShareAccess(Game game) async {
    // This would be handled by the game provider
    // Clearing the shareToken effectively revokes access
    // Implementation is in the game provider's updateGame method
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
