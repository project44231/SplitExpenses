import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/currency.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/compat.dart';
import '../../../services/event_share_service.dart';
import '../../../services/storage_service.dart';
import '../providers/game_provider.dart';
import '../../players/providers/player_provider.dart';
import '../widgets/add_expense_dialog.dart';
import '../widgets/edit_expense_dialog.dart';
import '../widgets/expense_card.dart';
import '../../auth/providers/auth_provider.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  Event? _currentEvent;
  List<Expense> _expenses = [];
  bool _isLoading = true;
  Set<String> _expandedExpenseIds = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadEventData());
  }

  Future<void> _loadEventData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      await ref.read(gameProvider.notifier).loadGames();
      final event = await ref.read(gameProvider.notifier).getGame(widget.eventId);
      final expenses = await ref.read(gameProvider.notifier).getExpenses(widget.eventId);
      
      if (mounted) {
        setState(() {
          _currentEvent = event;
          _expenses = expenses..sort((a, b) => b.timestamp.compareTo(a.timestamp));
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading event: $e')),
        );
      }
    }
  }

  Future<void> _showAddExpenseDialog() async {
    if (_currentEvent == null) return;

    // Load all players
    await ref.read(playerProvider.notifier).loadPlayers();
    final playersAsync = ref.read(playerProvider);
    
    final allPlayers = playersAsync.when(
      data: (players) => players,
      loading: () => <Participant>[],
      error: (_, __) => <Participant>[],
    );

    if (!mounted) return;

    final currency = AppCurrencies.fromCode(_currentEvent!.currency);
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddExpenseDialog(
        participants: allPlayers,
        currency: currency,
        onAddParticipant: (name) async {
          final participant = await ref.read(playerProvider.notifier).addPlayer(name: name);
          if (participant != null) {
            await ref.read(playerProvider.notifier).loadPlayers();
          }
          return participant;
        },
      ),
    );

    if (result != null && mounted) {
      try {
        // Upload receipt if provided
        String? receiptUrl;
        if (result['receiptFile'] != null) {
          final authService = ref.read(authServiceProvider);
          final userId = authService.currentUserId ?? 'guest';
          final expenseId = const Uuid().v4();
          
          receiptUrl = await ref.read(storageServiceProvider).uploadReceiptImage(
            result['receiptFile'],
            userId,
            expenseId,
          );
        }
        
        await ref.read(gameProvider.notifier).addExpense(
          eventId: _currentEvent!.id,
          paidByParticipantId: result['paidByParticipantId'],
          amount: result['amount'],
          description: result['description'],
          category: result['category'],
          splitMethod: result['splitMethod'],
          splitDetails: result['splitDetails'],
          notes: result['notes'],
          receipt: receiptUrl,
        );
        
        await _loadEventData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense added successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding expense: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  Future<void> _showEditExpenseDialog(Expense expense) async {
    if (_currentEvent == null) return;

    // Load all players
    await ref.read(playerProvider.notifier).loadPlayers();
    final playersAsync = ref.read(playerProvider);
    
    final allPlayers = playersAsync.when(
      data: (players) => players,
      loading: () => <Participant>[],
      error: (_, __) => <Participant>[],
    );

    if (!mounted) return;

    final currency = AppCurrencies.fromCode(_currentEvent!.currency);
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => EditExpenseDialog(
        expense: expense,
        participants: allPlayers,
        currency: currency,
        onAddParticipant: (name) async {
          final participant = await ref.read(playerProvider.notifier).addPlayer(name: name);
          if (participant != null) {
            await ref.read(playerProvider.notifier).loadPlayers();
          }
          return participant;
        },
      ),
    );

    if (result != null && mounted) {
      try {
        // Handle receipt upload/deletion
        String? receiptUrl = expense.receipt;
        if (result['newReceiptFile'] != null) {
          // Delete old receipt if exists
          if (receiptUrl != null) {
            await ref.read(storageServiceProvider).deleteReceiptImage(receiptUrl);
          }
          // Upload new receipt
          final authService = ref.read(authServiceProvider);
          final userId = authService.currentUserId ?? 'guest';
          receiptUrl = await ref.read(storageServiceProvider).uploadReceiptImage(
            result['newReceiptFile'],
            userId,
            expense.id,
          );
        } else if (result['removeReceipt'] == true && receiptUrl != null) {
          await ref.read(storageServiceProvider).deleteReceiptImage(receiptUrl);
          receiptUrl = null;
        }
        
        // Update expense
        await ref.read(gameProvider.notifier).updateExpenseWithParams(
          expenseId: expense.id,
          paidByParticipantId: result['paidByParticipantId'],
          amount: result['amount'],
          description: result['description'],
          category: result['category'],
          splitMethod: result['splitMethod'],
          splitDetails: result['splitDetails'],
          notes: result['notes'],
          receipt: receiptUrl,
        );
        
        await _loadEventData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense updated successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating expense: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteExpense(Expense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text(
          'Are you sure you want to delete this expense?\n\n'
          '${expense.description}\n'
          'Amount: ${Formatters.formatCurrency(expense.amount, AppCurrencies.fromCode(_currentEvent!.currency))}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        // Delete receipt from storage if exists
        if (expense.receipt != null) {
          await ref.read(storageServiceProvider).deleteReceiptImage(expense.receipt!);
        }
        
        await ref.read(gameProvider.notifier).deleteBuyIn(expense.id);
        await _loadEventData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting expense: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  void _navigateToSettle() {
    context.go('/cash-out/${widget.eventId}');
  }

  Future<void> _shareEvent() async {
    if (_currentEvent == null) return;

    try {
      final shareService = EventShareService();
      
      // Generate share token if not exists
      String shareToken = _currentEvent!.shareToken ?? shareService.generateShareToken();
      
      // Update event with share token if needed
      if (_currentEvent!.shareToken == null) {
        final updatedEvent = _currentEvent!.copyWith(
          shareToken: shareToken,
          updatedAt: DateTime.now(),
        );
        await ref.read(gameProvider.notifier).updateGame(updatedEvent);
        setState(() {
          _currentEvent = updatedEvent;
        });
      }

      // Show share options dialog
      final shareUrl = shareService.buildShareUrl(_currentEvent!.id, shareToken);
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Share Event with Friends'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Friends can view live event details and expenses at:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SelectableText(
                    shareUrl,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '• Link stays active permanently\n'
                  '• Shows live expense updates\n'
                  '• Read-only access for viewers',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () async {
                  await shareService.copyShareUrl(
                    eventId: _currentEvent!.id,
                    shareToken: shareToken,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copied to clipboard')),
                    );
                  }
                },
                child: const Text('Copy Link'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await shareService.shareEvent(
                    event: _currentEvent!,
                    shareToken: shareToken,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Share'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing event: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentEvent == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Failed to load event')),
      );
    }

    final currency = AppCurrencies.fromCode(_currentEvent!.currency);
    final totalExpenses = _expenses.fold(0.0, (sum, e) => sum + e.amount);
    final playersAsync = ref.watch(playerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentEvent!.name ?? 'Event'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareEvent,
            tooltip: 'Share with Friends',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEventData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Event Summary Header
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.primaryColor,
            child: Column(
              children: [
                if (_currentEvent!.description != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _currentEvent!.description!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${_expenses.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Expenses',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          Formatters.formatCurrency(totalExpenses, currency),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Total',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Settle Button (if there are expenses)
          if (_expenses.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: _navigateToSettle,
                icon: const Icon(Icons.calculate, color: Colors.white),
                label: const Text('Settle Expenses', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),

          // Expenses List
          Expanded(
            child: _expenses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No expenses yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to add your first expense',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadEventData,
                    child: playersAsync.when(
                      data: (allPlayers) {
                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _expenses.length,
                          itemBuilder: (context, index) {
                            final expense = _expenses[index];
                            
                            return ExpenseCard(
                              expense: expense,
                              currency: currency,
                              allParticipants: allPlayers,
                              isExpanded: _expandedExpenseIds.contains(expense.id),
                              onToggleExpand: () {
                                setState(() {
                                  if (_expandedExpenseIds.contains(expense.id)) {
                                    _expandedExpenseIds.remove(expense.id);
                                  } else {
                                    _expandedExpenseIds.add(expense.id);
                                  }
                                });
                              },
                              onEdit: () => _showEditExpenseDialog(expense),
                              onDelete: () => _deleteExpense(expense),
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (_, __) => const Center(child: Text('Error loading participants')),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddExpenseDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}
