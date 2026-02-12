import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/currency.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/game_provider.dart';
import '../../players/providers/player_provider.dart';

class NewGameScreen extends ConsumerStatefulWidget {
  const NewGameScreen({super.key});

  @override
  ConsumerState<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends ConsumerState<NewGameScreen> {
  final _formKey = GlobalKey<FormState>();
  final Set<String> _selectedPlayerIds = {};
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _playerSearchController = TextEditingController();
  final TextEditingController _newPlayerNameController = TextEditingController();
  Currency _selectedCurrency = AppCurrencies.usd;
  bool _isCreating = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _groupNameController.dispose();
    _descriptionController.dispose();
    _playerSearchController.dispose();
    _newPlayerNameController.dispose();
    super.dispose();
  }

  void _togglePlayer(String playerId) {
    setState(() {
      if (_selectedPlayerIds.contains(playerId)) {
        _selectedPlayerIds.remove(playerId);
      } else {
        _selectedPlayerIds.add(playerId);
      }
    });
  }

  Future<void> _showAddPlayerDialog() async {
    _newPlayerNameController.clear();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Participant'),
        content: TextField(
          controller: _newPlayerNameController,
          decoration: const InputDecoration(
            labelText: 'Participant Name',
            hintText: 'Enter participant name',
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

    if (result == true && _newPlayerNameController.text.isNotEmpty) {
      final player = await ref.read(playerProvider.notifier).addPlayer(
            name: _newPlayerNameController.text,
          );
      
      if (player != null && mounted) {
        setState(() {
          _selectedPlayerIds.add(player.id);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${player.name} added')),
        );
      }
    }
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPlayerIds.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least 2 participants')),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final group = await ref.read(gameProvider.notifier).createEvent(
            participantIds: _selectedPlayerIds.toList(),
            name: _groupNameController.text.trim(),
            description: _descriptionController.text.trim().isEmpty 
                ? null 
                : _descriptionController.text.trim(),
            currency: _selectedCurrency.code,
          );

      if (group != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group expense created successfully!')),
        );
        
        // Navigate to Group Expense detail screen
        context.go('${AppConstants.groupExpenseDetailRoute}/${group.id}');
      } else {
        throw Exception('Failed to create group expense');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating group expense: $e')),
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
    final playersAsync = ref.watch(playerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group Expense'),
      ),
      body: playersAsync.when(
        data: (allPlayers) {
          // Filter players based on search
          final players = _searchQuery.isEmpty
              ? allPlayers
              : allPlayers.where((p) => 
                  p.name.toLowerCase().contains(_searchQuery.toLowerCase())
                ).toList();

          return Form(
            key: _formKey,
            child: Column(
              children: [
                // Group Name and Description
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).cardColor,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _groupNameController,
                        decoration: const InputDecoration(
                          labelText: 'Group Name',
                          hintText: 'e.g., Weekend Trip, Roommate Expenses',
                          prefixIcon: Icon(Icons.group_work),
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a group name';
                          }
                          if (value.length > AppConstants.maxGroupNameLength) {
                            return 'Name too long (max ${AppConstants.maxGroupNameLength} characters)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                          hintText: 'e.g., Shared expenses for Bali trip',
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(),
                        ),
                        maxLength: AppConstants.maxDescriptionLength,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Currency Selection
                Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).cardColor,
                child: Row(
                  children: [
                    const Icon(Icons.attach_money, color: AppTheme.primaryColor),
                    const SizedBox(width: 12),
                    const Text(
                      'Currency:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButton<Currency>(
                        value: _selectedCurrency,
                        isExpanded: true,
                        items: AppCurrencies.all.map((currency) {
                          return DropdownMenuItem(
                            value: currency,
                            child: Text('${currency.symbol} ${currency.code}'),
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
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1),

              // Participant Search
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _playerSearchController,
                        decoration: InputDecoration(
                          hintText: 'Search participants...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _playerSearchController.clear();
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _showAddPlayerDialog,
                      icon: const Icon(Icons.person_add),
                      label: const Text('Add'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Selected Players Count
              if (_selectedPlayerIds.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_selectedPlayerIds.length} player${_selectedPlayerIds.length == 1 ? '' : 's'} selected',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              // Player List
              Expanded(
                child: players.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchQuery.isEmpty 
                                  ? Icons.people_outline 
                                  : Icons.search_off,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No players yet'
                                  : 'No players found',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: _showAddPlayerDialog,
                              icon: const Icon(Icons.person_add),
                              label: const Text('Add Your First Player'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: players.length,
                        itemBuilder: (context, index) {
                          final player = players[index];
                          final isSelected = _selectedPlayerIds.contains(player.id);

                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (_) => _togglePlayer(player.id),
                            title: Text(
                              player.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: player.email != null 
                                ? Text(player.email!)
                                : null,
                            secondary: CircleAvatar(
                              backgroundColor: isSelected 
                                  ? AppTheme.primaryColor 
                                  : Colors.grey.shade300,
                              child: Text(
                                player.name[0].toUpperCase(),
                                style: TextStyle(
                                  color: isSelected 
                                      ? Colors.white 
                                      : Colors.grey.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            activeColor: AppTheme.primaryColor,
                          );
                        },
                      ),
              ),

              // Bottom Bar with Create Button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.people, color: AppTheme.primaryColor),
                          const SizedBox(width: 12),
                          Text(
                            '${_selectedPlayerIds.length} ${_selectedPlayerIds.length == 1 ? 'participant' : 'participants'} selected',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _isCreating ? null : _createGroup,
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
                      label: Text(_isCreating ? 'Creating...' : 'Create Group'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(playerProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
