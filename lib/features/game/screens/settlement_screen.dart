import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/currency.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/settlement.dart';
import '../../../models/compat.dart';
import '../../../services/settlement_service.dart';
import '../../../services/settlement_share_service.dart';
import '../providers/game_provider.dart';
import '../../players/providers/player_provider.dart';
// import '../widgets/cash_out_dialog.dart'; // Removed - not used in expense model
import '../widgets/settlement_card.dart';
import '../widgets/settlement_history_dialog.dart';


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
  List<Expense> _expenses = [];
  Map<String, double> _paidTotals = {};
  Map<String, double> _owedTotals = {};
  Map<String, double> _netBalance = {};
  bool _isLoading = true;
  bool _isValidSettlement = true;
  double _mismatchAmount = 0;
  double _mismatchPercent = 0;
  String? _errorMessage;
  bool _isNotesExpanded = false;

  @override
  void initState() {
    super.initState();
    // Delay provider modification until after the widget tree is built
    Future.microtask(() => _loadGameData());
  }

  Future<void> _loadGameData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // First, ensure players are loaded
      await ref.read(playerProvider.notifier).loadPlayers();
      
      final game = await ref.read(gameProvider.notifier).getGame(widget.gameId);
      final expenses = await ref.read(gameProvider.notifier).getExpenses(widget.gameId);
      
      if (game == null) {
        setState(() {
          _errorMessage = 'Event not found';
          _isLoading = false;
        });
        return;
      }

      // Now get players after ensuring they're loaded
      final playersAsync = ref.read(playerProvider);
      final allPlayers = playersAsync.when(
        data: (players) => players,
        loading: () => <Player>[],
        error: (_, __) => <Player>[],
      );

      // Collect all participant IDs from expenses
      final allParticipantIdsFromExpenses = <String>{};
      for (final expense in expenses) {
        allParticipantIdsFromExpenses.add(expense.paidByParticipantId);
        allParticipantIdsFromExpenses.addAll(expense.splitDetails.keys);
      }
      
      // Also include game players
      allParticipantIdsFromExpenses.addAll(game.playerIds);
      
      // Get players that are actually involved in expenses
      final gamePlayers = allPlayers
          .where((p) => allParticipantIdsFromExpenses.contains(p.id))
          .toList();

      // Calculate totals for each participant
      final paidTotals = <String, double>{};
      final owedTotals = <String, double>{};
      
      for (final playerId in allParticipantIdsFromExpenses) {
        paidTotals[playerId] = 0;
        owedTotals[playerId] = 0;
      }

      // Calculate how much each person paid and owes
      for (final expense in expenses) {
        // The payer's contribution
        paidTotals[expense.paidByParticipantId] = 
            (paidTotals[expense.paidByParticipantId] ?? 0) + expense.amount;

        // Use splitDetails to determine who owes what
        // splitDetails contains the share for each participant (as a fraction of total amount)
        expense.splitDetails.forEach((participantId, shareRatio) {
          final amountOwed = expense.amount * shareRatio;
          owedTotals[participantId] = (owedTotals[participantId] ?? 0) + amountOwed;
        });
      }

      // Calculate net balance for all participants (positive means others owe them, negative means they owe others)
      final netBalance = <String, double>{};
      final allParticipantIds = {...paidTotals.keys, ...owedTotals.keys};
      for (final playerId in allParticipantIds) {
        netBalance[playerId] = (paidTotals[playerId] ?? 0) - (owedTotals[playerId] ?? 0);
      }

      // Calculate settlement from expenses
      List<SettlementTransaction> transactions = [];
      bool isValid = true;
      double mismatchAmount = 0;
      double mismatchPercent = 0;
      
      if (expenses.isNotEmpty) {
        final service = SettlementService();
        final totalPaid = paidTotals.values.fold(0.0, (sum, val) => sum + val);
        final totalOwed = owedTotals.values.fold(0.0, (sum, val) => sum + val);
        
        // Small differences are expected due to rounding
        mismatchAmount = (totalPaid - totalOwed).abs();
        mismatchPercent = totalPaid > 0 ? (mismatchAmount / totalPaid) * 100 : 0;
        isValid = mismatchPercent < 1; // Less than 1% is acceptable
        
        // Calculate transactions for all participants
        final allParticipantIds = {...paidTotals.keys, ...owedTotals.keys};
        final playerResults = allParticipantIds.map((playerId) {
          final participantExpenses = expenses.where((e) => 
            e.paidByParticipantId == playerId || 
            e.splitDetails.containsKey(playerId)
          ).length;
          return ParticipantResult(
            participantId: playerId,
            totalPaid: paidTotals[playerId] ?? 0,
            totalOwed: owedTotals[playerId] ?? 0,
            expenseCount: participantExpenses,
          );
        }).toList();
        
        transactions = service.calculateSettlement(playerResults);
      }

      setState(() {
        _game = game;
        _players = gamePlayers;
        _expenses = expenses;
        _paidTotals = paidTotals;
        _owedTotals = owedTotals;
        _netBalance = netBalance;
        _transactions = transactions;
        _isValidSettlement = isValid;
        _mismatchAmount = mismatchAmount;
        _mismatchPercent = mismatchPercent;
        _isLoading = false;
      });

      // Save settlement to Firestore if we have transactions
      if (transactions.isNotEmpty) {
        print('DEBUG: Settlement calculated with ${transactions.length} transactions, saving to Firestore...');
        _saveSettlementToFirestore(transactions);
      } else {
        print('DEBUG: No transactions to save (empty transactions list)');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading game: $e';
        _isLoading = false;
      });
    }
  }

  /// Save settlement transactions to Firestore for tracking
  Future<void> _saveSettlementToFirestore(List<SettlementTransaction> transactions) async {
    try {
      print('DEBUG: Calling gameProvider.saveSettlement for event ${widget.gameId}');
      await ref.read(gameProvider.notifier).saveSettlement(
        eventId: widget.gameId,
        transactions: transactions,
      );
      print('DEBUG: Settlement saved successfully to Firestore! ✓');
    } catch (e) {
      print('ERROR: Failed to save settlement to Firestore: $e');
      // Don't show error to user as this is a background operation
    }
  }

  Future<void> _shareSettlement() async {
    if (_game == null || _transactions.isEmpty) return;

    // Show loading
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generating shareable link...'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    try {
      final currency = AppCurrencies.fromCode(_game!.currency);
      final playerMap = <String, String>{for (var p in _players) p.id: p.name};
      
      final playerResults = _players.map<ParticipantResult>((player) {
        final participantExpenses = _expenses.where((e) => 
          e.paidByParticipantId == player.id || 
          e.splitDetails.containsKey(player.id)
        ).length;
        return ParticipantResult(
          participantId: player.id,
          totalPaid: _paidTotals[player.id] ?? 0,
          totalOwed: _owedTotals[player.id] ?? 0,
          expenseCount: participantExpenses,
        );
      }).toList();

      // Create shareable web link
      final shareService = SettlementShareService();
      final shareUrl = await shareService.createShareableLink(
        eventName: _game!.name ?? 'Event',
        eventDate: _game!.startTime,
        participantResults: playerResults,
        transactions: _transactions,
        participantNames: playerMap,
        currency: currency,
      );

      // Share the link
      await Share.share(
        'View the settlement for "${_game!.name ?? "Event"}":\n\n$shareUrl',
        subject: 'Settlement - ${_game!.name ?? "Event"}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Link created! Tap to copy'),
            action: SnackBarAction(
              label: 'Copy',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: shareUrl));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied!')),
                );
              },
            ),
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveSettlement() async {
    if (_game == null || _transactions.isEmpty) return;

    final currency = AppCurrencies.fromCode(_game!.currency);
    final playerMap = <String, String>{for (var p in _players) p.id: p.name};
    
    final playerResults = _players.map<ParticipantResult>((player) {
      final participantExpenses = _expenses.where((e) => 
        e.paidByParticipantId == player.id || 
        e.splitDetails.containsKey(player.id)
      ).length;
      return ParticipantResult(
        participantId: player.id,
        totalPaid: _paidTotals[player.id] ?? 0,
        totalOwed: _owedTotals[player.id] ?? 0,
        expenseCount: participantExpenses,
      );
    }).toList();

    final service = SettlementService();
    final summary = service.generateSettlementText(
      eventName: _game!.name ?? 'Event',
      eventDate: _game!.startTime,
      participantResults: playerResults,
      transactions: _transactions,
      currencySymbol: currency.symbol,
      participantNames: playerMap,
    );

    try {
      // Use Share to save/export the file
      await Share.share(
        summary,
        subject: 'Settlement Summary - ${_game!.name ?? "Event"}',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settlement summary ready to save'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSettlementHistory(Currency currency) {
    showDialog(
      context: context,
      builder: (context) => SettlementHistoryDialog(
        gameId: widget.gameId,
        currency: currency,
      ),
    );
  }

  Future<void> _backToGame() async {
    // Navigate back to the specific group expense
    if (!mounted) return;
    context.go('${AppConstants.groupExpenseDetailRoute}/${widget.gameId}');
  }

  Future<void> _markAsSettled() async {
    if (_game == null) return;
    
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Event'),
        content: const Text(
          'This will archive the event and move it to history. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
    
    if (confirm != true || !mounted) return;
    
    try {
      // Update game status to settled
      await ref.read(gameProvider.notifier).endGame(widget.gameId);
      
      if (!mounted) return;
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group expense marked as settled!')),
      );
      
      // Navigate back to group expenses list
      context.go(AppConstants.groupExpensesRoute);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error settling group: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'images/app_icon.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'images/app_icon.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'images/app_icon.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Game not found',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    final currency = AppCurrencies.fromCode(_game!.currency);
    final hasExpenses = _expenses.isNotEmpty;
    final totalPaid = _paidTotals.values.fold(0.0, (sum, val) => sum + val);
    final totalOwed = _owedTotals.values.fold(0.0, (sum, val) => sum + val);

    // Sort players by net balance (who is owed the most first)
    final sortedPlayers = List<Participant>.from(_players)
      ..sort((a, b) {
        final aBalance = _netBalance[a.id] ?? 0;
        final bBalance = _netBalance[b.id] ?? 0;
        return bBalance.compareTo(aBalance);
      });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppConstants.homeRoute),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'images/app_icon.png',
                width: 28,
                height: 28,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Settlement'),
          ],
        ),
        actions: [
          if (hasExpenses)
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => _showSettlementHistory(currency),
              tooltip: 'Settlement History',
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
                            Formatters.formatCurrency(totalPaid, currency),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (hasExpenses)
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
                              Formatters.formatCurrency(totalOwed, currency),
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

            // Game Notes (if available)
            if (_game!.notes != null && _game!.notes!.trim().isNotEmpty)
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() => _isNotesExpanded = !_isNotesExpanded);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.note_alt_outlined,
                              size: 18,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Game Notes',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade900,
                              ),
                            ),
                            if (!_isNotesExpanded)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade700,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            const Spacer(),
                            Icon(
                              _isNotesExpanded ? Icons.expand_less : Icons.expand_more,
                              size: 20,
                              color: Colors.blue.shade700,
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: _isNotesExpanded
                          ? Container(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                              child: Text(
                                _game!.notes!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),

            // Validation Warning
            if (hasExpenses && !_isValidSettlement)
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
            if (!hasExpenses)
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
                    Text(
                      'Add expenses from the group detail screen',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

            // Player Profit/Loss
            if (hasExpenses) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  'Balance Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...sortedPlayers.map((player) {
                final netBalance = _netBalance[player.id] ?? 0;
                final isProfit = netBalance > 0;
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
                      'Paid: ${Formatters.formatCurrency(_paidTotals[player.id] ?? 0, currency)} • '
                      'Owed: ${Formatters.formatCurrency(_owedTotals[player.id] ?? 0, currency)}',
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
                          '${isProfit ? '+' : ''}${Formatters.formatCurrency(netBalance, currency)}',
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
                final fromPlayer = _players.cast<Participant>().firstWhere(
                  (p) => p.id == transaction.fromParticipantId,
                  orElse: () => Participant(
                    id: transaction.fromParticipantId,
                    userId: 'unknown',
                    name: 'Unknown',
                    createdAt: DateTime.now(),
                  ),
                );
                final toPlayer = _players.cast<Participant>().firstWhere(
                  (p) => p.id == transaction.toParticipantId,
                  orElse: () => Participant(
                    id: transaction.toParticipantId,
                    userId: 'unknown',
                    name: 'Unknown',
                    createdAt: DateTime.now(),
                  ),
                );

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
                  if (!hasExpenses)
                    OutlinedButton(
                      onPressed: _backToGame,
                      child: const Text('Back to Game'),
                    ),
                  if (hasExpenses) ...[
                    // Share and Save buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _shareSettlement,
                            icon: const Icon(Icons.share, size: 18),
                            label: const Text('Share'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: AppTheme.primaryColor, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _saveSettlement,
                            icon: const Icon(Icons.download, size: 18),
                            label: const Text('Save'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Colors.green, width: 1.5),
                              foregroundColor: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _markAsSettled,
                      icon: const Icon(Icons.archive),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      label: const Text(
                        'Archive Event',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
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
