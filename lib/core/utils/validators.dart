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

  /// Validate name (participant name, group name, etc.)
  static String? validateName(String? value, {int? maxLength}) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.trim().isEmpty) {
      return 'Name cannot be empty';
    }
    
    final length = maxLength ?? AppConstants.maxParticipantNameLength;
    if (value.length > length) {
      return 'Name must be less than $length characters';
    }
    
    return null;
  }

  /// Validate expense amount
  static String? validateExpenseAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    
    final amount = double.tryParse(value);
    
    if (amount == null) {
      return 'Please enter a valid number';
    }
    
    if (amount < AppConstants.minExpenseAmount) {
      return 'Amount must be at least ${AppConstants.minExpenseAmount}';
    }
    
    if (amount > AppConstants.maxExpenseAmount) {
      return 'Amount cannot exceed ${AppConstants.maxExpenseAmount}';
    }
    
    return null;
  }

  /// Validate description
  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Description is required';
    }
    
    if (value.trim().isEmpty) {
      return 'Description cannot be empty';
    }
    
    if (value.length > AppConstants.maxDescriptionLength) {
      return 'Description must be less than ${AppConstants.maxDescriptionLength} characters';
    }
    
    return null;
  }

  /// Validate cash-out amount (for backward compatibility)
  static String? validateCashOutAmount(String? value) {
    return validateExpenseAmount(value);
  }

  /// Validate buy-in amount (for backward compatibility)
  static String? validateBuyInAmount(String? value) {
    return validateExpenseAmount(value);
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
