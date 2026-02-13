import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/settlement.dart';
import '../models/compat.dart';
import '../core/constants/currency.dart';

class SettlementShareService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Generate a unique shareable ID for settlement
  String _generateShareId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           DateTime.now().microsecond.toString();
  }
  
  /// Save settlement data for web sharing and return shareable link
  Future<String> createShareableLink({
    required String eventName,
    required DateTime eventDate,
    required List<ParticipantResult> participantResults,
    required List<SettlementTransaction> transactions,
    required Map<String, String> participantNames,
    required Currency currency,
  }) async {
    try {
      final shareId = _generateShareId();
      
      // Prepare settlement data
      final settlementData = {
        'shareId': shareId,
        'eventName': eventName,
        'eventDate': eventDate.toIso8601String(),
        'currency': {
          'code': currency.code,
          'symbol': currency.symbol,
          'name': currency.name,
        },
        'participantResults': participantResults.map((pr) => {
          'participantId': pr.participantId,
          'name': participantNames[pr.participantId] ?? 'Unknown',
          'totalPaid': pr.totalPaid,
          'totalOwed': pr.totalOwed,
          'balance': pr.totalPaid - pr.totalOwed,
          'expenseCount': pr.expenseCount,
        }).toList(),
        'transactions': transactions.map((t) => {
          'from': participantNames[t.fromParticipantId] ?? 'Unknown',
          'to': participantNames[t.toParticipantId] ?? 'Unknown',
          'amount': t.amount,
        }).toList(),
        'createdAt': FieldValue.serverTimestamp(),
        'accessCount': 0,
      };
      
      // Save to Firestore
      await _firestore
          .collection('shared_settlements')
          .doc(shareId)
          .set(settlementData);
      
      // Generate shareable URL
      const baseUrl = 'https://splitexpenses-4c618.web.app';
      final shareUrl = '$baseUrl/settlement/$shareId';
      
      debugPrint('Created shareable settlement link: $shareUrl');
      
      return shareUrl;
    } catch (e) {
      debugPrint('Error creating shareable link: $e');
      rethrow;
    }
  }
  
  /// Increment access counter when settlement is viewed
  Future<void> incrementAccessCount(String shareId) async {
    try {
      await _firestore
          .collection('shared_settlements')
          .doc(shareId)
          .update({
        'accessCount': FieldValue.increment(1),
        'lastAccessedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error incrementing access count: $e');
    }
  }
  
  /// Get settlement data by share ID (for web view)
  Future<Map<String, dynamic>?> getSharedSettlement(String shareId) async {
    try {
      final doc = await _firestore
          .collection('shared_settlements')
          .doc(shareId)
          .get();
      
      if (doc.exists) {
        await incrementAccessCount(shareId);
        return doc.data();
      }
      return null;
    } catch (e) {
      debugPrint('Error getting shared settlement: $e');
      return null;
    }
  }
  
  /// Delete a shared settlement
  Future<void> deleteSharedSettlement(String shareId) async {
    try {
      await _firestore
          .collection('shared_settlements')
          .doc(shareId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting shared settlement: $e');
      rethrow;
    }
  }
}
