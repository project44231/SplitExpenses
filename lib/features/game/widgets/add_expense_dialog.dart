import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/currency.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/compat.dart';
import '../../../models/expense.dart';

class AddExpenseDialog extends StatefulWidget {
  final List<Participant> participants;
  final Currency currency;
  final String? preselectedParticipantId;

  const AddExpenseDialog({
    super.key,
    required this.participants,
    required this.currency,
    this.preselectedParticipantId,
  });

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  String? _selectedParticipantId;
  ExpenseCategory _selectedCategory = ExpenseCategory.other;
  SplitMethod _selectedSplitMethod = SplitMethod.equal;
  Map<String, TextEditingController> _splitControllers = {};
  Map<String, double> _calculatedSplits = {};

  @override
  void initState() {
    super.initState();
    _selectedParticipantId = widget.preselectedParticipantId ?? 
        (widget.participants.isNotEmpty ? widget.participants.first.id : null);
    
    // Initialize split controllers for each participant
    for (final participant in widget.participants) {
      _splitControllers[participant.id] = TextEditingController();
    }
    
    _calculateEqualSplits();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    for (final controller in _splitControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _calculateEqualSplits() {
    if (_selectedSplitMethod != SplitMethod.equal) return;
    
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0 || widget.participants.isEmpty) {
      _calculatedSplits = {};
      return;
    }
    
    final share = 1.0 / widget.participants.length;
    _calculatedSplits = {
      for (final p in widget.participants) p.id: share
    };
  }

  void _calculateCustomSplits() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      _calculatedSplits = {};
      return;
    }

    switch (_selectedSplitMethod) {
      case SplitMethod.equal:
        _calculateEqualSplits();
        break;
        
      case SplitMethod.percentage:
        double totalPercentage = 0;
        final percentages = <String, double>{};
        
        for (final participant in widget.participants) {
          final value = double.tryParse(_splitControllers[participant.id]!.text) ?? 0;
          percentages[participant.id] = value;
          totalPercentage += value;
        }
        
        if (totalPercentage == 100) {
          _calculatedSplits = percentages.map((id, pct) => MapEntry(id, pct / 100));
        }
        break;
        
      case SplitMethod.exactAmount:
        double totalAmount = 0;
        final amounts = <String, double>{};
        
        for (final participant in widget.participants) {
          final value = double.tryParse(_splitControllers[participant.id]!.text) ?? 0;
          amounts[participant.id] = value;
          totalAmount += value;
        }
        
        if ((totalAmount - amount).abs() < 0.01) {
          _calculatedSplits = amounts.map((id, amt) => MapEntry(id, amt / amount));
        }
        break;
        
      case SplitMethod.shares:
        double totalShares = 0;
        final shares = <String, double>{};
        
        for (final participant in widget.participants) {
          final value = double.tryParse(_splitControllers[participant.id]!.text) ?? 0;
          shares[participant.id] = value;
          totalShares += value;
        }
        
        if (totalShares > 0) {
          _calculatedSplits = shares.map((id, share) => MapEntry(id, share / totalShares));
        }
        break;
    }
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Icons.restaurant;
      case ExpenseCategory.transport:
        return Icons.directions_car;
      case ExpenseCategory.accommodation:
        return Icons.hotel;
      case ExpenseCategory.utilities:
        return Icons.bolt;
      case ExpenseCategory.groceries:
        return Icons.shopping_cart;
      case ExpenseCategory.entertainment:
        return Icons.movie;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag;
      case ExpenseCategory.healthcare:
        return Icons.local_hospital;
      case ExpenseCategory.other:
        return Icons.more_horiz;
    }
  }

  String _getCategoryLabel(ExpenseCategory category) {
    return category.name[0].toUpperCase() + category.name.substring(1);
  }

  void _saveExpense() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedParticipantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select who paid')),
      );
      return;
    }

    _calculateCustomSplits();

    if (_calculatedSplits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid split configuration')),
      );
      return;
    }

    final amount = double.parse(_amountController.text);
    
    Navigator.pop(context, {
      'amount': amount,
      'description': _descriptionController.text.trim(),
      'paidByParticipantId': _selectedParticipantId!,
      'category': _selectedCategory,
      'splitMethod': _selectedSplitMethod,
      'splitDetails': _calculatedSplits,
      'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Add Expense'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Amount
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          prefixText: widget.currency.symbol,
                          border: const OutlineInputBorder(),
                          hintText: '0.00',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount < AppConstants.minExpenseAmount) {
                            return 'Invalid amount';
                          }
                          if (amount > AppConstants.maxExpenseAmount) {
                            return 'Amount too large';
                          }
                          return null;
                        },
                        onChanged: (_) {
                          if (_selectedSplitMethod == SplitMethod.equal) {
                            setState(() => _calculateEqualSplits());
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., Dinner at restaurant',
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        maxLength: AppConstants.maxDescriptionLength,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Category
                      DropdownButtonFormField<ExpenseCategory>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: ExpenseCategory.values.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Row(
                              children: [
                                Icon(_getCategoryIcon(category), size: 20),
                                const SizedBox(width: 12),
                                Text(_getCategoryLabel(category)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedCategory = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Paid By
                      DropdownButtonFormField<String>(
                        value: _selectedParticipantId,
                        decoration: const InputDecoration(
                          labelText: 'Paid By',
                          border: OutlineInputBorder(),
                        ),
                        items: widget.participants.map((participant) {
                          return DropdownMenuItem(
                            value: participant.id,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: AppTheme.primaryColor,
                                  child: Text(
                                    participant.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(participant.name),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedParticipantId = value);
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select who paid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Split Method
                      DropdownButtonFormField<SplitMethod>(
                        value: _selectedSplitMethod,
                        decoration: const InputDecoration(
                          labelText: 'Split Method',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: SplitMethod.equal,
                            child: Text('Equal Split'),
                          ),
                          DropdownMenuItem(
                            value: SplitMethod.percentage,
                            child: Text('By Percentage'),
                          ),
                          DropdownMenuItem(
                            value: SplitMethod.exactAmount,
                            child: Text('Exact Amounts'),
                          ),
                          DropdownMenuItem(
                            value: SplitMethod.shares,
                            child: Text('Custom Shares'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedSplitMethod = value;
                              if (value == SplitMethod.equal) {
                                _calculateEqualSplits();
                              } else {
                                for (final controller in _splitControllers.values) {
                                  controller.clear();
                                }
                                _calculatedSplits = {};
                              }
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Split Details (if not equal)
                      if (_selectedSplitMethod != SplitMethod.equal) ...[
                        Text(
                          _getSplitInstructions(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...widget.participants.map((participant) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    participant.name,
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: _splitControllers[participant.id],
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      suffixText: _getSplitSuffix(),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                    ],
                                    onChanged: (_) => _calculateCustomSplits(),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 8),
                        if (_calculatedSplits.isNotEmpty)
                          _buildSplitSummary(),
                      ],

                      const SizedBox(height: 16),

                      // Notes (Optional)
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (Optional)',
                          border: OutlineInputBorder(),
                          hintText: 'Additional details...',
                        ),
                        maxLines: 2,
                        maxLength: AppConstants.maxNotesLength,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveExpense,
                      child: const Text('Add Expense'),
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

  String _getSplitInstructions() {
    switch (_selectedSplitMethod) {
      case SplitMethod.percentage:
        return 'Enter percentage for each participant (total must equal 100%):';
      case SplitMethod.exactAmount:
        final amount = double.tryParse(_amountController.text) ?? 0;
        return 'Enter exact amount for each participant (total must equal ${widget.currency.symbol}${amount.toStringAsFixed(2)}):';
      case SplitMethod.shares:
        return 'Enter share ratio for each participant (e.g., 1, 2, 3):';
      default:
        return '';
    }
  }

  String _getSplitSuffix() {
    switch (_selectedSplitMethod) {
      case SplitMethod.percentage:
        return '%';
      case SplitMethod.exactAmount:
        return widget.currency.symbol;
      case SplitMethod.shares:
        return 'shares';
      default:
        return '';
    }
  }

  Widget _buildSplitSummary() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Split Preview',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...widget.participants.map((participant) {
            final share = _calculatedSplits[participant.id] ?? 0;
            final participantAmount = amount * share;
            
            if (participantAmount == 0) return const SizedBox.shrink();
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    participant.name,
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    Formatters.formatCurrency(participantAmount, widget.currency),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
