import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/currency.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../models/player.dart';

/// Dialog for entering cash-out amounts
class CashOutDialog extends StatefulWidget {
  final List<Player> players;
  final Map<String, double> buyInTotals;
  final Currency currency;
  final Map<String, double>? existingCashOuts;

  const CashOutDialog({
    super.key,
    required this.players,
    required this.buyInTotals,
    required this.currency,
    this.existingCashOuts,
  });

  @override
  State<CashOutDialog> createState() => _CashOutDialogState();
}

class _CashOutDialogState extends State<CashOutDialog> {
  final Map<String, TextEditingController> _controllers = {};
  final _formKey = GlobalKey<FormState>();
  bool _showMismatchWarning = false;
  double _totalBuyIn = 0;
  double _totalCashOut = 0;

  @override
  void initState() {
    super.initState();
    _totalBuyIn = widget.buyInTotals.values.fold(0.0, (sum, val) => sum + val);
    
    // Initialize controllers for each player
    for (final player in widget.players) {
      final existingAmount = widget.existingCashOuts?[player.id];
      _controllers[player.id] = TextEditingController(
        text: existingAmount != null && existingAmount > 0 
          ? existingAmount.toStringAsFixed(existingAmount.truncateToDouble() == existingAmount ? 0 : 2)
          : '',
      );
    }
    
    // Calculate initial totals
    _calculateTotals();
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

  void _setQuickAmount(String playerId, double amount) {
    setState(() {
      _controllers[playerId]?.text = amount.toStringAsFixed(0);
      _calculateTotals();
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final cashOuts = <String, double>{};
      for (final entry in _controllers.entries) {
        final text = entry.value.text.trim();
        if (text.isNotEmpty) {
          cashOuts[entry.key] = double.parse(text);
        } else {
          cashOuts[entry.key] = 0;
        }
      }
      Navigator.pop(context, cashOuts);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    widget.existingCashOuts != null && widget.existingCashOuts!.isNotEmpty
                      ? 'Edit Cash-Outs'
                      : 'Enter Cash-Outs',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total Buy-In: ${widget.currency.symbol}${_totalBuyIn.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  if (_totalCashOut > 0)
                    Text(
                      'Total Cash-Out: ${widget.currency.symbol}${_totalCashOut.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: _showMismatchWarning ? Colors.orange : Colors.white70,
                      ),
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
                        'Mismatch: Total cash-out should equal total buy-in',
                        style: TextStyle(
                          fontSize: 12,
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
                  itemCount: widget.players.length,
                  itemBuilder: (context, index) {
                    final player = widget.players[index];
                    final buyInTotal = widget.buyInTotals[player.id] ?? 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppTheme.primaryColor,
                                  child: Text(
                                    player.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
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
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Buy-in: ${widget.currency.symbol}${buyInTotal.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _controllers[player.id],
                              decoration: InputDecoration(
                                labelText: 'Cash-Out Amount',
                                prefixText: widget.currency.symbol,
                                isDense: true,
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                              validator: Validators.validateCashOutAmount,
                              onChanged: (_) => _calculateTotals(),
                            ),
                            const SizedBox(height: 8),
                            // Quick amount buttons (buy-in, double, triple)
                            Wrap(
                              spacing: 6,
                              children: [
                                if (buyInTotal > 0)
                                  OutlinedButton(
                                    onPressed: () => _setQuickAmount(player.id, buyInTotal),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text('Break Even', style: const TextStyle(fontSize: 11)),
                                  ),
                                if (buyInTotal > 0)
                                  OutlinedButton(
                                    onPressed: () => _setQuickAmount(player.id, buyInTotal * 2),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text('2x', style: const TextStyle(fontSize: 11)),
                                  ),
                                OutlinedButton(
                                  onPressed: () => _setQuickAmount(player.id, 0),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text('Bust', style: const TextStyle(fontSize: 11)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                      ),
                      child: Text(
                        widget.existingCashOuts != null && widget.existingCashOuts!.isNotEmpty
                          ? 'Update Settlement'
                          : 'Calculate Settlement',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
