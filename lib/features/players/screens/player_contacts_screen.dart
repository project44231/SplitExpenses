import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/constants/currency.dart';
import '../../../models/player.dart';
import '../providers/player_provider.dart';
import '../widgets/add_edit_player_dialog.dart';

class PlayerContactsScreen extends ConsumerStatefulWidget {
  const PlayerContactsScreen({super.key});

  @override
  ConsumerState<PlayerContactsScreen> createState() =>
      _PlayerContactsScreenState();
}

class _PlayerContactsScreenState extends ConsumerState<PlayerContactsScreen> {
  String _searchQuery = '';
  bool _showFavoritesOnly = false;

  @override
  Widget build(BuildContext context) {
    final playersAsync = ref.watch(playerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Contacts'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.star : Icons.star_border,
              color: _showFavoritesOnly ? Colors.amber : Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showFavoritesOnly = !_showFavoritesOnly;
              });
            },
            tooltip: 'Show Favorites Only',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search players...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Player list
          Expanded(
            child: playersAsync.when(
              data: (players) {
                // Apply filters
                var filteredPlayers = players.where((p) {
                  final matchesSearch = p.name.toLowerCase().contains(_searchQuery) ||
                      (p.email?.toLowerCase().contains(_searchQuery) ?? false);
                  final matchesFavorite = !_showFavoritesOnly || p.isFavorite;
                  return matchesSearch && matchesFavorite;
                }).toList();

                // Sort: favorites first, then by name
                filteredPlayers.sort((a, b) {
                  if (a.isFavorite != b.isFavorite) {
                    return a.isFavorite ? -1 : 1;
                  }
                  return a.name.compareTo(b.name);
                });

                if (filteredPlayers.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredPlayers.length,
                  itemBuilder: (context, index) {
                    final player = filteredPlayers[index];
                    return _buildPlayerCard(player);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPlayerDialog(),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Add Player'),
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_searchQuery.isNotEmpty || _showFavoritesOnly) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No players found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            Text(
              'No Contacts Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add players to quickly include them in future games',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerCard(Player player) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showEditPlayerDialog(player),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                child: Text(
                  player.name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Player info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            player.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (player.isFavorite) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.star,
                            size: 18,
                            color: Colors.amber.shade700,
                          ),
                        ],
                      ],
                    ),
                    if (player.email != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        player.email!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    if (player.gamesPlayed > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildStatChip(
                            '${player.gamesPlayed} games',
                            Icons.sports_esports,
                            Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          _buildStatChip(
                            '${player.totalProfit >= 0 ? '+' : ''}${Formatters.formatCurrency(player.totalProfit, AppCurrencies.usd)}',
                            Icons.trending_up,
                            player.totalProfit >= 0 ? Colors.green : Colors.red,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Favorite button
              IconButton(
                icon: Icon(
                  player.isFavorite ? Icons.star : Icons.star_border,
                  color: player.isFavorite ? Colors.amber.shade700 : Colors.grey,
                ),
                onPressed: () => _toggleFavorite(player),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddPlayerDialog() async {
    final result = await showDialog<Player>(
      context: context,
      builder: (context) => const AddEditPlayerDialog(),
    );

    if (result != null) {
      try {
        await ref.read(playerProvider.notifier).addPlayer(
          name: result.name,
          email: result.email,
          phone: result.phone,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${result.name} added to contacts')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding player: $e')),
          );
        }
      }
    }
  }

  Future<void> _showEditPlayerDialog(Player player) async {
    final result = await showDialog<Player>(
      context: context,
      builder: (context) => AddEditPlayerDialog(player: player),
    );

    if (result != null) {
      try {
        await ref.read(playerProvider.notifier).updatePlayer(result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${result.name} updated')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating player: $e')),
          );
        }
      }
    }
  }

  Future<void> _toggleFavorite(Player player) async {
    try {
      final updated = player.copyWith(isFavorite: !player.isFavorite);
      await ref.read(playerProvider.notifier).updatePlayer(updated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating favorite: $e')),
        );
      }
    }
  }
}
