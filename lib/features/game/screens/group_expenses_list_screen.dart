import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/currency.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/compat.dart';
import '../providers/game_provider.dart';

class GroupExpensesListScreen extends ConsumerStatefulWidget {
  const GroupExpensesListScreen({super.key});

  @override
  ConsumerState<GroupExpensesListScreen> createState() => _GroupExpensesListScreenState();
}

class _GroupExpensesListScreenState extends ConsumerState<GroupExpensesListScreen> {
  bool _isLoading = true;
  List<Event> _activeGroups = [];
  Map<String, double> _groupTotals = {};
  Map<String, int> _groupExpenseCounts = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadActiveGroups());
  }

  Future<void> _loadActiveGroups() async {
    setState(() => _isLoading = true);
    
    try {
      await ref.read(gameProvider.notifier).loadGames();
      final activeEvents = ref.read(gameProvider.notifier).getActiveEvents();
      
      // Load totals for each group
      final totals = <String, double>{};
      final expenseCounts = <String, int>{};
      
      for (final event in activeEvents) {
        final expenses = await ref.read(gameProvider.notifier).getExpenses(event.id);
        totals[event.id] = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
        expenseCounts[event.id] = expenses.length;
      }
      
      setState(() {
        _activeGroups = activeEvents;
        _groupTotals = totals;
        _groupExpenseCounts = expenseCounts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading groups: $e')),
        );
      }
    }
  }

  void _createNewGroup() {
    context.push(AppConstants.createGroupExpenseRoute);
  }

  void _openGroupDetail(Event group) {
    context.push('${AppConstants.groupExpenseDetailRoute}/${group.id}');
  }

  Future<void> _archiveEvent(Event event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Event?'),
        content: Text(
          'Are you sure you want to archive "${event.name ?? 'this event'}"?\n\n'
          'It will be moved to history and marked as settled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Archive'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(gameProvider.notifier).endGame(event.id);
        await _loadActiveGroups();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${event.name ?? "Event"} archived successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error archiving event: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'images/app_icon.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: const Text('Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadActiveGroups,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _activeGroups.isEmpty
              ? _buildEmptyState()
              : _buildGroupsList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewGroup,
        icon: const Icon(Icons.add),
        label: const Text('Create Group Event'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'images/app_icon.png',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to SplitExpenses!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[800],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Split bills and track shared expenses effortlessly',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildFeatureRow(Icons.event, 'Create events for trips, dinners, or group activities'),
                  const SizedBox(height: 12),
                  _buildFeatureRow(Icons.receipt, 'Add expenses and choose how to split them'),
                  const SizedBox(height: 12),
                  _buildFeatureRow(Icons.calculate, 'Auto-calculate who owes what'),
                  const SizedBox(height: 12),
                  _buildFeatureRow(Icons.share, 'Share with friends to track together'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Tap the button below to create your first event',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupsList() {
    return RefreshIndicator(
      onRefresh: _loadActiveGroups,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _activeGroups.length,
        itemBuilder: (context, index) {
          final group = _activeGroups[index];
          return _buildGroupCard(group);
        },
      ),
    );
  }

  Widget _buildGroupCard(Event group) {
    final currency = AppCurrencies.fromCode(group.currency);
    final totalExpenses = _groupTotals[group.id] ?? 0.0;
    final expenseCount = _groupExpenseCounts[group.id] ?? 0;
    final participantCount = group.participantIds.length;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openGroupDetail(group),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Left: Event Icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryColor.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Middle: Event Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        group.name ?? 'Unnamed Event',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$participantCount',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.receipt,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$expenseCount',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Right: Amount & Actions
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      Formatters.formatCurrency(totalExpenses, currency),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Archive button
                        InkWell(
                          onTap: () => _archiveEvent(group),
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.archive_outlined,
                              size: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
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
