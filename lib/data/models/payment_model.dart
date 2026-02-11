class PaymentModel {
  final int? id;
  final int billId;
  final String referenceId;
  final DateTime scheduledDate;
  final double amount;
  final String status;
  final DateTime? createdAt;

  PaymentModel({
    this.id,
    required this.billId,
    required this.referenceId,
    required this.scheduledDate,
    required this.amount,
    this.status = 'Scheduled',
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'bill_id': billId,
      'reference_id': referenceId,
      'scheduled_date': scheduledDate.toIso8601String().split('T')[0],
      'amount': amount,
      'status': status,
    };
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'] as int?,
      billId: map['bill_id'] as int,
      referenceId: map['reference_id'] as String,
      scheduledDate: DateTime.parse(map['scheduled_date'] as String),
      amount: (map['amount'] as num).toDouble(),
      status: map['status'] as String? ?? 'Scheduled',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }
}
