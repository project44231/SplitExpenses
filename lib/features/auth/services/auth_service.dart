import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../models/app_user.dart';
import '../../../services/local_storage_service.dart';
import '../../../core/constants/app_constants.dart';

/// Authentication service handling both guest and Firebase auth
class AuthService {
  final firebase_auth.FirebaseAuth? _firebaseAuth;
  final LocalStorageService _localStorage;

  AuthService({
    firebase_auth.FirebaseAuth? firebaseAuth,
    required LocalStorageService localStorage,
  })  : _firebaseAuth = firebaseAuth,
        _localStorage = localStorage;

  /// Check if user is in guest mode
  bool get isGuestMode {
    return _localStorage.getBool(AppConstants.isGuestModeKey) ?? false;
  }

  /// Get current user (guest or authenticated)
  AppUser? getCurrentUser() {
    if (isGuestMode) {
      return AppUser.guest();
    }

    final firebaseUser = _firebaseAuth?.currentUser;
    if (firebaseUser == null) return null;

    return AppUser(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      isGuest: false,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }

  /// Sign in as guest
  Future<AppUser> signInAsGuest() async {
    await _localStorage.setBool(AppConstants.isGuestModeKey, true);
    return AppUser.guest();
  }

  /// Sign out
  Future<void> signOut() async {
    if (isGuestMode) {
      // Clear guest mode flag
      await _localStorage.remove(AppConstants.isGuestModeKey);
    } else {
      // Sign out from Firebase
      await _firebaseAuth?.signOut();
    }
  }

  /// Convert guest data to authenticated account
  /// (For future implementation when user upgrades from guest to authenticated)
  Future<void> migrateGuestDataToAuthenticated(String userId) async {
    // TODO: Implement migration logic
    // This would:
    // 1. Get all local data
    // 2. Upload to Firestore with user's ID
    // 3. Clear guest mode flag
    // 4. Keep local data as cache
    
    await _localStorage.remove(AppConstants.isGuestModeKey);
  }

  /// Sign in with email and password
  Future<AppUser?> signInWithEmail(String email, String password) async {
    if (_firebaseAuth == null) {
      throw Exception('Firebase not initialized');
    }

    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user == null) return null;

    return AppUser(
      id: credential.user!.uid,
      email: credential.user!.email ?? '',
      displayName: credential.user!.displayName,
      photoUrl: credential.user!.photoURL,
      isGuest: false,
      createdAt: credential.user!.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }

  /// Register with email and password
  Future<AppUser?> registerWithEmail(String email, String password) async {
    if (_firebaseAuth == null) {
      throw Exception('Firebase not initialized');
    }

    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user == null) return null;

    return AppUser(
      id: credential.user!.uid,
      email: credential.user!.email ?? '',
      displayName: credential.user!.displayName,
      photoUrl: credential.user!.photoURL,
      isGuest: false,
      createdAt: credential.user!.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }

  /// Sign in with Google
  /// TODO: Implement when Google Sign In is set up
  Future<AppUser?> signInWithGoogle() async {
    throw UnimplementedError('Google Sign In not implemented yet');
  }

  /// Sign in with Apple
  /// TODO: Implement when Apple Sign In is set up
  Future<AppUser?> signInWithApple() async {
    throw UnimplementedError('Apple Sign In not implemented yet');
  }

  /// Check if user is authenticated (either guest or Firebase)
  bool isAuthenticated() {
    return isGuestMode || _firebaseAuth?.currentUser != null;
  }

  /// Stream of auth state changes
  Stream<AppUser?> authStateChanges() async* {
    if (_firebaseAuth == null) {
      // No Firebase, check guest mode
      if (isGuestMode) {
        yield AppUser.guest();
      }
      return;
    }

    // Listen to Firebase auth changes
    await for (final firebaseUser in _firebaseAuth.authStateChanges()) {
      if (firebaseUser != null) {
        yield AppUser(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName,
          photoUrl: firebaseUser.photoURL,
          isGuest: false,
          createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
      } else if (isGuestMode) {
        yield AppUser.guest();
      } else {
        yield null;
      }
    }
  }
}
