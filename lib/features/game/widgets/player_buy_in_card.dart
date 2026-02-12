import 'package:flutter/material.dart';
import '../../../core/constants/currency.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/compat.dart';


/// Card displaying player's expense information
class PlayerBuyInCard extends StatefulWidget {
  final Participant player;
  final double totalBuyIn;
  final int buyInCount;
  final List<Expense> buyIns;
  final Currency currency;
  final VoidCallback? onAddBuyIn;
  final Function(Expense)? onEditBuyIn;
  final Function(Expense)? onDeleteBuyIn;
  final VoidCallback? onEditPlayer;
  final VoidCallback? onDeletePlayer;

  const PlayerBuyInCard({
    super.key,
    required this.player,
    required this.totalBuyIn,
    required this.buyInCount,
    required this.buyIns,
    required this.currency,
    this.onAddBuyIn,
    this.onEditBuyIn,
    this.onDeleteBuyIn,
    this.onEditPlayer,
    this.onDeletePlayer,
  });

  @override
  State<PlayerBuyInCard> createState() => _PlayerBuyInCardState();
}

class _PlayerBuyInCardState extends State<PlayerBuyInCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: Text(
                widget.player.name[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              widget.player.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: widget.buyInCount > 1
                ? Text('${widget.buyInCount} buy-ins')
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Formatters.formatCurrency(widget.totalBuyIn, widget.currency),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    if (widget.totalBuyIn == 0)
                      Text(
                        'No expenses',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.add_circle, size: 28),
                  color: AppTheme.primaryColor,
                  onPressed: widget.onAddBuyIn,
                  tooltip: 'Add Buy-In',
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey.shade600, size: 20),
                  tooltip: 'Player Options',
                  onSelected: (value) {
                    if (value == 'edit') {
                      widget.onEditPlayer?.call();
                    } else if (value == 'delete') {
                      widget.onDeletePlayer?.call();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Edit Name'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      enabled: widget.totalBuyIn == 0,
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            size: 18,
                            color: widget.totalBuyIn == 0 ? AppTheme.errorColor : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Remove Player',
                            style: TextStyle(
                              color: widget.totalBuyIn == 0 ? AppTheme.errorColor : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            onTap: widget.buyIns.isNotEmpty
                ? () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  }
                : null,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isExpanded && widget.buyIns.isNotEmpty
                ? Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.primaryColor.withValues(alpha: 0.05),
                          AppTheme.primaryColor.withValues(alpha: 0.02),
                        ],
                      ),
                      border: Border(
                        top: BorderSide(
                          color: AppTheme.primaryColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.history,
                                size: 16,
                                color: AppTheme.primaryColor.withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Buy-in History',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor.withValues(alpha: 0.8),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${widget.buyIns.length} transaction${widget.buyIns.length == 1 ? '' : 's'}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.buyIns.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            indent: 64,
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          ),
                          itemBuilder: (context, index) {
                            final buyIn = widget.buyIns[index];
                            return ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.only(
                                left: 16,
                                right: 8,
                                top: 4,
                                bottom: 4,
                              ),
                              leading: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppTheme.primaryColor,
                                      AppTheme.primaryColor.withValues(alpha: 0.7),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                Formatters.formatCurrency(buyIn.amount, widget.currency),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              subtitle: Row(
                                children: [
                                  Text(
                                    Formatters.formatTime(buyIn.timestamp),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      Formatters.formatRelativeTime(buyIn.timestamp),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 18),
                                    color: AppTheme.primaryColor,
                                    onPressed: () => widget.onEditBuyIn?.call(buyIn),
                                    tooltip: 'Edit',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 18),
                                    color: AppTheme.errorColor,
                                    onPressed: () => widget.onDeleteBuyIn?.call(buyIn),
                                    tooltip: 'Delete',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
