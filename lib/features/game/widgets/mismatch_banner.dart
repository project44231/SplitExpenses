import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/constants/currency.dart';
import '../../../services/cash_out_mismatch_handler.dart';

/// Banner widget showing cash-out mismatch status with appropriate styling
class MismatchBanner extends StatelessWidget {
  final MismatchSeverity severity;
  final double difference;
  final double totalBuyIn;
  final double totalCashOut;
  final Currency currency;
  final VoidCallback? onAddExpense;
  final VoidCallback? onAdjustCashOuts;
  final VoidCallback? onContinueAsIs;
  final VoidCallback? onGoBack;
  final VoidCallback? onAddBuyIns;
  final VoidCallback? onCalculateSettlement;

  const MismatchBanner({
    super.key,
    required this.severity,
    required this.difference,
    required this.totalBuyIn,
    required this.totalCashOut,
    required this.currency,
    this.onAddExpense,
    this.onAdjustCashOuts,
    this.onContinueAsIs,
    this.onGoBack,
    this.onAddBuyIns,
    this.onCalculateSettlement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        border: Border.all(color: _getBorderColor(), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and message
          Row(
            children: [
              Icon(
                _getIcon(),
                color: _getIconColor(),
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getMessage(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getTextColor(),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getExplanation(),
                      style: TextStyle(
            fontSize: 13,
            color: _getTextColor().withValues(alpha: 0.9),
          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Show detailed breakdown for non-perfect matches
          if (severity != MismatchSeverity.perfect) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    'Total Buy-In:',
                    Formatters.formatCurrency(totalBuyIn, currency),
                  ),
                  const SizedBox(height: 4),
                  _buildDetailRow(
                    'Total Cash-Out:',
                    Formatters.formatCurrency(totalCashOut, currency),
                  ),
                  const Divider(height: 16, color: Colors.black26),
                  _buildDetailRow(
                    'Difference:',
                    '${difference > 0 ? '+' : ''}${Formatters.formatCurrency(difference, currency)}',
                    bold: true,
                  ),
                ],
              ),
            ),
          ],
          
          // Action buttons
          const SizedBox(height: 16),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: _getTextColor().withValues(alpha: 0.8),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: _getTextColor(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    switch (severity) {
      case MismatchSeverity.perfect:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onCalculateSettlement,
            icon: const Icon(Icons.check_circle),
            label: const Text('Calculate Settlement'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        );
        
      case MismatchSeverity.acceptable:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onCalculateSettlement,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Continue to Settlement'),
          ),
        );
        
      case MismatchSeverity.warningShortage:
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onAddExpense,
                    icon: const Icon(Icons.receipt, size: 18),
                    label: const Text('Add Expense'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: _getBorderColor()),
                      foregroundColor: _getTextColor(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onAdjustCashOuts,
                    icon: const Icon(Icons.tune, size: 18),
                    label: const Text('Adjust'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: _getBorderColor()),
                      foregroundColor: _getTextColor(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onContinueAsIs,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Continue As-Is'),
              ),
            ),
          ],
        );
        
      case MismatchSeverity.criticalExcess:
        return Column(
          children: [
            // Adjust Cash-Outs first
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAdjustCashOuts,
                icon: const Icon(Icons.tune, size: 18),
                label: const Text('Adjust Cash-Outs'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onAddBuyIns,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Buy-Ins'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: _getBorderColor()),
                      foregroundColor: _getTextColor(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onGoBack,
                    icon: const Icon(Icons.home, size: 18),
                    label: const Text('Go Home'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: _getBorderColor()),
                      foregroundColor: _getTextColor(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
    }
  }

  Color _getBackgroundColor() {
    switch (severity) {
      case MismatchSeverity.perfect:
        return Colors.green.shade50;
      case MismatchSeverity.acceptable:
        return Colors.blue.shade50;
      case MismatchSeverity.warningShortage:
        return Colors.orange.shade50;
      case MismatchSeverity.criticalExcess:
        return Colors.red.shade50;
    }
  }

  Color _getBorderColor() {
    switch (severity) {
      case MismatchSeverity.perfect:
        return Colors.green.shade600;
      case MismatchSeverity.acceptable:
        return Colors.blue.shade600;
      case MismatchSeverity.warningShortage:
        return Colors.orange.shade600;
      case MismatchSeverity.criticalExcess:
        return Colors.red.shade600;
    }
  }

  Color _getIconColor() {
    return _getBorderColor();
  }

  Color _getTextColor() {
    switch (severity) {
      case MismatchSeverity.perfect:
        return Colors.green.shade900;
      case MismatchSeverity.acceptable:
        return Colors.blue.shade900;
      case MismatchSeverity.warningShortage:
        return Colors.orange.shade900;
      case MismatchSeverity.criticalExcess:
        return Colors.red.shade900;
    }
  }

  IconData _getIcon() {
    switch (severity) {
      case MismatchSeverity.perfect:
        return Icons.check_circle;
      case MismatchSeverity.acceptable:
        return Icons.info;
      case MismatchSeverity.warningShortage:
        return Icons.warning;
      case MismatchSeverity.criticalExcess:
        return Icons.error;
    }
  }

  String _getMessage() {
    final handler = CashOutMismatchHandler();
    return handler.getMessage(severity, difference);
  }

  String _getExplanation() {
    final handler = CashOutMismatchHandler();
    return handler.getExplanation(severity);
  }
}
