import '../constants/app_constants.dart';

/// Input validation utilities
class Validators {
  /// Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    
    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }

  /// Validate name (player name, group name, etc.)
  static String? validateName(String? value, {int? maxLength}) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.trim().isEmpty) {
      return 'Name cannot be empty';
    }
    
    final length = maxLength ?? AppConstants.maxPlayerNameLength;
    if (value.length > length) {
      return 'Name must be less than $length characters';
    }
    
    return null;
  }

  /// Validate buy-in amount
  static String? validateBuyInAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    
    final amount = double.tryParse(value);
    
    if (amount == null) {
      return 'Please enter a valid number';
    }
    
    if (amount < AppConstants.minBuyInAmount) {
      return 'Amount must be at least ${AppConstants.minBuyInAmount}';
    }
    
    if (amount > AppConstants.maxBuyInAmount) {
      return 'Amount cannot exceed ${AppConstants.maxBuyInAmount}';
    }
    
    return null;
  }

  /// Validate cash-out amount
  static String? validateCashOutAmount(String? value) {
    return validateBuyInAmount(value);
  }

  /// Validate notes
  static String? validateNotes(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Notes are optional
    }
    
    if (value.length > AppConstants.maxNotesLength) {
      return 'Notes must be less than ${AppConstants.maxNotesLength} characters';
    }
    
    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate phone number (optional, basic validation)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }
    
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }
}
