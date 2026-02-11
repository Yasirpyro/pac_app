class BillModel {
  final int? id;
  final String payeeName;
  final double amount;
  final DateTime dueDate;
  final String category;
  final String status;
  final String? referenceId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BillModel({
    this.id,
    required this.payeeName,
    required this.amount,
    required this.dueDate,
    required this.category,
    this.status = 'Pending',
    this.referenceId,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'payee_name': payeeName,
      'amount': amount,
      'due_date': dueDate.toIso8601String().split('T')[0],
      'category': category,
      'status': status,
      'reference_id': referenceId,
    };
  }

  factory BillModel.fromMap(Map<String, dynamic> map) {
    return BillModel(
      id: map['id'] as int?,
      payeeName: map['payee_name'] as String,
      amount: (map['amount'] as num).toDouble(),
      dueDate: DateTime.parse(map['due_date'] as String),
      category: map['category'] as String,
      status: map['status'] as String? ?? 'Pending',
      referenceId: map['reference_id'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  BillModel copyWith({
    int? id,
    String? payeeName,
    double? amount,
    DateTime? dueDate,
    String? category,
    String? status,
    String? referenceId,
  }) {
    return BillModel(
      id: id ?? this.id,
      payeeName: payeeName ?? this.payeeName,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      status: status ?? this.status,
      referenceId: referenceId ?? this.referenceId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
