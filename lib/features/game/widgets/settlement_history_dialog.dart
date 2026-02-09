import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/currency.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/settlement.dart';
import '../../../models/player.dart';
import '../providers/game_provider.dart';
import '../../players/providers/player_provider.dart';

/// Dialog showing settlement history for a game
/// 
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (context) => SettlementHistoryDialog(
///     gameId: gameId,
///     currency: currency,
///   ),
/// );
/// ```
class SettlementHistoryDialog extends ConsumerStatefulWidget {
  final String gameId;
  final Currency currency;

  const SettlementHistoryDialog({
    super.key,
    required this.gameId,
    required this.currency,
  });

  @override
  ConsumerState<SettlementHistoryDialog> createState() =>
      _SettlementHistoryDialogState();
}

class _SettlementHistoryDialogState
    extends ConsumerState<SettlementHistoryDialog> {
  List<Settlement> _settlements = [];
  Map<String, Player> _playerMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettlements();
  }

  Future<void> _loadSettlements() async {
    setState(() => _isLoading = true);

    try {
      // Load settlements
      final settlements =
          await ref.read(gameProvider.notifier).getSettlements(widget.gameId);

      // Load players
      await ref.read(playerProvider.notifier).loadPlayers();
      final playersAsync = ref.read(playerProvider);
      final players = playersAsync.when(
        data: (p) => p,
        loading: () => <Player>[],
        error: (_, __) => <Player>[],
      );

      setState(() {
        _settlements = settlements;
        _playerMap = {for (var p in players) p.id: p};
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.history, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Settlement History',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _settlements.isEmpty
                      ? _buildEmptyState()
                      : _buildSettlementList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Settlement History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Settlement records will appear here\nafter entering cash-outs',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _settlements.length,
      itemBuilder: (context, index) {
        final settlement = _settlements[index];
        final isLatest = index == 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: isLatest
                  ? AppTheme.primaryColor
                  : Colors.grey.shade300,
              child: Icon(
                Icons.receipt_long,
                color: isLatest ? Colors.white : Colors.grey.shade600,
              ),
            ),
            title: Row(
              children: [
                Text(
                  Formatters.formatDate(settlement.generatedAt),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isLatest) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Latest',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Text(
              '${settlement.transactions.length} transaction${settlement.transactions.length == 1 ? '' : 's'} • ${Formatters.formatTime(settlement.generatedAt)}',
              style: const TextStyle(fontSize: 12),
            ),
            children: [
              const Divider(height: 1),
              ...settlement.transactions.map((transaction) {
                final fromPlayer = _playerMap[transaction.fromPlayerId];
                final toPlayer = _playerMap[transaction.toPlayerId];

                return ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.arrow_forward,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  title: Text(
                    '${fromPlayer?.name ?? 'Unknown'} → ${toPlayer?.name ?? 'Unknown'}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: Text(
                    Formatters.formatCurrency(
                        transaction.amount, widget.currency),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
