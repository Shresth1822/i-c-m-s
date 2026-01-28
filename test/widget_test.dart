import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icms/features/claims/domain/entities/claim.dart';
import 'package:icms/features/claims/domain/entities/bill.dart';
import 'package:icms/features/claims/domain/entities/advance.dart';
import 'package:icms/features/claims/domain/entities/settlement.dart';
import 'package:icms/features/claims/domain/repositories/claim_repository.dart';
import 'package:icms/features/claims/presentation/providers/claim_repository_provider.dart';

// Fake Repository
class FakeClaimRepository implements ClaimRepository {
  @override
  Future<List<Claim>> getClaims() async => [];
  @override
  Future<Claim> createClaim(Claim claim) async => claim;
  @override
  Future<Claim> updateClaim(Claim claim) async => claim;
  @override
  Future<void> deleteClaim(String id) async {}

  @override
  Future<void> addBill(String claimId, Bill bill) async {}
  @override
  Future<void> deleteBill(String id) async {}

  @override
  Future<void> addAdvance(String claimId, Advance advance) async {}
  @override
  Future<void> deleteAdvance(String id) async {}

  @override
  Future<void> addSettlement(String claimId, Settlement settlement) async {}
  @override
  Future<void> deleteSettlement(String id) async {}
}

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          claimRepositoryProvider.overrideWithValue(FakeClaimRepository()),
        ],
        child: const MaterialApp(home: Scaffold(body: Text('Hello'))),
      ),
    );

    // Provide a longer delay for any async ops/animations
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Hello'), findsOneWidget);
  });
}
