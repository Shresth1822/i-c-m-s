class Advance {
  final String id;
  final String claimId;
  final double amount;
  final DateTime date;
  final String? reason;

  Advance({
    required this.id,
    required this.claimId,
    required this.amount,
    required this.date,
    this.reason,
  });

  factory Advance.fromJson(Map<String, dynamic> json) {
    return Advance(
      id: json['id'] as String,
      claimId: json['claim_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      reason: json['reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'claim_id': claimId,
      'amount': amount,
      'date': date.toIso8601String(),
      'reason': reason,
    };
  }
}
