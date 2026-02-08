import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/player.dart';
import '../providers/player_provider.dart';
import 'add_edit_player_dialog.dart';

class PlayerSelectionDialog extends ConsumerStatefulWidget {
  final List<String> excludePlayerIds;

  const PlayerSelectionDialog({
    super.key,
    this.excludePlayerIds = const [],
  });

  @override
  ConsumerState<PlayerSelectionDialog> createState() =>
      _PlayerSelectionDialogState();
}

class _PlayerSelectionDialogState
    extends ConsumerState<PlayerSelectionDialog> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playersAsync = ref.watch(playerProvider);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Player',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.contacts, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                          context.push(AppConstants.playerContactsRoute);
                        },
                        tooltip: 'Manage Contacts',
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search or type new name...',
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
                textCapitalization: TextCapitalization.words,
              ),
            ),

            // Player list
            Expanded(
              child: playersAsync.when(
                data: (players) {
                  // Filter out already selected players
                  var availablePlayers = players
                      .where((p) => !widget.excludePlayerIds.contains(p.id))
                      .toList();

                  // Apply search filter
                  if (_searchQuery.isNotEmpty) {
                    availablePlayers = availablePlayers
                        .where((p) => p.name.toLowerCase().contains(_searchQuery))
                        .toList();
                  }

                  // Sort: favorites first, then by name
                  availablePlayers.sort((a, b) {
                    if (a.isFavorite != b.isFavorite) {
                      return a.isFavorite ? -1 : 1;
                    }
                    return a.name.compareTo(b.name);
                  });

                  return ListView(
                    children: [
                      // Show existing players
                      if (availablePlayers.isNotEmpty) ...[
                        if (_searchQuery.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Text(
                              'Your Contacts',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ...availablePlayers.map((player) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.primaryColor
                                  .withValues(alpha: 0.2),
                              child: Text(
                                player.name[0].toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                            title: Row(
                              children: [
                                Flexible(child: Text(player.name)),
                                if (player.isFavorite) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber.shade700,
                                  ),
                                ],
                              ],
                            ),
                            subtitle: player.gamesPlayed > 0
                                ? Text('${player.gamesPlayed} games played')
                                : null,
                            trailing: PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) {
                                if (value == 'select') {
                                  Navigator.pop(context, player);
                                } else if (value == 'edit') {
                                  _editPlayer(player);
                                } else if (value == 'delete') {
                                  _deletePlayer(player);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'select',
                                  child: Row(
                                    children: [
                                      Icon(Icons.check, size: 18),
                                      SizedBox(width: 12),
                                      Text('Select Player'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 18),
                                      SizedBox(width: 12),
                                      Text('Edit Name'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, size: 18, color: Colors.red),
                                      SizedBox(width: 12),
                                      Text('Delete', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => Navigator.pop(context, player),
                          );
                        }),
                      ],

                      // Show "Add new" option if search query doesn't match existing
                      if (_searchQuery.isNotEmpty &&
                          !availablePlayers.any((p) =>
                              p.name.toLowerCase() == _searchQuery)) ...[
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            'Not found?',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                Colors.green.withValues(alpha: 0.2),
                            child: const Icon(
                              Icons.add,
                              color: Colors.green,
                            ),
                          ),
                          title: Text('Add "${_searchController.text.trim()}"'),
                          subtitle: const Text('Create new contact'),
                          onTap: () => _createNewPlayer(_searchController.text.trim()),
                        ),
                      ],

                      // Empty state
                      if (availablePlayers.isEmpty &&
                          _searchQuery.isEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Contacts Yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add players below',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
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
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _addNewPlayer,
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Player'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addNewPlayer() async {
    final result = await showDialog<Player>(
      context: context,
      builder: (context) => const AddEditPlayerDialog(),
    );

    if (result != null && mounted) {
      try {
        await ref.read(playerProvider.notifier).addPlayer(
          name: result.name,
          email: result.email,
          phone: result.phone,
        );
        if (mounted) {
          Navigator.pop(context, result);
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

  Future<void> _createNewPlayer(String name) async {
    if (name.isEmpty) return;

    try {
      final player = await ref.read(playerProvider.notifier).addPlayer(name: name);
      if (mounted && player != null) {
        Navigator.pop(context, player);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating player: $e')),
        );
      }
    }
  }

  Future<void> _editPlayer(Player player) async {
    final result = await showDialog<dynamic>(
      context: context,
      builder: (context) => AddEditPlayerDialog(player: player),
    );

    if (result == 'DELETE' && mounted) {
      // Handle delete from edit dialog
      _deletePlayer(player);
    } else if (result is Player && mounted) {
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

  Future<void> _deletePlayer(Player player) async {
    // Check if player has been used in any games
    if (player.gamesPlayed > 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cannot Delete'),
          content: Text(
            '${player.name} has played ${player.gamesPlayed} game${player.gamesPlayed != 1 ? 's' : ''} and cannot be deleted.\n\n'
            'Players with game history are kept for statistics.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Player'),
        content: Text(
          'Are you sure you want to delete ${player.name}?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await ref.read(playerProvider.notifier).deletePlayer(player.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${player.name} deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting player: $e')),
          );
        }
      }
    }
  }
}
