import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/constants/currency.dart';
import '../../../models/player.dart';
import '../../../services/cash_out_adjustment_service.dart';

/// Dialog for adjusting cash-outs with proportional or manual distribution
class AdjustmentDialog extends StatefulWidget {
  final List<Player> players;
  final Map<String, double> buyInTotals;
  final Map<String, double> currentCashOuts;
  final double amountToAdjust;
  final bool isShortage; // true = shortage (add), false = excess (reduce)
  final Currency currency;

  const AdjustmentDialog({
    super.key,
    required this.players,
    required this.buyInTotals,
    required this.currentCashOuts,
    required this.amountToAdjust,
    required this.isShortage,
    required this.currency,
  });

  @override
  State<AdjustmentDialog> createState() => _AdjustmentDialogState();
}

class _AdjustmentDialogState extends State<AdjustmentDialog> {
  AdjustmentMode _mode = AdjustmentMode.proportional;
  final Set<String> _selectedPlayerIds = {};
  Map<String, AdjustmentPreview>? _preview;

  @override
  void initState() {
    super.initState();
    _calculatePreview();
  }

  void _calculatePreview() {
    final service = CashOutAdjustmentService();
    Map<String, double> adjustments;

    switch (_mode) {
      case AdjustmentMode.proportional:
        if (widget.isShortage) {
          // Add to losers proportionally
          adjustments = service.distributeAmongLosers(
            players: widget.players,
            buyInTotals: widget.buyInTotals,
            currentCashOuts: widget.currentCashOuts,
            amountToDistribute: widget.amountToAdjust,
          );
        } else {
          // Reduce from winners proportionally
          adjustments = service.distributeAmongWinners(
            players: widget.players,
            buyInTotals: widget.buyInTotals,
            currentCashOuts: widget.currentCashOuts,
            amountToDistribute: -widget.amountToAdjust, // Negative to reduce
          );
        }
        break;

      case AdjustmentMode.manual:
        if (_selectedPlayerIds.isEmpty) {
          adjustments = {};
        } else {
          adjustments = service.distributeManually(
            selectedPlayerIds: _selectedPlayerIds.toList(),
            amountToDistribute: widget.isShortage 
                ? widget.amountToAdjust 
                : -widget.amountToAdjust,
          );
        }
        break;
    }

    setState(() {
      _preview = service.calculateAdjustmentPreview(
        players: widget.players,
        buyInTotals: widget.buyInTotals,
        currentCashOuts: widget.currentCashOuts,
        adjustments: adjustments,
      );
    });
  }

  void _apply() {
    if (_preview == null) return;

    // Extract adjustments that have changes
    final adjustments = <String, double>{};
    for (final entry in _preview!.entries) {
      if (entry.value.hasAdjustment) {
        adjustments[entry.key] = entry.value.adjustment;
      }
    }

    if (adjustments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No adjustments to apply')),
      );
      return;
    }

    Navigator.of(context).pop(adjustments);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.isShortage 
            ? 'Distribute Missing ${Formatters.formatCurrency(widget.amountToAdjust, widget.currency)}'
            : 'Reduce Extra ${Formatters.formatCurrency(widget.amountToAdjust, widget.currency)}',
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode selection
            SegmentedButton<AdjustmentMode>(
              segments: [
                ButtonSegment(
                  value: AdjustmentMode.proportional,
                  label: Text(
                    widget.isShortage ? 'By Losers' : 'By Winners',
                    style: const TextStyle(fontSize: 13),
                  ),
                  icon: const Icon(Icons.percent, size: 16),
                ),
                const ButtonSegment(
                  value: AdjustmentMode.manual,
                  label: Text('Manual', style: TextStyle(fontSize: 13)),
                  icon: Icon(Icons.touch_app, size: 16),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (Set<AdjustmentMode> newSelection) {
                setState(() {
                  _mode = newSelection.first;
                  _selectedPlayerIds.clear();
                  _calculatePreview();
                });
              },
            ),
            const SizedBox(height: 16),

            // Description
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getDescription(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Player selection for manual mode
            if (_mode == AdjustmentMode.manual) ...[
              const Text(
                'Select players to adjust:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: _buildPlayerSelection(),
              ),
              const SizedBox(height: 16),
            ],

            // Preview
            const Text(
              'Preview:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: _buildPreview(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _preview != null && _preview!.values.any((p) => p.hasAdjustment)
              ? _apply
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Apply'),
        ),
      ],
    );
  }

  String _getDescription() {
    if (_mode == AdjustmentMode.proportional) {
      if (widget.isShortage) {
        return 'Amount will be added to players who lost, proportional to their losses.';
      } else {
        return 'Amount will be reduced from players who won, proportional to their winnings.';
      }
    } else {
      return 'Select players and the amount will be distributed equally among them.';
    }
  }

  Widget _buildPlayerSelection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.players.length,
        itemBuilder: (context, index) {
          final player = widget.players[index];
          final isSelected = _selectedPlayerIds.contains(player.id);
          
          return CheckboxListTile(
            dense: true,
            value: isSelected,
            title: Text(player.name),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _selectedPlayerIds.add(player.id);
                } else {
                  _selectedPlayerIds.remove(player.id);
                }
                _calculatePreview();
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildPreview() {
    if (_preview == null || _preview!.isEmpty) {
      return const Center(
        child: Text('No preview available'),
      );
    }

    // Filter to only show players with adjustments
    final playersWithAdjustments = _preview!.values
        .where((p) => p.hasAdjustment)
        .toList();

    if (playersWithAdjustments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'Select players to see preview',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: playersWithAdjustments.length,
        itemBuilder: (context, index) {
          final preview = playersWithAdjustments[index];
          return _buildPreviewItem(preview);
        },
      ),
    );
  }

  Widget _buildPreviewItem(AdjustmentPreview preview) {
    final adjustmentSign = preview.adjustment >= 0 ? '+' : '';
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            preview.playerName,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current:',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              Text(
                Formatters.formatCurrency(preview.oldCashOut, widget.currency),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Adjustment:',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              Text(
                '$adjustmentSign${Formatters.formatCurrency(preview.adjustment, widget.currency)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: preview.adjustment >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const Divider(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'New Cash-Out:',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              Text(
                Formatters.formatCurrency(preview.newCashOut, widget.currency),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum AdjustmentMode {
  proportional,
  manual,
}
