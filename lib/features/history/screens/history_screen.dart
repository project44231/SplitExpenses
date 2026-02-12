import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/compat.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../services/firestore_service.dart';
import '../widgets/game_history_card.dart';
import '../widgets/leaderboard_tab.dart';
import '../widgets/history_filter_dialog.dart';


class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Game> _endedGames = [];
  List<Game> _filteredGames = [];
  Map<String, List<BuyIn>> _gamesBuyIns = {};
  Map<String, List<dynamic>> _gamesCashOuts = {}; // Removed CashOut model
  HistoryFilters _filters = HistoryFilters();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      
      // Check if user is authenticated
      if (authService.isGuestMode) {
        // Guest users can't access history
        setState(() => _isLoading = false);
        return;
      }

      // Get current user ID
      final userId = authService.currentUserId;
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Load games directly from Firebase only (not local storage)
      final firestoreService = FirestoreService();
      final allGames = await firestoreService.getEvents(userId);

      // Filter ended games and sort by end time
      final endedGames = allGames
          .where((g) => g.status == EventStatus.settled && g.endTime != null)
          .toList()
        ..sort((a, b) => b.endTime!.compareTo(a.endTime!));

      // Load buy-ins and cash-outs for each game from Firebase only
      final gamesBuyIns = <String, List<BuyIn>>{};
      final gamesCashOuts = <String, List<dynamic>>{}; // Removed CashOut model

      for (final game in endedGames) {
        final buyIns = await firestoreService.getExpenses(game.id);
        // final cashOuts = await firestoreService.getCashOuts(game.id); // Removed
        gamesBuyIns[game.id] = buyIns;
        // gamesCashOuts[game.id] = cashOuts; // Removed
      }

      if (mounted) {
        setState(() {
          _endedGames = endedGames;
          _gamesBuyIns = gamesBuyIns;
          _gamesCashOuts = gamesCashOuts;
          _isLoading = false;
        });
        _applyFilters();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading history: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    List<Game> filtered = List.from(_endedGames);

    // Apply date filter
    final now = DateTime.now();
    switch (_filters.dateFilter) {
      case DateFilter.week:
        final weekAgo = now.subtract(const Duration(days: 7));
        filtered = filtered.where((g) => g.endTime!.isAfter(weekAgo)).toList();
        break;
      case DateFilter.month:
        final monthAgo = DateTime(now.year, now.month - 1, now.day);
        filtered = filtered.where((g) => g.endTime!.isAfter(monthAgo)).toList();
        break;
      case DateFilter.threeMonths:
        final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
        filtered = filtered.where((g) => g.endTime!.isAfter(threeMonthsAgo)).toList();
        break;
      case DateFilter.custom:
        if (_filters.customStartDate != null && _filters.customEndDate != null) {
          filtered = filtered.where((g) {
            final endTime = g.endTime!;
            return endTime.isAfter(_filters.customStartDate!) &&
                endTime.isBefore(_filters.customEndDate!.add(const Duration(days: 1)));
          }).toList();
        }
        break;
      case DateFilter.all:
        break;
    }

    // Apply player filter
    if (_filters.selectedPlayerId != null) {
      filtered = filtered.where((g) => (g as Event).playerIds.contains(_filters.selectedPlayerId)).toList();
    }

    // Apply sorting
    switch (_filters.sortOption) {
      case SortOption.dateNewest:
        filtered.sort((a, b) => (b as Event).endTime!.compareTo((a as Event).endTime!));
        break;
      case SortOption.dateOldest:
        filtered.sort((a, b) => (a as Event).endTime!.compareTo((b as Event).endTime!));
        break;
      case SortOption.potSize:
        filtered.sort((a, b) {
          final aEvent = a as Event;
          final bEvent = b as Event;
          final aPot = (_gamesBuyIns[aEvent.id] ?? []).fold<double>(0, (sum, bi) => sum + (bi as Expense).amount);
          final bPot = (_gamesBuyIns[bEvent.id] ?? []).fold<double>(0, (sum, bi) => sum + (bi as Expense).amount);
          return bPot.compareTo(aPot);
        });
        break;
      case SortOption.duration:
        filtered.sort((a, b) {
          final aEvent = a as Event;
          final bEvent = b as Event;
          final aDuration = aEvent.endTime!.difference(aEvent.startTime);
          final bDuration = bEvent.endTime!.difference(bEvent.startTime);
          return bDuration.compareTo(aDuration);
        });
        break;
      case SortOption.playerCount:
        filtered.sort((a, b) {
          final aEvent = a as Event;
          final bEvent = b as Event;
          return bEvent.playerIds.length.compareTo(aEvent.playerIds.length);
        });
        break;
    }

    setState(() {
      _filteredGames = filtered;
    });
  }

  Future<void> _showFilterDialog() async {
    final result = await showDialog<HistoryFilters>(
      context: context,
      builder: (context) => HistoryFilterDialog(currentFilters: _filters),
    );

    if (result != null) {
      setState(() {
        _filters = result;
      });
      _applyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);

    // Show sign-in prompt for guest users
    if (authService.isGuestMode) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('History'),
          backgroundColor: AppTheme.primaryColor,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 24),
                Text(
                  'Sign In to View History',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Track your game history, player statistics, and leaderboards by signing in with your Google account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () async {
                    // Sign out guest user first, then go to auth
                    await ref.read(authServiceProvider).signOut();
                    if (mounted) {
                      context.go('/auth');
                    }
                  },
                  icon: const Icon(Icons.login, color: Colors.white),
                  label: const Text('Sign In'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Authenticated user view
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterDialog,
                tooltip: 'Filter',
              ),
              if (_filters.isActive)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_filters.activeFilterCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          tabs: const [
            Tab(text: 'Games', icon: Icon(Icons.history, size: 20)),
            Tab(text: 'Leaderboard', icon: Icon(Icons.leaderboard, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Games Tab
          _buildGamesTab(),
          
          // Leaderboard Tab
          LeaderboardTab(
            games: _endedGames,
            gamesBuyIns: _gamesBuyIns,
            gamesCashOuts: _gamesCashOuts,
          ),
        ],
      ),
    );
  }

  Widget _buildGamesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_endedGames.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                'No Game History Yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your completed games will appear here',
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

    if (_filteredGames.isEmpty && _filters.isActive) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.filter_list_off,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                'No Games Match Filters',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Try adjusting your filter criteria',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _showFilterDialog,
                icon: const Icon(Icons.filter_list),
                label: const Text('Adjust Filters'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredGames.length,
        itemBuilder: (context, index) {
          final game = _filteredGames[index];
          final buyIns = _gamesBuyIns[game.id] ?? [];
          final cashOuts = _gamesCashOuts[game.id] ?? [];

          return GameHistoryCard(
            game: game,
            buyIns: List<BuyIn>.from(buyIns),
            cashOuts: cashOuts,
            onTap: () {
              // Navigate to game details
              context.go('/game-details/${game.id}');
            },
          );
        },
      ),
    );
  }
}
