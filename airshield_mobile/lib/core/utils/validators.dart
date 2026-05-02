/// Input Validators
/// 
/// Reusable validation functions for forms

class Validators {
  // Email validation
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  // Phone number validation (basic international format)
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }
    
    // Remove spaces, dashes, parentheses
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Check if it's all digits and has reasonable length
    if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(cleaned)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  // Name validation
  static String? name(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    
    if (value.length > 50) {
      return '$fieldName must be less than 50 characters';
    }
    
    // Check for valid characters (letters, spaces, common punctuation)
    if (!RegExp(r"^[a-zA-Z\s\-'\.]+$").hasMatch(value)) {
      return '$fieldName contains invalid characters';
    }
    
    return null;
  }

  // Required field validation
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Number range validation
  static String? numberRange(
    String? value, {
    required double min,
    required double max,
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    if (number < min || number > max) {
      return '${fieldName ?? 'Value'} must be between $min and $max';
    }
    
    return null;
  }

  // Integer range validation
  static String? intRange(
    String? value, {
    required int min,
    required int max,
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final number = int.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    if (number < min || number > max) {
      return '${fieldName ?? 'Value'} must be between $min and $max';
    }
    
    return null;
  }

  // Min length validation
  static String? minLength(
    String? value,
    int minLength, {
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return null;
    }
    
    if (value.length < minLength) {
      return '${fieldName ?? 'This field'} must be at least $minLength characters';
    }
    
    return null;
  }

  // Max length validation
  static String? maxLength(
    String? value,
    int maxLength, {
    String? fieldName,
  }) {
    if (value == null) {
      return null;
    }
    
    if (value.length > maxLength) {
      return '${fieldName ?? 'This field'} must be less than $maxLength characters';
    }
    
    return null;
  }

  // Combine multiple validators
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) {
          return error;
        }
      }
      return null;
    };
  }

  // AQI threshold validation (0-500)
  static String? aqiThreshold(String? value) {
    return intRange(
      value,
      min: 0,
      max: 500,
      fieldName: 'AQI threshold',
    );
  }

  // Sensitivity level validation (1-5)
  static String? sensitivityLevel(double? value) {
    if (value == null) {
      return 'Sensitivity level is required';
    }
    
    if (value < 1 || value > 5) {
      return 'Sensitivity must be between 1 and 5';
    }
    
    return null;
  }
}
