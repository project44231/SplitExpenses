import 'package:hive_flutter/hive_flutter.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../models/buy_in.dart';
import '../models/cash_out.dart';
import '../models/expense.dart';
import '../models/settlement.dart';
import '../models/game_group.dart';

/// Local storage service using Hive for guest mode
class LocalStorageService {
  static const String _gamesBoxName = 'games';
  static const String _playersBoxName = 'players';
  static const String _buyInsBoxName = 'buy_ins';
  static const String _cashOutsBoxName = 'cash_outs';
  static const String _expensesBoxName = 'expenses';
  static const String _settlementsBoxName = 'settlements';
  static const String _groupsBoxName = 'game_groups';
  static const String _prefsBoxName = 'preferences';

  // Boxes
  late Box<Map> _gamesBox;
  late Box<Map> _playersBox;
  late Box<Map> _buyInsBox;
  late Box<Map> _cashOutsBox;
  late Box<Map> _expensesBox;
  late Box<Map> _settlementsBox;
  late Box<Map> _groupsBox;
  late Box<dynamic> _prefsBox;

  /// Initialize Hive and open all boxes
  Future<void> initialize() async {
    await Hive.initFlutter();

    // Open boxes
    _gamesBox = await Hive.openBox<Map>(_gamesBoxName);
    _playersBox = await Hive.openBox<Map>(_playersBoxName);
    _buyInsBox = await Hive.openBox<Map>(_buyInsBoxName);
    _cashOutsBox = await Hive.openBox<Map>(_cashOutsBoxName);
    _expensesBox = await Hive.openBox<Map>(_expensesBoxName);
    _settlementsBox = await Hive.openBox<Map>(_settlementsBoxName);
    _groupsBox = await Hive.openBox<Map>(_groupsBoxName);
    _prefsBox = await Hive.openBox(_prefsBoxName);
  }

  // ==================== Games ====================

  Future<void> saveGame(Game game) async {
    await _gamesBox.put(game.id, game.toJson());
  }

  Future<Game?> getGame(String id) async {
    final json = _gamesBox.get(id);
    if (json == null) return null;
    return Game.fromJson(Map<String, dynamic>.from(json));
  }

  Future<List<Game>> getAllGames() async {
    final games = <Game>[];
    for (var json in _gamesBox.values) {
      games.add(Game.fromJson(Map<String, dynamic>.from(json)));
    }
    // Sort by start time, most recent first
    games.sort((a, b) => b.startTime.compareTo(a.startTime));
    return games;
  }

  Future<List<Game>> getGamesByGroup(String groupId) async {
    final allGames = await getAllGames();
    return allGames.where((game) => game.groupId == groupId).toList();
  }

  Future<void> deleteGame(String id) async {
    await _gamesBox.delete(id);
    // Also delete associated data
    await _deleteBuyInsByGame(id);
    await _deleteCashOutsByGame(id);
    await _deleteExpensesByGame(id);
    await _deleteSettlementsByGame(id);
  }

  // ==================== Players ====================

  Future<void> savePlayer(Player player) async {
    await _playersBox.put(player.id, player.toJson());
  }

  Future<Player?> getPlayer(String id) async {
    final json = _playersBox.get(id);
    if (json == null) return null;
    return Player.fromJson(Map<String, dynamic>.from(json));
  }

  Future<List<Player>> getAllPlayers() async {
    final players = <Player>[];
    for (var json in _playersBox.values) {
      players.add(Player.fromJson(Map<String, dynamic>.from(json)));
    }
    // Sort by name
    players.sort((a, b) => a.name.compareTo(b.name));
    return players;
  }

  Future<void> deletePlayer(String id) async {
    await _playersBox.delete(id);
  }

  // ==================== Buy-Ins ====================

  Future<void> saveBuyIn(BuyIn buyIn) async {
    await _buyInsBox.put(buyIn.id, buyIn.toJson());
  }

  Future<List<BuyIn>> getBuyInsByGame(String gameId) async {
    final buyIns = <BuyIn>[];
    for (var json in _buyInsBox.values) {
      final buyIn = BuyIn.fromJson(Map<String, dynamic>.from(json));
      if (buyIn.gameId == gameId) {
        buyIns.add(buyIn);
      }
    }
    // Sort by timestamp
    buyIns.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return buyIns;
  }

  Future<void> deleteBuyIn(String buyInId) async {
    await _buyInsBox.delete(buyInId);
  }

  Future<void> _deleteBuyInsByGame(String gameId) async {
    final keysToDelete = <String>[];
    for (var entry in _buyInsBox.toMap().entries) {
      final buyIn = BuyIn.fromJson(Map<String, dynamic>.from(entry.value));
      if (buyIn.gameId == gameId) {
        keysToDelete.add(entry.key);
      }
    }
    for (var key in keysToDelete) {
      await _buyInsBox.delete(key);
    }
  }

  // ==================== Cash-Outs ====================

  Future<void> saveCashOut(CashOut cashOut) async {
    await _cashOutsBox.put(cashOut.id, cashOut.toJson());
  }

  Future<List<CashOut>> getCashOutsByGame(String gameId) async {
    final cashOuts = <CashOut>[];
    for (var json in _cashOutsBox.values) {
      final cashOut = CashOut.fromJson(Map<String, dynamic>.from(json));
      if (cashOut.gameId == gameId) {
        cashOuts.add(cashOut);
      }
    }
    // Sort by timestamp
    cashOuts.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return cashOuts;
  }

  Future<void> _deleteCashOutsByGame(String gameId) async {
    final keysToDelete = <String>[];
    for (var entry in _cashOutsBox.toMap().entries) {
      final cashOut = CashOut.fromJson(Map<String, dynamic>.from(entry.value));
      if (cashOut.gameId == gameId) {
        keysToDelete.add(entry.key);
      }
    }
    for (var key in keysToDelete) {
      await _cashOutsBox.delete(key);
    }
  }

  // ==================== Expenses ====================

  Future<void> saveExpense(Expense expense) async {
    await _expensesBox.put(expense.id, expense.toJson());
  }

  Future<List<Expense>> getExpensesByGame(String gameId) async {
    final expenses = <Expense>[];
    for (var json in _expensesBox.values) {
      final expense = Expense.fromJson(Map<String, dynamic>.from(json));
      if (expense.gameId == gameId) {
        expenses.add(expense);
      }
    }
    return expenses;
  }

  Future<void> _deleteExpensesByGame(String gameId) async {
    final keysToDelete = <String>[];
    for (var entry in _expensesBox.toMap().entries) {
      final expense = Expense.fromJson(Map<String, dynamic>.from(entry.value));
      if (expense.gameId == gameId) {
        keysToDelete.add(entry.key);
      }
    }
    for (var key in keysToDelete) {
      await _expensesBox.delete(key);
    }
  }

  // ==================== Settlements ====================

  Future<void> saveSettlement(Settlement settlement) async {
    await _settlementsBox.put(settlement.id, settlement.toJson());
  }

  Future<Settlement?> getSettlementByGame(String gameId) async {
    for (var json in _settlementsBox.values) {
      final settlement = Settlement.fromJson(Map<String, dynamic>.from(json));
      if (settlement.gameId == gameId) {
        return settlement;
      }
    }
    return null;
  }

  Future<void> _deleteSettlementsByGame(String gameId) async {
    final keysToDelete = <String>[];
    for (var entry in _settlementsBox.toMap().entries) {
      final settlement =
          Settlement.fromJson(Map<String, dynamic>.from(entry.value));
      if (settlement.gameId == gameId) {
        keysToDelete.add(entry.key);
      }
    }
    for (var key in keysToDelete) {
      await _settlementsBox.delete(key);
    }
  }

  // ==================== Game Groups ====================

  Future<void> saveGameGroup(GameGroup group) async {
    await _groupsBox.put(group.id, group.toJson());
  }

  Future<GameGroup?> getGameGroup(String id) async {
    final json = _groupsBox.get(id);
    if (json == null) return null;
    return GameGroup.fromJson(Map<String, dynamic>.from(json));
  }

  Future<List<GameGroup>> getAllGameGroups() async {
    final groups = <GameGroup>[];
    for (var json in _groupsBox.values) {
      groups.add(GameGroup.fromJson(Map<String, dynamic>.from(json)));
    }
    // Sort by name
    groups.sort((a, b) => a.name.compareTo(b.name));
    return groups;
  }

  Future<void> deleteGameGroup(String id) async {
    await _groupsBox.delete(id);
  }

  // ==================== Preferences ====================

  Future<void> setString(String key, String value) async {
    await _prefsBox.put(key, value);
  }

  String? getString(String key) {
    return _prefsBox.get(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefsBox.put(key, value);
  }

  bool? getBool(String key) {
    return _prefsBox.get(key);
  }

  Future<void> remove(String key) async {
    await _prefsBox.delete(key);
  }

  // ==================== Utility ====================

  /// Clear all local data (for testing or logout)
  Future<void> clearAll() async {
    await _gamesBox.clear();
    await _playersBox.clear();
    await _buyInsBox.clear();
    await _cashOutsBox.clear();
    await _expensesBox.clear();
    await _settlementsBox.clear();
    await _groupsBox.clear();
    await _prefsBox.clear();
  }

  /// Get storage statistics
  Map<String, int> getStats() {
    return {
      'games': _gamesBox.length,
      'players': _playersBox.length,
      'buyIns': _buyInsBox.length,
      'cashOuts': _cashOutsBox.length,
      'expenses': _expensesBox.length,
      'settlements': _settlementsBox.length,
      'groups': _groupsBox.length,
    };
  }
}
