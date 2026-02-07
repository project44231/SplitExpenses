import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/currency.dart';
import '../../../core/theme/app_theme.dart';

/// Dialog for configuring game settings
class GameSettingsDialog extends StatefulWidget {
  final List<double> currentAmounts;
  final Currency currency;

  const GameSettingsDialog({
    super.key,
    required this.currentAmounts,
    required this.currency,
  });

  @override
  State<GameSettingsDialog> createState() => _GameSettingsDialogState();
}

class _GameSettingsDialogState extends State<GameSettingsDialog> {
  late List<TextEditingController> _controllers;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controllers = widget.currentAmounts
        .map((amount) => TextEditingController(text: amount.toStringAsFixed(0)))
        .toList();
    
    // Ensure we have at least 4 controllers
    while (_controllers.length < 4) {
      _controllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addAmount() {
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  void _removeAmount(int index) {
    if (_controllers.length > 2) {
      setState(() {
        _controllers[index].dispose();
        _controllers.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need at least 2 quick amounts')),
      );
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final amounts = <double>[];
      for (var controller in _controllers) {
        final text = controller.text.trim();
        if (text.isNotEmpty) {
          amounts.add(double.parse(text));
        }
      }
      
      if (amounts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one amount')),
        );
        return;
      }
      
      // Sort amounts in ascending order
      amounts.sort();
      Navigator.pop(context, amounts);
    }
  }

  void _useDefaultAmounts() {
    setState(() {
      for (var controller in _controllers) {
        controller.dispose();
      }
      _controllers = [20.0, 50.0, 100.0, 200.0]
          .map((amount) => TextEditingController(text: amount.toStringAsFixed(0)))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.75, // 75% of screen height
          maxWidth: 500,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.settings, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Game Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Quick Buy-In Amounts',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _useDefaultAmounts,
                            icon: const Icon(Icons.refresh, size: 14),
                            label: const Text('Reset', style: TextStyle(fontSize: 12)),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Amount inputs
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _controllers.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _controllers[index],
                                    decoration: InputDecoration(
                                      labelText: 'Amount ${index + 1}',
                                      prefixText: widget.currency.symbol,
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                      suffixIcon: _controllers.length > 2
                                          ? IconButton(
                                              icon: const Icon(Icons.remove_circle, color: AppTheme.errorColor, size: 20),
                                              onPressed: () => _removeAmount(index),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            )
                                          : null,
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return null; // Allow empty fields
                                      }
                                      final amount = double.tryParse(value);
                                      if (amount == null) {
                                        return 'Invalid amount';
                                      }
                                      if (amount <= 0) {
                                        return 'Amount must be greater than 0';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Add button
                      OutlinedButton.icon(
                        onPressed: _addAmount,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Amount'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Info box
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppTheme.primaryColor,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'These amounts appear as quick buttons when adding buy-ins.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(12),
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
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Save Settings'),
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
