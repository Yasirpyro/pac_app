class ReminderModel {
  final int? id;
  final int billId;
  final DateTime reminderDate;
  final DateTime createdAt;

  ReminderModel({
    this.id,
    required this.billId,
    required this.reminderDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bill_id': billId,
      'reminder_date': reminderDate.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'],
      billId: map['bill_id'],
      reminderDate: DateTime.parse(map['reminder_date']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
