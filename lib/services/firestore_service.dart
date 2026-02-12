import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import '../models/participant.dart';
import '../models/expense.dart';
import '../models/settlement.dart';
import '../models/event_group.dart';
import '../models/feedback.dart';

/// Firestore service for cloud data persistence
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection names
  static const String _eventsCollection = 'events';
  static const String _participantsCollection = 'participants';
  static const String _expensesCollection = 'expenses';
  static const String _settlementsCollection = 'settlements';
  static const String _groupsCollection = 'event_groups';
  static const String _feedbackCollection = 'feedback';

  // ==================== Events ====================

  /// Save or update an event
  Future<void> saveEvent(Event event, String userId) async {
    await _firestore
        .collection(_eventsCollection)
        .doc(event.id)
        .set({
          ...event.toJson(),
          'userId': userId,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  /// Get a specific event
  Future<Event?> getEvent(String eventId) async {
    final doc = await _firestore
        .collection(_eventsCollection)
        .doc(eventId)
        .get();

    if (!doc.exists) return null;
    return Event.fromJson(_convertTimestamps(doc.data()!));
  }

  /// Get all events for a user
  Future<List<Event>> getEvents(String userId) async {
    final snapshot = await _firestore
        .collection(_eventsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('startTime', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Event.fromJson(_convertTimestamps(doc.data())))
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

  /// Get active events for a user
  Future<List<Event>> getActiveEvents(String userId) async {
    final snapshot = await _firestore
        .collection(_eventsCollection)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .orderBy('startTime', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Event.fromJson(_convertTimestamps(doc.data())))
        .toList();
  }

  /// Delete an event
  Future<void> deleteEvent(String eventId) async {
    await _firestore
        .collection(_eventsCollection)
        .doc(eventId)
        .delete();
  }

  /// Stream events for real-time updates
  Stream<List<Event>> streamEvents(String userId) {
    return _firestore
        .collection(_eventsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Event.fromJson(_convertTimestamps(doc.data())))
            .toList());
  }

  // ==================== Participants ====================

  /// Save or update a participant
  Future<void> saveParticipant(Participant participant, String userId) async {
    await _firestore
        .collection(_participantsCollection)
        .doc(participant.id)
        .set({
          ...participant.toJson(),
          'userId': userId,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  /// Get all participants for a user
  Future<List<Participant>> getParticipants(String userId) async {
    final snapshot = await _firestore
        .collection(_participantsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('name')
        .get();

    return snapshot.docs
        .map((doc) => Participant.fromJson(_convertTimestamps(doc.data())))
        .toList();
  }

  /// Delete a participant
  Future<void> deleteParticipant(String participantId) async {
    await _firestore
        .collection(_participantsCollection)
        .doc(participantId)
        .delete();
  }

  /// Stream participants for real-time updates
  Stream<List<Participant>> streamParticipants(String userId) {
    return _firestore
        .collection(_participantsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Participant.fromJson(_convertTimestamps(doc.data())))
            .toList());
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

  /// Get expenses for an event
  Future<List<Expense>> getExpenses(String eventId) async {
    final snapshot = await _firestore
        .collection(_expensesCollection)
        .where('eventId', isEqualTo: eventId)
        .orderBy('timestamp')
        .get();

    return snapshot.docs
        .map((doc) => Expense.fromJson(_convertTimestamps(doc.data())))
        .toList();
  }

  /// Delete an expense
  Future<void> deleteExpense(String expenseId) async {
    await _firestore
        .collection(_expensesCollection)
        .doc(expenseId)
        .delete();
  }

  /// Stream expenses for real-time updates
  Stream<List<Expense>> streamExpenses(String eventId) {
    return _firestore
        .collection(_expensesCollection)
        .where('eventId', isEqualTo: eventId)
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Expense.fromJson(_convertTimestamps(doc.data())))
            .toList());
  }

  // ==================== Settlements ====================

  /// Save a single settlement for an event
  Future<void> saveSettlement(Settlement settlement, String userId) async {
    await _firestore
        .collection(_settlementsCollection)
        .doc(settlement.id)
        .set({
          ...settlement.toJson(),
          'userId': userId,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  /// Save multiple settlements for an event (batch operation)
  Future<void> saveSettlements(List<Settlement> settlements, String eventId, String userId) async {
    final batch = _firestore.batch();
    
    for (final settlement in settlements) {
      final docRef = _firestore
          .collection(_settlementsCollection)
          .doc(settlement.id);
      
      batch.set(docRef, {
        ...settlement.toJson(),
        'eventId': eventId,
        'userId': userId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    
    await batch.commit();
  }

  /// Get settlements for an event
  Future<List<Settlement>> getSettlements(String eventId) async {
    final snapshot = await _firestore
        .collection(_settlementsCollection)
        .where('eventId', isEqualTo: eventId)
        .orderBy('generatedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Settlement.fromJson(_convertTimestamps(doc.data())))
        .toList();
  }

  /// Get the latest settlement for an event
  Future<Settlement?> getLatestSettlement(String eventId) async {
    final snapshot = await _firestore
        .collection(_settlementsCollection)
        .where('eventId', isEqualTo: eventId)
        .orderBy('generatedAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return Settlement.fromJson(_convertTimestamps(snapshot.docs.first.data()));
  }

  // ==================== Event Groups ====================

  /// Save or update an event group
  Future<void> saveEventGroup(EventGroup group, String userId) async {
    await _firestore
        .collection(_groupsCollection)
        .doc(group.id)
        .set({
          ...group.toJson(),
          'userId': userId,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  /// Get all event groups for a user
  Future<List<EventGroup>> getEventGroups(String userId) async {
    final snapshot = await _firestore
        .collection(_groupsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('name')
        .get();

    return snapshot.docs
        .map((doc) => EventGroup.fromJson(_convertTimestamps(doc.data())))
        .toList();
  }

  // ==================== Feedback ====================

  /// Submit feedback
  Future<void> submitFeedback(UserFeedback feedback, String userId) async {
    await _firestore
        .collection(_feedbackCollection)
        .doc(feedback.id)
        .set({
          ...feedback.toJson(),
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: false));
  }

  /// Get all feedback for a user
  Future<List<UserFeedback>> getFeedbackByUserId(String userId) async {
    final snapshot = await _firestore
        .collection(_feedbackCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => UserFeedback.fromJson(_convertTimestamps(doc.data())))
        .toList();
  }

  /// Stream feedback for a user (for future real-time updates)
  Stream<List<UserFeedback>> streamFeedback(String userId) {
    return _firestore
        .collection(_feedbackCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserFeedback.fromJson(_convertTimestamps(doc.data())))
            .toList());
  }

  // ==================== Batch Operations ====================

  /// Sync all event data (for initial load or recovery)
  Future<void> syncAllEventData(String eventId, String userId) async {
    // This will trigger all individual sync operations
    await Future.wait([
      getEvent(eventId),
      getExpenses(eventId),
      getSettlements(eventId),
    ]);
  }
}
