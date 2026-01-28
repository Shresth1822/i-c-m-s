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

  // Computed Getters
  double get totalBillAmount => bills.fold(0, (sum, bill) => sum + bill.amount);
  double get totalAdvanceAmount =>
      advances.fold(0, (sum, adv) => sum + adv.amount);
  double get totalSettledAmount =>
      settlements.fold(0, (sum, set) => sum + set.amount);

  // Pending amount is total bills minus what has already been settled.
  // Advances are typically deducted from the final settlement, but for "pending"
  // we usually mean "how much more needs to be paid out".
  // If advances count as "already paid", then Pending = Bills - (Settlements + Advances).
  // Let's assume Pending = Bills - Settlements - Advances for now.
  double get pendingAmount =>
      totalBillAmount - totalAdvanceAmount - totalSettledAmount;

  Claim copyWith({
    String? id,
    String? policyNumber,
    String? patientName,
    String? patientEmail,
    ClaimStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Bill>? bills,
    List<Advance>? advances,
    List<Settlement>? settlements,
  }) {
    return Claim(
      id: id ?? this.id,
      policyNumber: policyNumber ?? this.policyNumber,
      patientName: patientName ?? this.patientName,
      patientEmail: patientEmail ?? this.patientEmail,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bills: bills ?? this.bills,
      advances: advances ?? this.advances,
      settlements: settlements ?? this.settlements,
    );
  }

  factory Claim.fromJson(Map<String, dynamic> json) {
    try {
      return Claim(
        id:
            json['id'] as String? ??
            '', // Handle potential null ID if generated client-side is expected but missing
        policyNumber: json['policy_number'] as String? ?? 'UNKNOWN',
        patientName: json['patient_name'] as String? ?? 'Unknown Patient',
        patientEmail: json['patient_email'] as String?,
        status: ClaimStatus.fromString(json['status'] as String? ?? 'draft'),
        createdAt:
            DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.now(),
        updatedAt:
            DateTime.tryParse(json['updated_at'] as String? ?? '') ??
            DateTime.now(),
        bills: _safeList<Bill>(json['bills'], (x) => Bill.fromJson(x)),
        advances: _safeList<Advance>(
          json['advances'],
          (x) => Advance.fromJson(x),
        ),
        settlements: _safeList<Settlement>(
          json['settlements'],
          (x) => Settlement.fromJson(x),
        ),
      );
    } catch (e, stack) {
      // Log the error to console for debugging if parsing fails
      // ignore: avoid_print
      print('Error inside Claim.fromJson: $e\n$stack');
      // ignore: avoid_print
      print('JSON content: $json');
      rethrow;
    }
  }

  static List<T> _safeList<T>(
    dynamic list,
    T Function(Map<String, dynamic>) mapper,
  ) {
    if (list is List) {
      return list
          .map((item) {
            if (item is Map<String, dynamic>) {
              return mapper(item);
            }
            // Handle case where item might be cast-able map
            if (item is Map) {
              return mapper(Map<String, dynamic>.from(item));
            }
            return null;
          })
          .whereType<T>()
          .toList();
    }
    return [];
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
