import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../models/buy_in.dart';
import '../models/cash_out.dart';
import '../models/settlement.dart';
import '../models/game_group.dart';
import '../models/expense.dart';
import '../models/cash_out_reconciliation.dart';

/// Firestore service for cloud data persistence
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection names
  static const String _gamesCollection = 'games';
  static const String _playersCollection = 'players';
  static const String _buyInsCollection = 'buy_ins';
  static const String _cashOutsCollection = 'cash_outs';
  static const String _settlementsCollection = 'settlements';
  static const String _groupsCollection = 'game_groups';
  static const String _expensesCollection = 'expenses';
  static const String _reconciliationsCollection = 'reconciliations';

  // ==================== Games ====================

  /// Save or update a game
  Future<void> saveGame(Game game, String userId) async {
    await _firestore
        .collection(_gamesCollection)
        .doc(game.id)
        .set({
          ...game.toJson(),
          'userId': userId,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  /// Get a specific game
  Future<Game?> getGame(String gameId) async {
    final doc = await _firestore
        .collection(_gamesCollection)
        .doc(gameId)
        .get();

    if (!doc.exists) return null;
    return Game.fromJson(_convertTimestamps(doc.data()!));
  }

  /// Get all games for a user
  Future<List<Game>> getGames(String userId) async {
    final snapshot = await _firestore
        .collection(_gamesCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('startTime', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Game.fromJson(_convertTimestamps(doc.data())))
        .toList();
  }

  /// Convert Firestore Timestamps to ISO8601 strings for JSON parsing
  Map<String, dynamic> _convertTimestamps(Map<String, dynamic> data) {
    final converted = <String, dynamic>{};
    data.forEach((key, value) {
      if (value is Timestamp) {
        converted[key] = value.toDate().toIso8601String();
      } else {
        converted[key] = value;
      }
    });
    return converted;
  }

  /// Get active games for a user
  Future<List<Game>> getActiveGames(String userId) async {
    final snapshot = await _firestore
        .collection(_gamesCollection)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .orderBy('startTime', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Game.fromJson(_convertTimestamps(doc.data())))
        .toList();
  }

  /// Delete a game
  Future<void> deleteGame(String gameId) async {
    await _firestore
        .collection(_gamesCollection)
        .doc(gameId)
        .delete();
  }

  /// Stream games for real-time updates
  Stream<List<Game>> streamGames(String userId) {
    return _firestore
        .collection(_gamesCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Game.fromJson(_convertTimestamps(doc.data())))
            .toList());
  }

  // ==================== Players ====================

  /// Save or update a player
  Future<void> savePlayer(Player player, String userId) async {
    await _firestore
        .collection(_playersCollection)
        .doc(player.id)
        .set({
          ...player.toJson(),
          'userId': userId,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  /// Get all players for a user
  Future<List<Player>> getPlayers(String userId) async {
    final snapshot = await _firestore
        .collection(_playersCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('name')
        .get();

    return snapshot.docs
        .map((doc) => Player.fromJson(_convertTimestamps(doc.data())))
        .toList();
  }

  /// Delete a player
  Future<void> deletePlayer(String playerId) async {
    await _firestore
        .collection(_playersCollection)
        .doc(playerId)
        .delete();
  }

  /// Stream players for real-time updates
  Stream<List<Player>> streamPlayers(String userId) {
    return _firestore
        .collection(_playersCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Player.fromJson(_convertTimestamps(doc.data())))
            .toList());
  }

  // ==================== Buy-Ins ====================

  /// Save or update a buy-in
  Future<void> saveBuyIn(BuyIn buyIn, String userId) async {
    await _firestore
        .collection(_buyInsCollection)
        .doc(buyIn.id)
        .set({
          ...buyIn.toJson(),
          'userId': userId,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  /// Get buy-ins for a game
  Future<List<BuyIn>> getBuyIns(String gameId) async {
    final snapshot = await _firestore
        .collection(_buyInsCollection)
        .where('gameId', isEqualTo: gameId)
        .orderBy('timestamp')
        .get();

    return snapshot.docs
        .map((doc) => BuyIn.fromJson(_convertTimestamps(doc.data())))
        .toList();
  }

  /// Delete a buy-in
  Future<void> deleteBuyIn(String buyInId) async {
    await _firestore
        .collection(_buyInsCollection)
        .doc(buyInId)
        .delete();
  }

  /// Stream buy-ins for real-time updates
  Stream<List<BuyIn>> streamBuyIns(String gameId) {
    return _firestore
        .collection(_buyInsCollection)
        .where('gameId', isEqualTo: gameId)
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BuyIn.fromJson(_convertTimestamps(doc.data())))
            .toList());
  }

  // ==================== Cash-Outs ====================

  /// Save or update a cash-out
  Future<void> saveCashOut(CashOut cashOut, String userId) async {
    await _firestore
        .collection(_cashOutsCollection)
        .doc(cashOut.id)
        .set({
          ...cashOut.toJson(),
          'userId': userId,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  /// Get cash-outs for a game
  Future<List<CashOut>> getCashOuts(String gameId) async {
    final snapshot = await _firestore
        .collection(_cashOutsCollection)
        .where('gameId', isEqualTo: gameId)
        .get();

    return snapshot.docs
        .map((doc) => CashOut.fromJson(_convertTimestamps(doc.data())))
        .toList();
  }

  /// Delete cash-outs for a game
  Future<void> deleteCashOutsByGame(String gameId) async {
    final snapshot = await _firestore
        .collection(_cashOutsCollection)
        .where('gameId', isEqualTo: gameId)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ==================== Settlements ====================

  /// Save settlements for a game
  Future<void> saveSettlements(List<Settlement> settlements, String gameId, String userId) async {
    final batch = _firestore.batch();
    
    for (final settlement in settlements) {
      final docRef = _firestore
          .collection(_settlementsCollection)
          .doc(settlement.id);
      
      batch.set(docRef, {
        ...settlement.toJson(),
        'gameId': gameId,
        'userId': userId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    
    await batch.commit();
  }

  /// Get settlements for a game
  Future<List<Settlement>> getSettlements(String gameId) async {
    final snapshot = await _firestore
        .collection(_settlementsCollection)
        .where('gameId', isEqualTo: gameId)
        .get();

    return snapshot.docs
        .map((doc) => Settlement.fromJson(_convertTimestamps(doc.data())))
        .toList();
  }

  // ==================== Game Groups ====================

  /// Save or update a game group
  Future<void> saveGameGroup(GameGroup group, String userId) async {
    await _firestore
        .collection(_groupsCollection)
        .doc(group.id)
        .set({
          ...group.toJson(),
          'userId': userId,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  /// Get all game groups for a user
  Future<List<GameGroup>> getGameGroups(String userId) async {
    final snapshot = await _firestore
        .collection(_groupsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('name')
        .get();

    return snapshot.docs
        .map((doc) => GameGroup.fromJson(_convertTimestamps(doc.data())))
        .toList();
  }

  // ==================== Expenses ====================

  /// Save or update an expense
  Future<void> saveExpense(Expense expense, String userId) async {
    await _firestore
        .collection(_expensesCollection)
        .doc(expense.id)
        .set({
          ...expense.toJson(),
          'userId': userId,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  /// Get expenses for a game
  Future<List<Expense>> getExpenses(String gameId) async {
    final snapshot = await _firestore
        .collection(_expensesCollection)
        .where('gameId', isEqualTo: gameId)
        .get();

    return snapshot.docs
        .map((doc) => Expense.fromJson(_convertTimestamps(doc.data())))
        .toList();
  }

  // ==================== Reconciliations ====================

  /// Save or update a cash-out reconciliation
  Future<void> saveReconciliation(
    CashOutReconciliation reconciliation,
    String userId,
  ) async {
    await _firestore
        .collection(_reconciliationsCollection)
        .doc(reconciliation.id)
        .set({
          ...reconciliation.toJson(),
          'userId': userId,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  /// Get reconciliation for a game
  Future<CashOutReconciliation?> getReconciliation(String gameId) async {
    final snapshot = await _firestore
        .collection(_reconciliationsCollection)
        .where('gameId', isEqualTo: gameId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return CashOutReconciliation.fromJson(_convertTimestamps(snapshot.docs.first.data()));
  }

  /// Get all reconciliations for a game
  Future<List<CashOutReconciliation>> getReconciliations(String gameId) async {
    final snapshot = await _firestore
        .collection(_reconciliationsCollection)
        .where('gameId', isEqualTo: gameId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => CashOutReconciliation.fromJson(_convertTimestamps(doc.data())))
        .toList();
  }

  // ==================== Batch Operations ====================

  /// Sync all game data (for initial load or recovery)
  Future<void> syncAllGameData(String gameId, String userId) async {
    // This will trigger all individual sync operations
    await Future.wait([
      getGame(gameId),
      getBuyIns(gameId),
      getCashOuts(gameId),
      getSettlements(gameId),
      getExpenses(gameId),
      getReconciliations(gameId),
    ]);
  }
}
