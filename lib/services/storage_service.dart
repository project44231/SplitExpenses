import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for StorageService
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// Service for managing Firebase Storage operations for receipts
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload receipt image to Firebase Storage
  /// Returns the download URL of the uploaded image
  Future<String?> uploadReceiptImage(
    File image,
    String userId,
    String expenseId,
  ) async {
    try {
      final fileName = '${expenseId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('expense_receipts/$userId/$fileName');
      
      // Upload the file
      await ref.putFile(
        image,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'expenseId': expenseId,
            'userId': userId,
          },
        ),
      );
      
      // Get and return the download URL
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      debugPrint('Error uploading receipt image: $e');
      return null;
    }
  }

  /// Delete receipt image from Firebase Storage
  /// Takes the full download URL and deletes the file
  Future<bool> deleteReceiptImage(String imageUrl) async {
    try {
      // Extract the storage path from the download URL
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting receipt image: $e');
      return false;
    }
  }

  /// Get download URL for a storage path (if needed for future use)
  Future<String?> getReceiptDownloadUrl(String storagePath) async {
    try {
      final ref = _storage.ref(storagePath);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      debugPrint('Error getting download URL: $e');
      return null;
    }
  }

  /// Delete all receipts for a specific user (cleanup utility)
  Future<void> deleteUserReceipts(String userId) async {
    try {
      final ref = _storage.ref().child('expense_receipts/$userId');
      final result = await ref.listAll();
      
      for (final item in result.items) {
        await item.delete();
      }
    } catch (e) {
      debugPrint('Error deleting user receipts: $e');
    }
  }
}
