import 'package:flutter_test/flutter_test.dart';
import 'package:icms/features/claims/domain/entities/advance.dart';
import 'package:icms/features/claims/domain/entities/bill.dart';
import 'package:icms/features/claims/domain/entities/claim.dart';
import 'package:icms/features/claims/domain/entities/claim_status.dart';
import 'package:icms/features/claims/domain/entities/settlement.dart';

void main() {
  group('Claim Model', () {
    final testDate = DateTime(2023, 1, 1);

    final bill1 = Bill(id: 'b1', claimId: 'c1', amount: 1000, date: testDate);
    final bill2 = Bill(id: 'b2', claimId: 'c1', amount: 500, date: testDate);

    final advance1 = Advance(
      id: 'a1',
      claimId: 'c1',
      amount: 200,
      date: testDate,
    );

    final settlement1 = Settlement(
      id: 's1',
      claimId: 'c1',
      amount: 300,
      date: testDate,
    );

    test('should calculate totalBillAmount correctly', () {
      final claim = Claim(
        id: 'c1',
        policyNumber: 'P123',
        patientName: 'John Doe',
        status: ClaimStatus.draft,
        createdAt: testDate,
        updatedAt: testDate,
        bills: [bill1, bill2],
      );

      expect(claim.totalBillAmount, 1500);
    });

    test('should calculate pendingAmount correctly', () {
      // Pending = Bills (1500) - Settled (300) - Advances (200) = 1000
      final claim = Claim(
        id: 'c1',
        policyNumber: 'P123',
        patientName: 'John Doe',
        status: ClaimStatus.draft,
        createdAt: testDate,
        updatedAt: testDate,
        bills: [bill1, bill2],
        advances: [advance1],
        settlements: [settlement1],
      );

      expect(claim.totalBillAmount, 1500);
      expect(claim.totalAdvanceAmount, 200);
      expect(claim.totalSettledAmount, 300);
      expect(claim.pendingAmount, 1000);
    });

    test('should serialize and deserialize correctly', () {
      final claim = Claim(
        id: 'c1',
        policyNumber: 'P123',
        patientName: 'John Doe',
        status: ClaimStatus.submitted,
        createdAt: testDate,
        updatedAt: testDate,
        bills: [bill1],
      );

      final json = claim.toJson();
      expect(json['status'], 'submitted');
      expect(json['bills'], isNotEmpty);

      final fromJson = Claim.fromJson(json);
      expect(fromJson.id, claim.id);
      expect(fromJson.status, ClaimStatus.submitted);
      expect(fromJson.bills.first.amount, 1000);
    });
  });
}
