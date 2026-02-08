import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/currency.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../models/player.dart';
import '../providers/game_provider.dart';
import '../../players/providers/player_provider.dart';

class CashOutScreen extends ConsumerStatefulWidget {
  final String gameId;

  const CashOutScreen({super.key, required this.gameId});

  @override
  ConsumerState<CashOutScreen> createState() => _CashOutScreenState();
}

class _CashOutScreenState extends ConsumerState<CashOutScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final _formKey = GlobalKey<FormState>();
  bool _showMismatchWarning = false;
  double _totalBuyIn = 0;
  double _totalCashOut = 0;
  bool _isSubmitting = false;

  List<Player> _players = [];
  Map<String, double> _buyInTotals = {};
  Currency? _currency;

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

      if (mounted) {
        setState(() {
          _players = gamePlayers;
          _buyInTotals = buyInTotals;
          _currency = AppCurrencies.fromCode(game.currency);
          _totalBuyIn = buyInTotals.values.fold(0.0, (sum, val) => sum + val);
          
          // Initialize controllers
          for (final player in gamePlayers) {
            _controllers[player.id] = TextEditingController();
          }
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

  void _calculateTotals() {
    setState(() {
      _totalCashOut = 0;
      for (final entry in _controllers.entries) {
        final text = entry.value.text.trim();
        if (text.isNotEmpty) {
          _totalCashOut += double.tryParse(text) ?? 0;
        }
      }
      
      // Check for mismatch
      final difference = (_totalCashOut - _totalBuyIn).abs();
      _showMismatchWarning = difference > 0.01; // Allow 1 cent tolerance
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
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

        // NOW end the game (only when cash-outs are submitted)
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
  }

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
          onPressed: () {
            // Go back to active game (game stays active)
            context.go('${AppConstants.activeGameRoute}/${widget.gameId}');
          },
          tooltip: 'Back to Game',
        ),
        title: const Text('Enter Cash-Outs'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Column(
        children: [
          // Header with totals
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Buy-In',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          Formatters.formatCurrency(_totalBuyIn, _currency!),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    if (_totalCashOut > 0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Total Cash-Out',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            Formatters.formatCurrency(_totalCashOut, _currency!),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _showMismatchWarning ? Colors.orange : Colors.white,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Warning banner
          if (_showMismatchWarning)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.orange.shade100,
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade800, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Warning: Total cash-out should equal total buy-in (${Formatters.formatCurrency(_totalBuyIn, _currency!)})',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Player List
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
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppTheme.primaryColor,
                                child: Text(
                                  player.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      player.name,
                                      style: const TextStyle(
                                        fontSize: 18,
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
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _controllers[player.id],
                            decoration: InputDecoration(
                              labelText: 'Cash-Out Amount',
                              prefixText: _currency!.symbol,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                            validator: Validators.validateCashOutAmount,
                            onChanged: (_) => _calculateTotals(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Action Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 0),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Calculate Settlement',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
