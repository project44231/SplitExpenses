import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for cleaning up guest user data
/// Allows batch deletion of old guest event data
class GuestCleanupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static const String guestUserId = 'guest';

  /// Delete all guest data older than specified days
  Future<void> deleteOldGuestData({int olderThanDays = 30}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: olderThanDays));
    final cutoffTimestamp = Timestamp.fromDate(cutoffDate);

    try {
      // Clean up events
      await _deleteCollection(
        'events',
        where: [
          {'field': 'userId', 'isEqualTo': guestUserId},
          {'field': 'updatedAt', 'isLessThan': cutoffTimestamp},
        ],
      );

      // Clean up participants
      await _deleteCollection(
        'participants',
        where: [
          {'field': 'userId', 'isEqualTo': guestUserId},
          {'field': 'updatedAt', 'isLessThan': cutoffTimestamp},
        ],
      );

      // Clean up expenses
      await _deleteCollection(
        'expenses',
        where: [
          {'field': 'userId', 'isEqualTo': guestUserId},
          {'field': 'updatedAt', 'isLessThan': cutoffTimestamp},
        ],
      );

      // Clean up settlements
      await _deleteCollection(
        'settlements',
        where: [
          {'field': 'userId', 'isEqualTo': guestUserId},
          {'field': 'updatedAt', 'isLessThan': cutoffTimestamp},
        ],
      );

      // Clean up event groups
      await _deleteCollection(
        'event_groups',
        where: [
          {'field': 'userId', 'isEqualTo': guestUserId},
          {'field': 'updatedAt', 'isLessThan': cutoffTimestamp},
        ],
      );
    } catch (e) {
      throw Exception('Failed to clean up guest data: $e');
    }
  }

  /// Delete all guest data (regardless of age)
  Future<void> deleteAllGuestData() async {
    try {
      // Clean up all collections
      await _deleteCollection('events', where: [
        {'field': 'userId', 'isEqualTo': guestUserId},
      ]);
      await _deleteCollection('participants', where: [
        {'field': 'userId', 'isEqualTo': guestUserId},
      ]);
      await _deleteCollection('expenses', where: [
        {'field': 'userId', 'isEqualTo': guestUserId},
      ]);
      await _deleteCollection('settlements', where: [
        {'field': 'userId', 'isEqualTo': guestUserId},
      ]);
      await _deleteCollection('event_groups', where: [
        {'field': 'userId', 'isEqualTo': guestUserId},
      ]);
    } catch (e) {
      throw Exception('Failed to delete all guest data: $e');
    }
  }

  /// Get count of guest documents in a collection
  Future<int> getGuestDataCount(String collection) async {
    final snapshot = await _firestore
        .collection(collection)
        .where('userId', isEqualTo: guestUserId)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  /// Get total size estimate of guest data (in documents)
  Future<Map<String, int>> getGuestDataStats() async {
    return {
      'events': await getGuestDataCount('events'),
      'participants': await getGuestDataCount('participants'),
      'expenses': await getGuestDataCount('expenses'),
      'settlements': await getGuestDataCount('settlements'),
      'event_groups': await getGuestDataCount('event_groups'),
    };
  }

  /// Helper method to delete documents from a collection
  Future<void> _deleteCollection(
    String collectionName, {
    required List<Map<String, dynamic>> where,
  }) async {
    Query query = _firestore.collection(collectionName);

    // Apply all where clauses
    for (final condition in where) {
      if (condition.containsKey('isEqualTo')) {
        query = query.where(condition['field'], isEqualTo: condition['isEqualTo']);
      } else if (condition.containsKey('isLessThan')) {
        query = query.where(condition['field'], isLessThan: condition['isLessThan']);
      }
    }

    final snapshot = await query.get();
    
    if (snapshot.docs.isEmpty) return;

    // Delete in batches (Firestore batch limit is 500)
    final batches = <WriteBatch>[];
    var currentBatch = _firestore.batch();
    var operationCount = 0;

    for (final doc in snapshot.docs) {
      currentBatch.delete(doc.reference);
      operationCount++;

      if (operationCount == 500) {
        batches.add(currentBatch);
        currentBatch = _firestore.batch();
        operationCount = 0;
      }
    }

    // Add the last batch if it has operations
    if (operationCount > 0) {
      batches.add(currentBatch);
    }

    // Commit all batches
    for (final batch in batches) {
      await batch.commit();
    }
  }
}
