class CashflowInputModel {
  final int? id;
  final double currentBalance;
  final DateTime nextPaydayDate;
  final double safetyBuffer;
  final DateTime? updatedAt;

  CashflowInputModel({
    this.id,
    required this.currentBalance,
    required this.nextPaydayDate,
    required this.safetyBuffer,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'current_balance': currentBalance,
      'next_payday_date': nextPaydayDate.toIso8601String().split('T')[0],
      'safety_buffer': safetyBuffer,
    };
  }

  factory CashflowInputModel.fromMap(Map<String, dynamic> map) {
    return CashflowInputModel(
      id: map['id'] as int?,
      currentBalance: (map['current_balance'] as num).toDouble(),
      nextPaydayDate: DateTime.parse(map['next_payday_date'] as String),
      safetyBuffer: (map['safety_buffer'] as num).toDouble(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }
}
