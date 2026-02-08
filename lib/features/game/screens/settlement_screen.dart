import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/currency.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/buy_in.dart';
import '../../../models/cash_out.dart';
import '../../../models/game.dart';
import '../../../models/player.dart';
import '../../../models/settlement.dart';
import '../../../services/settlement_service.dart';
import '../providers/game_provider.dart';
import '../../players/providers/player_provider.dart';
import '../widgets/cash_out_dialog.dart';
import '../widgets/settlement_card.dart';

class SettlementScreen extends ConsumerStatefulWidget {
  final String gameId;

  const SettlementScreen({super.key, required this.gameId});

  @override
  ConsumerState<SettlementScreen> createState() => _SettlementScreenState();
}

class _SettlementScreenState extends ConsumerState<SettlementScreen> {
  List<SettlementTransaction> _transactions = [];
  Game? _game;
  List<Player> _players = [];
  List<BuyIn> _buyIns = [];
  List<CashOut> _cashOuts = [];
  Map<String, double> _buyInTotals = {};
  Map<String, double> _cashOutTotals = {};
  Map<String, double> _profitLoss = {};
  bool _isLoading = true;
  bool _isValidSettlement = true;
  double _mismatchAmount = 0;
  double _mismatchPercent = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGameData();
  }

  Future<void> _loadGameData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final game = await ref.read(gameProvider.notifier).getGame(widget.gameId);
      final buyIns = await ref.read(gameProvider.notifier).getBuyIns(widget.gameId);
      final cashOuts = await ref.read(gameProvider.notifier).getCashOuts(widget.gameId);
      
      if (game == null) {
        setState(() {
          _errorMessage = 'Game not found';
          _isLoading = false;
        });
        return;
      }

      final playersAsync = ref.read(playerProvider);
      final allPlayers = playersAsync.when(
        data: (players) => players,
        loading: () => <Player>[],
        error: (_, __) => <Player>[],
      );

      final gamePlayers = allPlayers
          .where((p) => game.playerIds.contains(p.id))
          .toList();

      // Calculate totals
      final buyInTotals = <String, double>{};
      final cashOutTotals = <String, double>{};
      
      for (final playerId in game.playerIds) {
        buyInTotals[playerId] = 0;
        cashOutTotals[playerId] = 0;
      }

      for (final buyIn in buyIns) {
        buyInTotals[buyIn.playerId] = (buyInTotals[buyIn.playerId] ?? 0) + buyIn.amount;
      }

      for (final cashOut in cashOuts) {
        cashOutTotals[cashOut.playerId] = (cashOutTotals[cashOut.playerId] ?? 0) + cashOut.amount;
      }

      // Calculate profit/loss
      final profitLoss = <String, double>{};
      for (final playerId in game.playerIds) {
        profitLoss[playerId] = (cashOutTotals[playerId] ?? 0) - (buyInTotals[playerId] ?? 0);
      }

      // Calculate settlement if we have cash-outs
      List<SettlementTransaction> transactions = [];
      bool isValid = true;
      double mismatchAmount = 0;
      double mismatchPercent = 0;
      
      if (cashOuts.isNotEmpty) {
        final service = SettlementService();
        final totalBuyIn = buyInTotals.values.fold(0.0, (sum, val) => sum + val);
        final totalCashOut = cashOutTotals.values.fold(0.0, (sum, val) => sum + val);
        
        // Validate settlement
        isValid = service.validateSettlement(
          totalBuyIns: totalBuyIn,
          totalCashOuts: totalCashOut,
        );
        
        if (!isValid) {
          mismatchAmount = (totalCashOut - totalBuyIn).abs();
          mismatchPercent = service.calculateMismatchPercent(
            totalBuyIns: totalBuyIn,
            totalCashOuts: totalCashOut,
          );
        }
        
        // Calculate transactions
        final playerResults = game.playerIds.map((playerId) {
          // Count rebuys for this player
          final rebuys = buyIns.where((b) => b.playerId == playerId && b.type == BuyInType.rebuy).length;
          
          return PlayerResult(
            playerId: playerId,
            totalBuyIn: buyInTotals[playerId] ?? 0,
            totalCashOut: cashOutTotals[playerId] ?? 0,
            rebuyCount: rebuys,
          );
        }).toList();
        
        transactions = service.calculateSettlement(playerResults);
      }

      setState(() {
        _game = game;
        _players = gamePlayers;
        _buyIns = buyIns;
        _cashOuts = cashOuts;
        _buyInTotals = buyInTotals;
        _cashOutTotals = cashOutTotals;
        _profitLoss = profitLoss;
        _transactions = transactions;
        _isValidSettlement = isValid;
        _mismatchAmount = mismatchAmount;
        _mismatchPercent = mismatchPercent;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading game: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _showCashOutDialog() async {
    if (_game == null) return;

    final currency = AppCurrencies.fromCode(_game!.currency);

    // Convert existing cash-outs to map
    Map<String, double>? existingCashOutsMap;
    if (_cashOuts.isNotEmpty) {
      existingCashOutsMap = {};
      for (final cashOut in _cashOuts) {
        existingCashOutsMap[cashOut.playerId] = cashOut.amount;
      }
    }

    if (!mounted) return;
    final result = await showDialog<Map<String, double>>(
      context: context,
      builder: (context) => CashOutDialog(
        players: _players,
        buyInTotals: _buyInTotals,
        currency: currency,
        existingCashOuts: existingCashOutsMap,
      ),
    );

    if (result != null && mounted) {
      // If editing, clear existing cash-outs first
      if (_cashOuts.isNotEmpty) {
        await ref.read(gameProvider.notifier).clearCashOuts(widget.gameId);
      }

      // Save new cash-outs
      for (final entry in result.entries) {
        if (entry.value > 0) {
          await ref.read(gameProvider.notifier).addCashOut(
                gameId: widget.gameId,
                playerId: entry.key,
                amount: entry.value,
              );
        }
      }

      // Reload data
      await _loadGameData();
    }
  }

  void _shareSettlement() {
    if (_game == null || _transactions.isEmpty) return;

    final currency = AppCurrencies.fromCode(_game!.currency);
    final playerMap = {for (var p in _players) p.id: p.name};
    
    final playerResults = _players.map((player) {
      final rebuys = _buyIns.where((b) => b.playerId == player.id && b.type == BuyInType.rebuy).length;
      
      return PlayerResult(
        playerId: player.id,
        totalBuyIn: _buyInTotals[player.id] ?? 0,
        totalCashOut: _cashOutTotals[player.id] ?? 0,
        rebuyCount: rebuys,
      );
    }).toList();

    final service = SettlementService();
    final summary = service.generateSettlementText(
      gameName: 'Poker Game',
      gameDate: _game!.startTime,
      playerResults: playerResults,
      transactions: _transactions,
      currencySymbol: currency.symbol,
      playerNames: playerMap,
    );

    Share.share(summary, subject: 'Poker Game Settlement');
  }

  Future<void> _backToGame() async {
    // Navigate back to the specific game (to continue or review)
    if (!mounted) return;
    context.go('/game/${widget.gameId}');
  }

  Future<void> _startNewGame() async {
    // Start a completely new game
    if (!mounted) return;
    // Navigate to /game which will trigger getOrCreateCurrentGame
    // Since current game is ended, it will create a new one
    context.go('/game');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadGameData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_game == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Game not found')),
      );
    }

    final currency = AppCurrencies.fromCode(_game!.currency);
    final hasCashOuts = _cashOuts.isNotEmpty;
    final totalBuyIn = _buyInTotals.values.fold(0.0, (sum, val) => sum + val);
    final totalCashOut = _cashOutTotals.values.fold(0.0, (sum, val) => sum + val);

    // Sort players by profit/loss
    final sortedPlayers = List<Player>.from(_players)
      ..sort((a, b) => (_profitLoss[b.id] ?? 0).compareTo(_profitLoss[a.id] ?? 0));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Settlement'),
        actions: [
          if (hasCashOuts)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareSettlement,
              tooltip: 'Share Settlement',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Game Summary Header
            Container(
              padding: const EdgeInsets.all(20),
              color: AppTheme.primaryColor,
              child: Column(
                children: [
                  Text(
                    Formatters.formatDate(_game!.startTime),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'Total Buy-In',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Formatters.formatCurrency(totalBuyIn, currency),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (hasCashOuts)
                        Column(
                          children: [
                            const Text(
                              'Total Cash-Out',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              Formatters.formatCurrency(totalCashOut, currency),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Validation Warning
            if (hasCashOuts && !_isValidSettlement)
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.orange.shade100,
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange.shade800),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Settlement Mismatch',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade900,
                            ),
                          ),
                          Text(
                            'Difference: ${Formatters.formatCurrency(_mismatchAmount, currency)} (${_mismatchPercent.toStringAsFixed(1)}%)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // No Cash-Outs State
            if (!hasCashOuts)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Icon(
                      Icons.payments_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Enter Cash-Out Amounts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Record how much each player cashed out\nto calculate settlements',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _showCashOutDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Enter Cash-Outs'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Player Profit/Loss
            if (hasCashOuts) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  'Player Results',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...sortedPlayers.map((player) {
                final profitLoss = _profitLoss[player.id] ?? 0;
                final isProfit = profitLoss > 0;
                final color = isProfit ? AppTheme.successColor : AppTheme.errorColor;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withValues(alpha: 0.1),
                      child: Text(
                        player.name[0].toUpperCase(),
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      player.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Buy-in: ${Formatters.formatCurrency(_buyInTotals[player.id] ?? 0, currency)} • '
                      'Cash-out: ${Formatters.formatCurrency(_cashOutTotals[player.id] ?? 0, currency)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(
                          isProfit ? Icons.trending_up : Icons.trending_down,
                          color: color,
                          size: 20,
                        ),
                        Text(
                          '${isProfit ? '+' : ''}${Formatters.formatCurrency(profitLoss, currency)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],

            // Settlement Transactions
            if (_transactions.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  children: [
                    const Text(
                      'Who Owes Whom',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_transactions.length} transaction${_transactions.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Optimized to minimize transfers',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ..._transactions.map((transaction) {
                final fromPlayer = _players.firstWhere((p) => p.id == transaction.fromPlayerId);
                final toPlayer = _players.firstWhere((p) => p.id == transaction.toPlayerId);

                return SettlementCard(
                  transaction: transaction,
                  fromPlayerName: fromPlayer.name,
                  toPlayerName: toPlayer.name,
                  currency: currency,
                );
              }),
            ],

            const SizedBox(height: 24),

            // Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!hasCashOuts)
                    OutlinedButton(
                      onPressed: _backToGame,
                      child: const Text('Back to Game'),
                    ),
                  if (hasCashOuts) ...[
                    ElevatedButton(
                      onPressed: _startNewGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Start New Game',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _showCashOutDialog,
                      child: const Text('Edit Cash-Outs'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
