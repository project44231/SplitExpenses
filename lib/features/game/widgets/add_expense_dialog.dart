import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/currency.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/compat.dart';

class AddExpenseDialog extends StatefulWidget {
  final List<Participant> participants;
  final Currency currency;
  final String? preselectedParticipantId;
  final Future<Participant?> Function(String name)? onAddParticipant;

  const AddExpenseDialog({
    super.key,
    required this.participants,
    required this.currency,
    this.preselectedParticipantId,
    this.onAddParticipant,
  });

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final _imagePicker = ImagePicker();
  
  String? _selectedParticipantId;
  ExpenseCategory _selectedCategory = ExpenseCategory.other;
  SplitMethod _selectedSplitMethod = SplitMethod.equal;
  Map<String, TextEditingController> _splitControllers = {};
  Map<String, double> _calculatedSplits = {};
  List<Participant> _localParticipants = [];
  Set<String> _selectedResponsibleIds = {};
  File? _selectedReceiptFile;

  @override
  void initState() {
    super.initState();
    _localParticipants = List.from(widget.participants);
    _selectedParticipantId = widget.preselectedParticipantId; // Empty by default
    
    // Initialize split controllers for each participant
    for (final participant in _localParticipants) {
      _splitControllers[participant.id] = TextEditingController();
    }
    
    _calculateEqualSplits();
  }

  Future<void> _showAddParticipantDialog() async {
    if (widget.onAddParticipant == null) return;

    final nameController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Person'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'Enter person name',
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.isNotEmpty) {
      final participant = await widget.onAddParticipant!(nameController.text);
      
      if (participant != null && mounted) {
        setState(() {
          _localParticipants.add(participant);
          _splitControllers[participant.id] = TextEditingController();
          _selectedResponsibleIds.add(participant.id); // Add to responsible by default
          if (_selectedParticipantId == null) {
            _selectedParticipantId = participant.id;
          }
          _calculateEqualSplits();
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${participant.name} added')),
          );
        }
      }
    }
    
    // Dispose after a small delay to ensure dialog is fully closed
    Future.delayed(const Duration(milliseconds: 100), () {
      nameController.dispose();
    });
  }

  Future<void> _pickReceiptImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedReceiptFile = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
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
    if (amount <= 0 || _selectedResponsibleIds.isEmpty) {
      _calculatedSplits = {};
      return;
    }
    
    final share = 1.0 / _selectedResponsibleIds.length;
    _calculatedSplits = {
      for (final id in _selectedResponsibleIds) id: share
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
        
        for (final id in _selectedResponsibleIds) {
          final value = double.tryParse(_splitControllers[id]!.text) ?? 0;
          percentages[id] = value;
          totalPercentage += value;
        }
        
        if (totalPercentage == 100) {
          _calculatedSplits = percentages.map((id, pct) => MapEntry(id, pct / 100));
        }
        break;
        
      case SplitMethod.shares:
        double totalShares = 0;
        final shares = <String, double>{};
        
        for (final id in _selectedResponsibleIds) {
          final value = double.tryParse(_splitControllers[id]!.text) ?? 0;
          shares[id] = value;
          totalShares += value;
        }
        
        if (totalShares > 0) {
          _calculatedSplits = shares.map((id, share) => MapEntry(id, share / totalShares));
        }
        break;
        
      case SplitMethod.exactAmount:
        // Removed - not needed
        break;
    }
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

    if (_selectedResponsibleIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one person responsible')),
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
      'receiptFile': _selectedReceiptFile,
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
                      // Description (moved to first)
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Expense Name',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., Dinner at restaurant',
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        maxLength: AppConstants.maxDescriptionLength,
                        autofocus: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter expense name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Amount (moved to second)
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

                      // Category Selector
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
                                Text(category.icon, style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 12),
                                Text(category.displayName),
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
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedParticipantId,
                              decoration: const InputDecoration(
                                labelText: 'Paid By',
                                border: OutlineInputBorder(),
                              ),
                              items: _localParticipants.map((participant) {
                                return DropdownMenuItem(
                                  value: participant.id,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
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
                                      Text(
                                        participant.name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
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
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _showAddParticipantDialog,
                            icon: const Icon(Icons.person_add),
                            tooltip: 'Add New Person',
                            style: IconButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // People Responsible
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'People Responsible',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    if (_selectedResponsibleIds.length == _localParticipants.length) {
                                      // Deselect all
                                      _selectedResponsibleIds.clear();
                                    } else {
                                      // Select all
                                      _selectedResponsibleIds = _localParticipants.map((p) => p.id).toSet();
                                    }
                                    _calculateEqualSplits();
                                  });
                                },
                                icon: Icon(
                                  _selectedResponsibleIds.length == _localParticipants.length
                                      ? Icons.clear_all
                                      : Icons.done_all,
                                  size: 18,
                                ),
                                label: Text(
                                  _selectedResponsibleIds.length == _localParticipants.length
                                      ? 'Clear All'
                                      : 'Add All',
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                ),
                              ),
                              IconButton(
                                onPressed: _showAddParticipantDialog,
                                icon: const Icon(Icons.person_add),
                                tooltip: 'Add New Person',
                                iconSize: 20,
                                style: IconButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                                  padding: const EdgeInsets.all(8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: _localParticipants.map((participant) {
                            final isSelected = _selectedResponsibleIds.contains(participant.id);
                            return CheckboxListTile(
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedResponsibleIds.add(participant.id);
                                  } else {
                                    _selectedResponsibleIds.remove(participant.id);
                                  }
                                  _calculateEqualSplits();
                                });
                              },
                              title: Text(participant.name),
                              dense: true,
                              controlAffinity: ListTileControlAffinity.leading,
                            );
                          }).toList(),
                        ),
                      ),
                      if (_selectedResponsibleIds.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Please select at least one person',
                            style: TextStyle(
                              color: AppTheme.errorColor,
                              fontSize: 12,
                            ),
                          ),
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
                                // Clear controllers only for selected responsible people
                                for (final id in _selectedResponsibleIds) {
                                  _splitControllers[id]?.clear();
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
                        ..._selectedResponsibleIds.map((id) {
                          final participant = _localParticipants.firstWhere((p) => p.id == id);
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
                                    controller: _splitControllers[id],
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
                      
                      const SizedBox(height: 16),

                      // Receipt Section
                      const Text(
                        'Receipt (Optional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildReceiptSection(),
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
        return 'Enter percentage for each person (total must equal 100%):';
      case SplitMethod.shares:
        return 'Enter share ratio for each person (e.g., 1, 2, 3):';
      default:
        return '';
    }
  }

  String _getSplitSuffix() {
    switch (_selectedSplitMethod) {
      case SplitMethod.percentage:
        return '%';
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
          ..._selectedResponsibleIds.map((id) {
            final participant = _localParticipants.firstWhere((p) => p.id == id);
            final share = _calculatedSplits[id] ?? 0;
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

  Widget _buildReceiptSection() {
    if (_selectedReceiptFile != null) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _selectedReceiptFile!,
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _selectedReceiptFile = null;
                  });
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickReceiptImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickReceiptImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Attach a photo of the receipt',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
