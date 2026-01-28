class Bill {
  final String id;
  final String claimId;
  final double amount;
  final DateTime date;
  final String? description;

  Bill({
    required this.id,
    required this.claimId,
    required this.amount,
    required this.date,
    this.description,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'] as String,
      claimId: json['claim_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'claim_id': claimId,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
    };
  }
}
