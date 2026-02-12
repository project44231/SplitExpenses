/// Backward compatibility layer - maps old Player model to new Participant model
/// This file provides type aliases and helper functions for gradual migration

import 'participant.dart';

// Export Participant as Player for backward compatibility
typedef Player = Participant;

// Helper extension to add Player-specific methods if needed
extension PlayerCompat on Participant {
  // Add any Player-specific compatibility methods here
}
