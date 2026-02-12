import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/currency.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/compat.dart';
import '../providers/game_provider.dart';
import '../../players/providers/player_provider.dart';

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
    _loadActiveGroups();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Expenses'),
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
        label: const Text('Create Group'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_work_outlined,
            size: 120,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            'No Active Group Expenses',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Create your first group expense to start\ntracking shared expenses with friends',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _createNewGroup,
            icon: const Icon(Icons.add),
            label: const Text('Create Group Expense'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
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
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _openGroupDetail(group),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.group_work,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name ?? 'Unnamed Group',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (group.description != null && group.description!.isNotEmpty)
                          Text(
                            group.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.grey[200]),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      Icons.people,
                      '$participantCount ${participantCount == 1 ? 'participant' : 'participants'}',
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoChip(
                      Icons.receipt_long,
                      '$expenseCount ${expenseCount == 1 ? 'expense' : 'expenses'}',
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Expenses:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      Formatters.formatCurrency(totalExpenses, currency),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Last updated: ${Formatters.formatRelativeTime(group.updatedAt ?? group.createdAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
