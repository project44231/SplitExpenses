import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../models/app_user.dart';
import '../../../services/local_storage_service.dart';
import '../services/auth_service.dart';

/// Provider for local storage service
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('LocalStorageService must be overridden in main.dart');
});

/// Provider for auth service
final authServiceProvider = Provider<AuthService>((ref) {
  final localStorage = ref.watch(localStorageServiceProvider);
  
  // Try to get Firebase Auth, but allow it to be null if not initialized
  firebase_auth.FirebaseAuth? firebaseAuth;
  try {
    firebaseAuth = firebase_auth.FirebaseAuth.instance;
  } catch (e) {
    // Firebase not initialized, that's okay for guest mode
    firebaseAuth = null;
  }

  return AuthService(
    firebaseAuth: firebaseAuth,
    localStorage: localStorage,
  );
});

/// Provider for current user
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges();
});

/// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.isAuthenticated();
});

/// Provider to check if in guest mode
final isGuestModeProvider = Provider<bool>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.isGuestMode;
});

/// Auth state notifier for managing auth actions
class AuthNotifier extends StateNotifier<AsyncValue<AppUser?>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.loading()) {
    _loadUser();
  }

  /// Load current user on initialization
  Future<void> _loadUser() async {
    try {
      final user = _authService.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Sign in as guest
  Future<void> signInAsGuest() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.signInAsGuest();
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _authService.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Sign in with email
  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.signInWithEmail(email, password);
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Register with email
  Future<void> registerWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.registerWithEmail(email, password);
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.signInWithGoogle();
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Sign in with Apple
  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.signInWithApple();
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

/// Provider for auth notifier
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AppUser?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
