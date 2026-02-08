import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../players/providers/player_provider.dart';

enum DateFilter {
  all('All Time'),
  week('This Week'),
  month('This Month'),
  threeMonths('Last 3 Months'),
  custom('Custom Range');

  final String label;
  const DateFilter(this.label);
}

enum SortOption {
  dateNewest('Date (Newest First)'),
  dateOldest('Date (Oldest First)'),
  potSize('Pot Size'),
  duration('Duration'),
  playerCount('Player Count');

  final String label;
  const SortOption(this.label);
}

class HistoryFilters {
  final DateFilter dateFilter;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final String? selectedPlayerId;
  final SortOption sortOption;

  HistoryFilters({
    this.dateFilter = DateFilter.all,
    this.customStartDate,
    this.customEndDate,
    this.selectedPlayerId,
    this.sortOption = SortOption.dateNewest,
  });

  HistoryFilters copyWith({
    DateFilter? dateFilter,
    DateTime? customStartDate,
    DateTime? customEndDate,
    String? selectedPlayerId,
    bool clearPlayer = false,
    SortOption? sortOption,
  }) {
    return HistoryFilters(
      dateFilter: dateFilter ?? this.dateFilter,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
      selectedPlayerId: clearPlayer ? null : (selectedPlayerId ?? this.selectedPlayerId),
      sortOption: sortOption ?? this.sortOption,
    );
  }

  bool get isActive =>
      dateFilter != DateFilter.all ||
      selectedPlayerId != null ||
      sortOption != SortOption.dateNewest;

  int get activeFilterCount {
    int count = 0;
    if (dateFilter != DateFilter.all) count++;
    if (selectedPlayerId != null) count++;
    if (sortOption != SortOption.dateNewest) count++;
    return count;
  }
}

class HistoryFilterDialog extends ConsumerStatefulWidget {
  final HistoryFilters currentFilters;

  const HistoryFilterDialog({
    super.key,
    required this.currentFilters,
  });

  @override
  ConsumerState<HistoryFilterDialog> createState() =>
      _HistoryFilterDialogState();
}

class _HistoryFilterDialogState extends ConsumerState<HistoryFilterDialog> {
  late HistoryFilters _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.currentFilters;
  }

  @override
  Widget build(BuildContext context) {
    final playersAsync = ref.watch(playerProvider);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                    'Filter History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Range
                    _buildSectionTitle('Date Range'),
                    ...DateFilter.values.map((filter) {
                      return RadioListTile<DateFilter>(
                        title: Text(filter.label),
                        value: filter,
                        groupValue: _filters.dateFilter,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _filters = _filters.copyWith(dateFilter: value);
                            });
                            if (value == DateFilter.custom) {
                              _selectCustomDateRange();
                            }
                          }
                        },
                        activeColor: AppTheme.primaryColor,
                      );
                    }),

                    if (_filters.dateFilter == DateFilter.custom &&
                        _filters.customStartDate != null &&
                        _filters.customEndDate != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'From: ${_formatDate(_filters.customStartDate!)}\nTo: ${_formatDate(_filters.customEndDate!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Player Filter
                    _buildSectionTitle('Filter by Player'),
                    playersAsync.when(
                      data: (players) {
                        return Column(
                          children: [
                            ListTile(
                              title: const Text('All Players'),
                              leading: Radio<String?>(
                                value: null,
                                groupValue: _filters.selectedPlayerId,
                                onChanged: (value) {
                                  setState(() {
                                    _filters = _filters.copyWith(clearPlayer: true);
                                  });
                                },
                                activeColor: AppTheme.primaryColor,
                              ),
                            ),
                            ...players.map((player) {
                              return ListTile(
                                title: Text(player.name),
                                leading: Radio<String?>(
                                  value: player.id,
                                  groupValue: _filters.selectedPlayerId,
                                  onChanged: (value) {
                                    setState(() {
                                      _filters = _filters.copyWith(
                                        selectedPlayerId: value,
                                      );
                                    });
                                  },
                                  activeColor: AppTheme.primaryColor,
                                ),
                              );
                            }),
                          ],
                        );
                      },
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (_, __) => const SizedBox(),
                    ),

                    const SizedBox(height: 16),

                    // Sort Options
                    _buildSectionTitle('Sort By'),
                    ...SortOption.values.map((option) {
                      return RadioListTile<SortOption>(
                        title: Text(option.label),
                        value: option,
                        groupValue: _filters.sortOption,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _filters = _filters.copyWith(sortOption: value);
                            });
                          }
                        },
                        activeColor: AppTheme.primaryColor,
                      );
                    }),
                  ],
                ),
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
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _filters = HistoryFilters();
                        });
                      },
                      child: const Text('Clear All'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, _filters);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Apply'),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Future<void> _selectCustomDateRange() async {
    final now = DateTime.now();
    final startDate = await showDatePicker(
      context: context,
      initialDate: _filters.customStartDate ?? now.subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: now,
    );

    if (startDate != null && mounted) {
      final endDate = await showDatePicker(
        context: context,
        initialDate: _filters.customEndDate ?? now,
        firstDate: startDate,
        lastDate: now,
      );

      if (endDate != null && mounted) {
        setState(() {
          _filters = _filters.copyWith(
            customStartDate: startDate,
            customEndDate: endDate,
          );
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
