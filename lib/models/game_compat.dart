/// Backward compatibility layer - maps old Game model to new Event model
/// This file provides type aliases and helper functions for gradual migration

import 'event.dart';
import 'event_group.dart';

// Export Event as Game for backward compatibility
typedef Game = Event;
typedef GameGroup = EventGroup;
typedef GameStatus = EventStatus;

// Helper extension to add Game-specific methods if needed
extension GameCompat on Event {
  // Add any Game-specific compatibility methods here
}
