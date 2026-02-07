import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';

/// Widget that displays a live game timer
class GameTimer extends StatefulWidget {
  final DateTime startTime;

  const GameTimer({
    super.key,
    required this.startTime,
  });

  @override
  State<GameTimer> createState() => _GameTimerState();
}

class _GameTimerState extends State<GameTimer> {
  late Timer _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateElapsed();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _updateElapsed();
      }
    });
  }

  void _updateElapsed() {
    setState(() {
      _elapsed = DateTime.now().difference(widget.startTime);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.timer, size: 18),
        const SizedBox(width: 6),
        Text(
          Formatters.formatDuration(_elapsed),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
