class Validators {
  static String? validateVpa(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'UPI ID is required';
    }
    if (!value.contains('@')) {
      return 'Invalid UPI ID format (must contain @)';
    }
    return null;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    // Remove formatting like commas
    final cleanValue = value.replaceAll(',', '');
    final amount = double.tryParse(cleanValue);

    if (amount == null) {
      return 'Invalid amount';
    }
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    if (amount > 100000) {
      return 'Maximum payment limit is ₹1,00,000';
    }
    return null;
  }

  static String? validatePin(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN is required';
    }
    if (value.length != 4) {
      return 'PIN must be exactly 4 digits';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'PIN must contain only numbers';
    }
    return null;
  }

  static String? validateCustomerId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Customer ID is required';
    }
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value.trim())) {
      return 'Customer ID must be alphanumeric';
    }
    return null;
  }
}
