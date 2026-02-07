import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/currency.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../models/player.dart';
import '../../../models/buy_in.dart';

/// Dialog for adding a buy-in
class AddBuyInDialog extends StatefulWidget {
  final List<Player> players;
  final Currency currency;
  final String? preselectedPlayerId;

  const AddBuyInDialog({
    super.key,
    required this.players,
    required this.currency,
    this.preselectedPlayerId,
  });

  @override
  State<AddBuyInDialog> createState() => _AddBuyInDialogState();
}

class _AddBuyInDialogState extends State<AddBuyInDialog> {
  final TextEditingController _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedPlayerId;
  BuyInType _buyInType = BuyInType.initial;

  // Quick amount buttons
  final List<double> _quickAmounts = [20, 50, 100, 200];

  @override
  void initState() {
    super.initState();
    _selectedPlayerId = widget.preselectedPlayerId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _setQuickAmount(double amount) {
    setState(() {
      _amountController.text = amount.toStringAsFixed(0);
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedPlayerId != null) {
      final amount = double.parse(_amountController.text);
      Navigator.pop(context, {
        'playerId': _selectedPlayerId,
        'amount': amount,
        'type': _buyInType,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                const Text(
                  'Add Buy-In',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Player Selection
                DropdownButtonFormField<String>(
                  value: _selectedPlayerId,
                  decoration: const InputDecoration(
                    labelText: 'Player',
                    prefixIcon: Icon(Icons.person),
                  ),
                  items: widget.players.map((player) {
                    return DropdownMenuItem(
                      value: player.id,
                      child: Text(player.name),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) return 'Please select a player';
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _selectedPlayerId = value;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Amount Input
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixIcon: const Icon(Icons.attach_money),
                    prefixText: widget.currency.symbol,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: Validators.validateBuyInAmount,
                  autofocus: true,
                ),
                const SizedBox(height: 16),

                // Quick Amount Buttons
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _quickAmounts.map((amount) {
                    return OutlinedButton(
                      onPressed: () => _setQuickAmount(amount),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text('${widget.currency.symbol}${amount.toInt()}'),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Buy-In Type
                const Text(
                  'Type',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<BuyInType>(
                  segments: const [
                    ButtonSegment(
                      value: BuyInType.initial,
                      label: Text('Initial'),
                      icon: Icon(Icons.add_circle_outline),
                    ),
                    ButtonSegment(
                      value: BuyInType.rebuy,
                      label: Text('Rebuy'),
                      icon: Icon(Icons.refresh),
                    ),
                  ],
                  selected: {_buyInType},
                  onSelectionChanged: (Set<BuyInType> newSelection) {
                    setState(() {
                      _buyInType = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Actions
                Row(
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
                          backgroundColor: AppTheme.accentColor,
                        ),
                        child: const Text('Add Buy-In'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
