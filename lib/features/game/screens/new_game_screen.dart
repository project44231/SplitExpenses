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
  final Set<String> _selectedPlayerIds = {};
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _playerSearchController = TextEditingController();
  final TextEditingController _newPlayerNameController = TextEditingController();
  Currency _selectedCurrency = AppCurrencies.usd;
  bool _isCreating = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _notesController.dispose();
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
        title: const Text('Add New Player'),
        content: TextField(
          controller: _newPlayerNameController,
          decoration: const InputDecoration(
            labelText: 'Player Name',
            hintText: 'Enter player name',
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

  Future<void> _createGame() async {
    if (_selectedPlayerIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one player')),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final game = await ref.read(gameProvider.notifier).createGame(
            playerIds: _selectedPlayerIds.toList(),
            currency: _selectedCurrency.code,
            notes: _notesController.text.trim().isEmpty 
                ? null 
                : _notesController.text.trim(),
          );

      if (game != null && mounted) {
        // Set as active game
        ref.read(activeGameProvider.notifier).state = game;
        
        // Navigate to Active Game screen
        context.go('${AppConstants.activeGameRoute}/${game.id}');
      } else {
        throw Exception('Failed to create game');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating game: $e')),
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
        title: const Text('New Game'),
      ),
      body: playersAsync.when(
        data: (allPlayers) {
          // Filter players based on search
          final players = _searchQuery.isEmpty
              ? allPlayers
              : allPlayers.where((p) => 
                  p.name.toLowerCase().contains(_searchQuery.toLowerCase())
                ).toList();

          return Column(
            children: [
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

              // Player Search
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _playerSearchController,
                        decoration: InputDecoration(
                          hintText: 'Search players...',
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
                  color: AppTheme.accentColor.withValues(alpha: 0.1),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppTheme.accentColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_selectedPlayerIds.length} player${_selectedPlayerIds.length == 1 ? '' : 's'} selected',
                        style: TextStyle(
                          color: AppTheme.accentColor,
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
                                  ? AppTheme.accentColor 
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
                            activeColor: AppTheme.accentColor,
                          );
                        },
                      ),
              ),

              // Notes (Optional)
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        hintText: 'Add game notes...',
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    
                    // Start Game Button
                    ElevatedButton(
                      onPressed: _isCreating || _selectedPlayerIds.isEmpty
                          ? null
                          : _createGame,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppTheme.accentColor,
                      ),
                      child: _isCreating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Start Game (${_selectedPlayerIds.length} ${_selectedPlayerIds.length == 1 ? 'Player' : 'Players'})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
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
