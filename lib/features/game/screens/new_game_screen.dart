import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/currency.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/compat.dart';
import '../providers/game_provider.dart';
import '../../players/providers/player_provider.dart';

class NewGameScreen extends ConsumerStatefulWidget {
  const NewGameScreen({super.key});

  @override
  ConsumerState<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends ConsumerState<NewGameScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Currency _selectedCurrency = AppCurrencies.usd;
  bool _isCreating = false;
  Set<String> _selectedParticipantIds = {};
  List<Participant> _allParticipants = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadParticipants());
  }

  Future<void> _loadParticipants() async {
    await ref.read(playerProvider.notifier).loadPlayers();
    final playersAsync = ref.read(playerProvider);
    final players = playersAsync.when(
      data: (players) => players,
      loading: () => <Participant>[],
      error: (_, __) => <Participant>[],
    );
    if (mounted) {
      setState(() {
        _allParticipants = players;
      });
    }
  }

  Future<void> _showAddParticipantDialog() async {
    final nameController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.person_add, color: AppTheme.primaryColor, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Add Member'),
          ],
        ),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Name',
            hintText: 'Enter member name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            prefixIcon: const Icon(Icons.account_circle_outlined),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.isNotEmpty) {
      final participant = await ref.read(playerProvider.notifier).addPlayer(name: nameController.text);
      
      if (participant != null && mounted) {
        setState(() {
          _allParticipants.add(participant);
          _selectedParticipantIds.add(participant.id);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${participant.name} added')),
          );
        }
      }
    }
    
    Future.delayed(const Duration(milliseconds: 100), () {
      nameController.dispose();
    });
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final event = await ref.read(gameProvider.notifier).createEvent(
            participantIds: _selectedParticipantIds.toList(),
            name: _eventNameController.text.trim(),
            description: _descriptionController.text.trim().isEmpty 
                ? null 
                : _descriptionController.text.trim(),
            currency: _selectedCurrency.code,
          );

      if (event != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event created successfully!')),
        );
        
        // Navigate to Event detail screen
        context.go('${AppConstants.groupExpenseDetailRoute}/${event.id}');
      } else {
        throw Exception('Failed to create event');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating event: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // App Icon
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'images/app_icon.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Event Name
                TextFormField(
                  controller: _eventNameController,
                  decoration: const InputDecoration(
                    labelText: 'Event Name',
                    hintText: 'e.g., Weekend Trip, Roommate Expenses',
                    prefixIcon: Icon(Icons.label),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  autofocus: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an event name';
                    }
                    if (value.length > AppConstants.maxGroupNameLength) {
                      return 'Name too long (max ${AppConstants.maxGroupNameLength} characters)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                
                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'e.g., Shared expenses for Bali trip',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLength: AppConstants.maxDescriptionLength,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                
                // Currency Selection
                DropdownButtonFormField<Currency>(
                  value: _selectedCurrency,
                  decoration: const InputDecoration(
                    labelText: 'Currency',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                  ),
                  items: AppCurrencies.all.map((currency) {
                    return DropdownMenuItem(
                      value: currency,
                      child: Text('${currency.symbol} ${currency.code} - ${currency.name}'),
                    );
                  }).toList(),
                  onChanged: (currency) {
                    if (currency != null) {
                      setState(() {
                        _selectedCurrency = currency;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
                
                // Members Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Members (Optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_allParticipants.isNotEmpty)
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                if (_selectedParticipantIds.length == _allParticipants.length) {
                                  _selectedParticipantIds.clear();
                                } else {
                                  _selectedParticipantIds = _allParticipants.map((p) => p.id).toSet();
                                }
                              });
                            },
                            icon: Icon(
                              _selectedParticipantIds.length == _allParticipants.length
                                  ? Icons.clear_all
                                  : Icons.done_all,
                              size: 16,
                            ),
                            label: Text(
                              _selectedParticipantIds.length == _allParticipants.length
                                  ? 'Clear'
                                  : 'All',
                              style: const TextStyle(fontSize: 13),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            ),
                          ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppTheme.primaryColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            onPressed: _showAddParticipantDialog,
                            icon: Icon(Icons.person_add, color: AppTheme.primaryColor, size: 18),
                            tooltip: 'Add Member',
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_allParticipants.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.people_outline, color: Colors.grey[600], size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No members added yet. Tap + to add members.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[50],
                    ),
                    child: Column(
                      children: _allParticipants.map((participant) {
                        final isSelected = _selectedParticipantIds.contains(participant.id);
                        return ListTile(
                          leading: Checkbox(
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedParticipantIds.add(participant.id);
                                } else {
                                  _selectedParticipantIds.remove(participant.id);
                                }
                              });
                            },
                          ),
                          title: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppTheme.primaryColor,
                                child: Text(
                                  participant.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  participant.name,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.red[400],
                            tooltip: 'Remove member',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: Row(
                                    children: [
                                      Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
                                      const SizedBox(width: 12),
                                      const Text('Delete Member?'),
                                    ],
                                  ),
                                  content: Text(
                                    'Permanently delete ${participant.name}? They will be removed from everywhere in the app.',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      ),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      ),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true && mounted) {
                                try {
                                  // Delete from database
                                  await ref.read(playerProvider.notifier).deletePlayer(participant.id);
                                  
                                  // Update local list
                                  setState(() {
                                    _allParticipants.remove(participant);
                                    _selectedParticipantIds.remove(participant.id);
                                  });
                                  
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${participant.name} permanently deleted'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to delete ${participant.name}: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                          dense: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 24),
                
                // Info Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Members can be added now or later when adding expenses.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Create Button
                ElevatedButton.icon(
                  onPressed: _isCreating ? null : _createEvent,
                  icon: _isCreating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.check),
                  label: Text(_isCreating ? 'Creating...' : 'Create Event'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
