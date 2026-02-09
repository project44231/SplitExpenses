import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/currency.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../models/player.dart';
import '../../../models/expense.dart';
import '../../../models/cash_out_reconciliation.dart';
import '../../../services/cash_out_mismatch_handler.dart';
import '../providers/game_provider.dart';
import '../../players/providers/player_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/mismatch_banner.dart';
import '../widgets/expense_dialog.dart';
import '../widgets/adjustment_dialog.dart';

class CashOutScreen extends ConsumerStatefulWidget {
  final String gameId;

  const CashOutScreen({super.key, required this.gameId});

  @override
  ConsumerState<CashOutScreen> createState() => _CashOutScreenState();
}

class _CashOutScreenState extends ConsumerState<CashOutScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();
  
  double _totalBuyIn = 0;
  double _totalCashOut = 0;
  bool _isSubmitting = false;
  MismatchSeverity _mismatchSeverity = MismatchSeverity.perfect;

  List<Player> _players = [];
  Map<String, double> _buyInTotals = {};
  Currency? _currency;
  final List<Expense> _expenses = [];

  @override
  void initState() {
    super.initState();
    _loadGameData();
  }

  Future<void> _loadGameData() async {
    try {
      final game = await ref.read(gameProvider.notifier).getGame(widget.gameId);
      if (game == null || !mounted) return;

      final buyIns = await ref.read(gameProvider.notifier).getBuyIns(widget.gameId);
      final cashOuts = await ref.read(gameProvider.notifier).getCashOuts(widget.gameId);
      final playersAsync = ref.read(playerProvider);
      
      final allPlayers = playersAsync.when(
        data: (players) => players,
        loading: () => <Player>[],
        error: (_, __) => <Player>[],
      );

      final gamePlayers = allPlayers.where((p) => game.playerIds.contains(p.id)).toList();
      
      final buyInTotals = <String, double>{};
      for (final buyIn in buyIns) {
        buyInTotals[buyIn.playerId] = (buyInTotals[buyIn.playerId] ?? 0) + buyIn.amount;
      }

      // Load existing cash-out amounts if any
      final cashOutAmounts = <String, double>{};
      for (final cashOut in cashOuts) {
        cashOutAmounts[cashOut.playerId] = (cashOutAmounts[cashOut.playerId] ?? 0) + cashOut.amount;
      }

      if (mounted) {
        setState(() {
          _players = gamePlayers;
          _buyInTotals = buyInTotals;
          _currency = AppCurrencies.fromCode(game.currency);
          _totalBuyIn = buyInTotals.values.fold(0.0, (sum, val) => sum + val);
          
          // Initialize controllers and restore saved cash-out values
          for (final player in gamePlayers) {
            _controllers[player.id] = TextEditingController();
            if (cashOutAmounts.containsKey(player.id) && cashOutAmounts[player.id]! > 0) {
              _controllers[player.id]!.text = cashOutAmounts[player.id]!.toStringAsFixed(2);
            }
          }
          
          _calculateMismatch();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading game data: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _calculateMismatch() {
    _totalCashOut = 0;
    for (final entry in _controllers.entries) {
      final text = entry.value.text.trim();
      if (text.isNotEmpty) {
        _totalCashOut += double.tryParse(text) ?? 0;
      }
    }
    
    final handler = CashOutMismatchHandler();
    setState(() {
      _mismatchSeverity = handler.checkMismatch(
        totalBuyIn: _totalBuyIn,
        totalCashOut: _totalCashOut,
      );
    });
  }

  /// Check if all players have entered cash-out amounts
  bool _allCashOutsEntered() {
    for (final controller in _controllers.values) {
      if (controller.text.trim().isEmpty) {
        return false;
      }
    }
    return _controllers.isNotEmpty;
  }

  // ==================== Action Handlers ====================

  Future<void> _handleAddExpense() async {
    if (_currency == null) return;
    
    final difference = (_totalBuyIn - _totalCashOut).abs();
    
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ExpenseDialog(
        suggestedAmount: difference,
        currency: _currency!,
      ),
    );

    if (result != null && mounted) {
      try {
        final authService = ref.read(authServiceProvider);
        final userId = authService.currentUserId ?? 'guest';
        
        final expense = Expense(
          id: _uuid.v4(),
          gameId: widget.gameId,
          amount: result['amount'],
          category: result['category'],
          note: result['note'],
          timestamp: DateTime.now(),
        );

        // Save expense to Firestore
        final firestoreService = ref.read(firestoreServiceProvider);
        await firestoreService.saveExpense(expense, userId);

        setState(() {
          _expenses.add(expense);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense added successfully')),
          );
          
          // Proceed to settlement
          _submitWithExpense();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding expense: $e')),
          );
        }
      }
    }
  }

  Future<void> _handleAdjustCashOuts() async {
    if (_currency == null) return;
    
    final difference = _totalCashOut - _totalBuyIn;
    final isShortage = difference < 0;
    
    final adjustments = await showDialog<Map<String, double>>(
      context: context,
      builder: (context) => AdjustmentDialog(
        players: _players,
        buyInTotals: _buyInTotals,
        currentCashOuts: _getCurrentCashOuts(),
        amountToAdjust: difference.abs(),
        isShortage: isShortage,
        currency: _currency!,
      ),
    );

    if (adjustments != null && mounted) {
      try {
        // Apply adjustments to controllers
        for (final entry in adjustments.entries) {
          final controller = _controllers[entry.key];
          if (controller != null) {
            final currentValue = double.tryParse(controller.text) ?? 0;
            final newValue = currentValue + entry.value;
            controller.text = newValue.toStringAsFixed(2);
          }
        }

        _calculateMismatch();

        // Save reconciliation record
        final authService = ref.read(authServiceProvider);
        final userId = authService.currentUserId ?? 'guest';
        final firestoreService = ref.read(firestoreServiceProvider);
        
        final reconciliation = CashOutReconciliation(
          id: _uuid.v4(),
          gameId: widget.gameId,
          originalBuyIn: _totalBuyIn,
          originalCashOut: _totalCashOut - adjustments.values.fold(0.0, (sum, val) => sum + val),
          adjustedCashOut: _totalCashOut,
          type: isShortage 
              ? ReconciliationType.distributeLosers 
              : ReconciliationType.distributeWinners,
          adjustments: adjustments,
          timestamp: DateTime.now(),
        );
        
        await firestoreService.saveReconciliation(reconciliation, userId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cash-outs adjusted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adjusting cash-outs: $e')),
          );
        }
      }
    }
  }

  Future<void> _handleContinueAsIs() async {
    // Confirm with user
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Continue with mismatch?'),
        content: Text(
          'The totals don\'t match. This means settlement calculations may not balance perfectly.\n\n'
          'Difference: ${Formatters.formatCurrency((_totalCashOut - _totalBuyIn).abs(), _currency!)}\n\n'
          'Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Continue Anyway'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        // Save reconciliation noting it was continued as-is
        final authService = ref.read(authServiceProvider);
        final userId = authService.currentUserId ?? 'guest';
        final firestoreService = ref.read(firestoreServiceProvider);
        
        final reconciliation = CashOutReconciliation(
          id: _uuid.v4(),
          gameId: widget.gameId,
          originalBuyIn: _totalBuyIn,
          originalCashOut: _totalCashOut,
          adjustedCashOut: _totalCashOut,
          type: ReconciliationType.continueAsIs,
          adjustments: {},
          note: 'User chose to continue with mismatch: ${Formatters.formatCurrency((_totalCashOut - _totalBuyIn).abs(), _currency!)}',
          timestamp: DateTime.now(),
        );
        
        await firestoreService.saveReconciliation(reconciliation, userId);
        
        // Proceed to submit
        await _submitCashOuts();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _handleGoBack() async {
    // Save current cash-out amounts before navigating away
    try {
      // Clear existing cash-outs first
      await ref.read(gameProvider.notifier).clearCashOuts(widget.gameId);
      
      // Save current values
      for (final entry in _controllers.entries) {
        final text = entry.value.text.trim();
        if (text.isNotEmpty) {
          final amount = double.tryParse(text);
          if (amount != null && amount > 0) {
            await ref.read(gameProvider.notifier).addCashOut(
              gameId: widget.gameId,
              playerId: entry.key,
              amount: amount,
            );
          }
        }
      }
      
      if (mounted) {
        // Navigate to home screen (with bottom nav bar)
        context.go(AppConstants.homeRoute);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving cash-outs: $e')),
        );
      }
    }
  }

  Future<void> _handleAddBuyIns() async {
    // Show dialog to add buy-ins for players
    final result = await showDialog<Map<String, double>>(
      context: context,
      builder: (context) => _AddBuyInsDialog(
        players: _players,
        currency: _currency!,
      ),
    );

    if (result != null && mounted) {
      try {
        // Add buy-ins to the game
        for (final entry in result.entries) {
          if (entry.value > 0) {
            await ref.read(gameProvider.notifier).addBuyIn(
              gameId: widget.gameId,
              playerId: entry.key,
              amount: entry.value,
            );
          }
        }

        // Reload game data
        await _loadGameData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Buy-ins added successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding buy-ins: $e')),
          );
        }
      }
    }
  }

  Future<void> _handleCalculateSettlement() async {
    await _submitCashOuts();
  }

  // ==================== Submit Methods ====================

  Future<void> _submitWithExpense() async {
    await _submitCashOuts();
  }

  Future<void> _submitCashOuts() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);

    try {
      final cashOuts = <String, double>{};
      for (final entry in _controllers.entries) {
        final text = entry.value.text.trim();
        if (text.isNotEmpty) {
          cashOuts[entry.key] = double.parse(text);
        } else {
          cashOuts[entry.key] = 0;
        }
      }

      // Clear existing cash-outs
      await ref.read(gameProvider.notifier).clearCashOuts(widget.gameId);

      // Save cash-outs
      for (final entry in cashOuts.entries) {
        if (entry.value > 0) {
          await ref.read(gameProvider.notifier).addCashOut(
            gameId: widget.gameId,
            playerId: entry.key,
            amount: entry.value,
          );
        }
      }

      // End the game
      await ref.read(gameProvider.notifier).endGame(widget.gameId);

      if (mounted) {
        // Navigate to settlement screen
        context.go('${AppConstants.settlementRoute}/${widget.gameId}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving cash-outs: $e')),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  Map<String, double> _getCurrentCashOuts() {
    final cashOuts = <String, double>{};
    for (final entry in _controllers.entries) {
      final text = entry.value.text.trim();
      cashOuts[entry.key] = text.isNotEmpty ? (double.tryParse(text) ?? 0) : 0;
    }
    return cashOuts;
  }

  // ==================== UI ====================

  @override
  Widget build(BuildContext context) {
    if (_currency == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleGoBack,
          tooltip: 'Back to Game',
        ),
        title: const Text('Enter Cash-Outs'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Mismatch Banner - Only show after all cash-outs are entered
                if (_allCashOutsEntered())
                  MismatchBanner(
                    severity: _mismatchSeverity,
                    difference: _totalCashOut - _totalBuyIn,
                    totalBuyIn: _totalBuyIn,
                    totalCashOut: _totalCashOut,
                    currency: _currency!,
                    onAddExpense: _handleAddExpense,
                    onAdjustCashOuts: _handleAdjustCashOuts,
                    onContinueAsIs: _handleContinueAsIs,
                    onGoBack: _handleGoBack,
                    onAddBuyIns: _handleAddBuyIns,
                    onCalculateSettlement: _handleCalculateSettlement,
                  ),

                // Helper text when not all cash-outs are entered
                if (!_allCashOutsEntered())
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.blue.shade50,
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Enter cash-out amounts for all players to see the summary',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Player cash-out entries
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _players.length,
                      itemBuilder: (context, index) {
                        final player = _players[index];
                        final buyInTotal = _buyInTotals[player.id] ?? 0;
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      player.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Buy-in: ${Formatters.formatCurrency(buyInTotal, _currency!)}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _controllers[player.id],
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                                  ],
                                  decoration: InputDecoration(
                                    labelText: 'Cash-Out Amount',
                                    prefixText: '${_currency!.symbol} ',
                                    border: const OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  validator: (value) => Validators.validateCashOutAmount(value),
                                  onChanged: (_) => _calculateMismatch(),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ==================== Add Buy-Ins Dialog ====================

class _AddBuyInsDialog extends StatefulWidget {
  final List<Player> players;
  final Currency currency;

  const _AddBuyInsDialog({
    required this.players,
    required this.currency,
  });

  @override
  State<_AddBuyInsDialog> createState() => _AddBuyInsDialogState();
}

class _AddBuyInsDialogState extends State<_AddBuyInsDialog> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (final player in widget.players) {
      _controllers[player.id] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final result = <String, double>{};
    for (final entry in _controllers.entries) {
      final text = entry.value.text.trim();
      if (text.isNotEmpty) {
        final amount = double.tryParse(text);
        if (amount != null && amount > 0) {
          result[entry.key] = amount;
        }
      }
    }

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Missing Buy-Ins'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.players.length,
          itemBuilder: (context, index) {
            final player = widget.players[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextFormField(
                controller: _controllers[player.id],
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: player.name,
                  prefixText: '${widget.currency.symbol} ',
                  border: const OutlineInputBorder(),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Add Buy-Ins'),
        ),
      ],
    );
  }
}
