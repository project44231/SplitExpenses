import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import '../../../models/feedback.dart';
import '../../../services/firestore_service.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../game/providers/game_provider.dart';

/// State for feedback submission
class FeedbackState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const FeedbackState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  FeedbackState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return FeedbackState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

/// Provider for managing feedback
final feedbackProvider = StateNotifierProvider<FeedbackNotifier, FeedbackState>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final authService = ref.watch(authServiceProvider);
  return FeedbackNotifier(firestoreService, authService);
});

/// Notifier for feedback state management
class FeedbackNotifier extends StateNotifier<FeedbackState> {
  final FirestoreService _firestoreService;
  final dynamic _authService;
  final _uuid = const Uuid();
  final _storage = FirebaseStorage.instance;

  FeedbackNotifier(this._firestoreService, this._authService) 
      : super(const FeedbackState());

  /// Get current user ID
  String get _userId => _authService.currentUserId ?? 'guest';

  /// Submit feedback with optional images
  Future<bool> submitFeedback({
    required String userName,
    required String userEmail,
    required FeedbackType type,
    required String message,
    required List<File> images,
    required bool includeDeviceInfo,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      // Upload images to Firebase Storage
      final imageUrls = <String>[];
      for (final image in images) {
        final url = await _uploadImage(image);
        if (url != null) {
          imageUrls.add(url);
        }
      }

      // Collect device info if requested
      String? deviceInfo;
      String? appVersion;
      
      if (includeDeviceInfo) {
        deviceInfo = await _collectDeviceInfo();
        appVersion = await _getAppVersion();
      }

      // Create feedback object
      final feedback = UserFeedback(
        id: _uuid.v4(),
        userId: _userId,
        userName: userName,
        userEmail: userEmail,
        type: type,
        message: message,
        imageUrls: imageUrls,
        deviceInfo: deviceInfo,
        appVersion: appVersion,
        createdAt: DateTime.now(),
      );

      // Submit to Firestore
      await _firestoreService.submitFeedback(feedback, _userId);

      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to submit feedback: ${e.toString()}',
      );
      return false;
    }
  }

  /// Upload image to Firebase Storage
  Future<String?> _uploadImage(File image) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_uuid.v4()}.jpg';
      final ref = _storage.ref().child('feedback_images/$_userId/$fileName');
      
      await ref.putFile(image);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      // Log error but don't fail the entire submission
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  /// Collect device information
  Future<String> _collectDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return 'Android ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt})\n'
               'Device: ${androidInfo.manufacturer} ${androidInfo.model}\n'
               'Brand: ${androidInfo.brand}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return 'iOS ${iosInfo.systemVersion}\n'
               'Device: ${iosInfo.name} (${iosInfo.model})\n'
               'System: ${iosInfo.systemName}';
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfo.macOsInfo;
        return 'macOS ${macInfo.osRelease}\n'
               'Computer: ${macInfo.computerName}\n'
               'Model: ${macInfo.model}';
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        return 'Windows ${windowsInfo.majorVersion}.${windowsInfo.minorVersion}\n'
               'Computer: ${windowsInfo.computerName}';
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        return 'Linux ${linuxInfo.name}\n'
               'Version: ${linuxInfo.version ?? "Unknown"}';
      } else {
        return 'Platform: ${Platform.operatingSystem}';
      }
    } catch (e) {
      return 'Unable to collect device info';
    }
  }

  /// Get app version
  Future<String> _getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return '${packageInfo.version} (${packageInfo.buildNumber})';
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Reset state
  void resetState() {
    state = const FeedbackState();
  }

  /// Get user's feedback history
  Future<List<UserFeedback>> getFeedbackHistory() async {
    try {
      return await _firestoreService.getFeedbackByUserId(_userId);
    } catch (e) {
      return [];
    }
  }
}
