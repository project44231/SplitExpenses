import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
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

  /// Get current user ID (returns unique guest ID for guest mode, Firebase UID for authenticated users)
  String? get currentUserId {
    if (isGuestMode) {
      return _localStorage.getString('guestUserId') ?? 'guest';
    }
    return _firebaseAuth?.currentUser?.uid;
  }

  /// Get current user (guest or authenticated)
  AppUser? getCurrentUser() {
    if (isGuestMode) {
      final guestId = _localStorage.getString('guestUserId') ?? 'guest';
      return AppUser.guest(guestId);
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
    
    // Generate or retrieve unique guest ID
    String? guestId = _localStorage.getString('guestUserId');
    if (guestId == null) {
      // Generate new unique guest ID
      final uuid = DateTime.now().millisecondsSinceEpoch.toString();
      guestId = 'guest_$uuid';
      await _localStorage.setString('guestUserId', guestId);
    }
    
    return AppUser.guest(guestId);
  }

  /// Sign out
  Future<void> signOut() async {
    if (isGuestMode) {
      // Clear guest mode flag (but keep guestUserId for re-login)
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
  Future<AppUser?> signInWithGoogle() async {
    if (_firebaseAuth == null) {
      throw Exception('Firebase not initialized');
    }

    try {
      // Trigger the Google authentication flow
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      // Sign out first to ensure account picker shows up
      await googleSignIn.signOut();

      // Initiate Google Sign In
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // If user cancels the sign-in
      if (googleUser == null) {
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) return null;

      // Clear guest mode flag if it was set
      await _localStorage.remove(AppConstants.isGuestModeKey);

      // Return AppUser
      return AppUser(
        id: userCredential.user!.uid,
        email: userCredential.user!.email ?? '',
        displayName: userCredential.user!.displayName,
        photoUrl: userCredential.user!.photoURL,
        isGuest: false,
        createdAt: userCredential.user!.metadata.creationTime ?? DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw Exception('An account already exists with a different sign-in method.');
        case 'invalid-credential':
          throw Exception('Invalid credential. Please try again.');
        case 'operation-not-allowed':
          throw Exception('Google Sign-In is not enabled. Please contact support.');
        case 'user-disabled':
          throw Exception('This account has been disabled.');
        case 'user-not-found':
          throw Exception('No user found.');
        case 'wrong-password':
          throw Exception('Wrong password.');
        default:
          throw Exception('Authentication failed: ${e.message}');
      }
    } catch (e) {
      // Handle other errors
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  /// Sign in with Apple
  Future<AppUser?> signInWithApple() async {
    if (_firebaseAuth == null) {
      throw Exception('Firebase not initialized');
    }

    try {
      // Generate nonce for security
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // Request Apple ID credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Create OAuth credential for Firebase
      final oauthCredential = firebase_auth.OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // Sign in to Firebase with Apple credential
      final userCredential = await _firebaseAuth.signInWithCredential(oauthCredential);

      if (userCredential.user == null) return null;

      // Update display name if provided (Apple only provides this on first sign-in)
      if (appleCredential.givenName != null || appleCredential.familyName != null) {
        final displayName = '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim();
        if (displayName.isNotEmpty && userCredential.user!.displayName == null) {
          await userCredential.user!.updateDisplayName(displayName);
        }
      }

      // Clear guest mode flag if it was set
      await _localStorage.remove(AppConstants.isGuestModeKey);

      // Return AppUser
      return AppUser(
        id: userCredential.user!.uid,
        email: userCredential.user!.email ?? appleCredential.email ?? '',
        displayName: userCredential.user!.displayName,
        photoUrl: userCredential.user!.photoURL,
        isGuest: false,
        createdAt: userCredential.user!.metadata.creationTime ?? DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw Exception('An account already exists with a different sign-in method.');
        case 'invalid-credential':
          throw Exception('Invalid credential. Please try again.');
        case 'operation-not-allowed':
          throw Exception('Apple Sign-In is not enabled. Please contact support.');
        case 'user-disabled':
          throw Exception('This account has been disabled.');
        case 'user-not-found':
          throw Exception('No user found.');
        default:
          throw Exception('Authentication failed: ${e.message}');
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      // Handle Apple-specific errors
      switch (e.code) {
        case AuthorizationErrorCode.canceled:
          throw Exception('Sign in canceled');
        case AuthorizationErrorCode.failed:
          throw Exception('Sign in failed. Please try again.');
        case AuthorizationErrorCode.invalidResponse:
          throw Exception('Invalid response from Apple. Please try again.');
        case AuthorizationErrorCode.notHandled:
          throw Exception('Sign in not handled. Please try again.');
        case AuthorizationErrorCode.unknown:
          throw Exception('Unknown error occurred. Please try again.');
        default:
          throw Exception('Apple Sign-In failed: ${e.message}');
      }
    } catch (e) {
      // Handle other errors
      throw Exception('Failed to sign in with Apple: $e');
    }
  }

  /// Generate a cryptographically secure random nonce
  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Returns the sha256 hash of [input] in hex notation
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
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
        final guestId = _localStorage.getString('guestUserId') ?? 'guest';
        yield AppUser.guest(guestId);
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
        final guestId = _localStorage.getString('guestUserId') ?? 'guest';
        yield AppUser.guest(guestId);
      } else {
        yield null;
      }
    }
  }
}
