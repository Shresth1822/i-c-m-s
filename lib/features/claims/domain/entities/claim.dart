import 'advance.dart';
import 'bill.dart';
import 'claim_status.dart';
import 'settlement.dart';

class Claim {
  final String id;
  final String policyNumber;
  final String patientName;
  final String? patientEmail;
  final ClaimStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Bill> bills;
  final List<Advance> advances;
  final List<Settlement> settlements;

  Claim({
    required this.id,
    required this.policyNumber,
    required this.patientName,
    this.patientEmail,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.bills = const [],
    this.advances = const [],
    this.settlements = const [],
  });

  double get totalBillAmount => bills.fold(0, (sum, item) => sum + item.amount);
  double get totalAdvanceAmount =>
      advances.fold(0, (sum, item) => sum + item.amount);
  double get totalSettledAmount =>
      settlements.fold(0, (sum, item) => sum + item.amount);

  // Pending amount is total bills minus what has already been settled.
  // Advances are typically deducted from the final settlement, but for "pending"
  // we usually mean "how much more needs to be paid out".
  // If advances count as "already paid", then Pending = Bills - (Settlements + Advances).
  // Let's assume Pending = Bills - Settlements - Advances for now.
  double get pendingAmount =>
      totalBillAmount - totalSettledAmount - totalAdvanceAmount;

  factory Claim.fromJson(Map<String, dynamic> json) {
    return Claim(
      id: json['id'] as String,
      policyNumber: json['policy_number'] as String,
      patientName: json['patient_name'] as String,
      patientEmail: json['patient_email'] as String?,
      status: ClaimStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      bills:
          (json['bills'] as List<dynamic>?)
              ?.map((e) => Bill.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      advances:
          (json['advances'] as List<dynamic>?)
              ?.map((e) => Advance.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      settlements:
          (json['settlements'] as List<dynamic>?)
              ?.map((e) => Settlement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'policy_number': policyNumber,
      'patient_name': patientName,
      'patient_email': patientEmail,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'bills': bills.map((e) => e.toJson()).toList(),
      'advances': advances.map((e) => e.toJson()).toList(),
      'settlements': settlements.map((e) => e.toJson()).toList(),
    };
  }
}
