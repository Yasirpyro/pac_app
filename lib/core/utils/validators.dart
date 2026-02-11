class Validators {
  static String? validatePayeeName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Payee name is required';
    }
    if (value.trim().length > 50) {
      return 'Payee name must be 50 characters or less';
    }
    return null;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Enter a valid number';
    }
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    if (amount > 9999.99) {
      return 'Amount must be \$9,999.99 or less';
    }
    return null;
  }

  static String? validateDueDate(DateTime? date) {
    if (date == null) {
      return 'Due date is required';
    }
    return null;
  }

  static String? validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Category is required';
    }
    const valid = ['Utilities', 'Insurance', 'Subscriptions', 'Other'];
    if (!valid.contains(value)) {
      return 'Invalid category';
    }
    return null;
  }

  static String? validateSafetyBuffer(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Safety buffer is required';
    }
    final buffer = double.tryParse(value);
    if (buffer == null) {
      return 'Enter a valid number';
    }
    if (buffer < 100 || buffer > 2000) {
      return 'Buffer must be between \$100 and \$2,000';
    }
    return null;
  }

  static String? validateDailyCap(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Daily cap is required';
    }
    final cap = double.tryParse(value);
    if (cap == null) {
      return 'Enter a valid number';
    }
    if (cap < 100 || cap > 10000) {
      return 'Cap must be between \$100 and \$10,000';
    }
    return null;
  }
}
