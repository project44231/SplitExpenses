/// Backward compatibility layer for transitioning from Game/Player/BuyIn to Event/Participant/Expense
/// Import this file instead of individual model files for backward compatibility
library compat;

import 'event.dart';
import 'participant.dart';
import 'expense.dart';
import 'event_group.dart';
import 'settlement.dart';

export 'event.dart';
export 'participant.dart';
export 'expense.dart';
export 'event_group.dart';
export 'settlement.dart';

// Type aliases
typedef Game = Event;
typedef Player = Participant;
typedef BuyIn = Expense;
typedef GameGroup = EventGroup;
typedef GameStatus = EventStatus;

// Extensions for backward compatibility
extension GameExtension on Event {
  List<String> get playerIds => participantIds;
  List<double> get customBuyInAmounts => [10, 20, 50, 100]; // Default amounts
}

extension BuyInExtension on Expense {
  String get playerId => paidByParticipantId;
  String get gameId => eventId;
}

extension PlayerExtension on Participant {
  // Add any Player-specific compatibility methods here if needed
}
