import 'package:flutter/material.dart';

class GameDetailsScreen extends StatelessWidget {
  final String gameId;

  const GameDetailsScreen({super.key, required this.gameId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Details'),
      ),
      body: Center(
        child: Text('Game Details Screen - Game ID: $gameId\nComing Soon'),
      ),
    );
  }
}
