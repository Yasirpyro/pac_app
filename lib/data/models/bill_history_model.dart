class BillHistoryModel {
  final int? id;
  final String payeeName;
  final double amount;
  final DateTime paymentDate;

  BillHistoryModel({
    this.id,
    required this.payeeName,
    required this.amount,
    required this.paymentDate,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'payee_name': payeeName,
      'amount': amount,
      'payment_date': paymentDate.toIso8601String().split('T')[0],
    };
  }

  factory BillHistoryModel.fromMap(Map<String, dynamic> map) {
    return BillHistoryModel(
      id: map['id'] as int?,
      payeeName: map['payee_name'] as String,
      amount: (map['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(map['payment_date'] as String),
    );
  }
}
