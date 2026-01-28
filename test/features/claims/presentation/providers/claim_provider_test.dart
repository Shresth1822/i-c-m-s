import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icms/features/claims/domain/entities/claim.dart';
import 'package:icms/features/claims/domain/entities/claim_status.dart';
import 'package:icms/features/claims/domain/entities/bill.dart';
import 'package:icms/features/claims/domain/entities/advance.dart';
import 'package:icms/features/claims/domain/entities/settlement.dart';
import 'package:icms/features/claims/domain/repositories/claim_repository.dart';
import 'package:icms/features/claims/presentation/providers/claim_provider.dart';
import 'package:icms/features/claims/presentation/providers/claim_repository_provider.dart';

class FakeClaimRepository implements ClaimRepository {
  final List<Claim> _claims = [];

  void seed(List<Claim> claims) {
    _claims.addAll(claims);
  }

  @override
  Future<Claim> createClaim(Claim claim) async {
    final newClaim = claim.copyWith(id: 'new-id');
    _claims.add(newClaim);
    return newClaim;
  }

  @override
  Future<void> deleteClaim(String id) async {
    _claims.removeWhere((c) => c.id == id);
  }

  @override
  Future<List<Claim>> getClaims() async {
    return _claims;
  }

  @override
  Future<Claim> updateClaim(Claim claim) async {
    final index = _claims.indexWhere((c) => c.id == claim.id);
    if (index != -1) {
      _claims[index] = claim;
      return claim;
    }
    throw Exception('Claim not found');
  }

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
  test('claimsProvider initial state is loading', () {
    final container = ProviderContainer(
      overrides: [
        claimRepositoryProvider.overrideWithValue(FakeClaimRepository()),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container.read(claimsProvider),
      const AsyncValue<List<Claim>>.loading(),
    );
  });

  test('claimsProvider fetches claims', () async {
    final repo = FakeClaimRepository();
    repo.seed([
      Claim(
        id: '1',
        policyNumber: 'P1',
        patientName: 'John',
        status: ClaimStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ]);

    final container = ProviderContainer(
      overrides: [claimRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    // Wait for the future to complete
    final claims = await container.read(claimsProvider.future);
    expect(claims.length, 1);
    expect(claims.first.patientName, 'John');
  });

  test('updateClaim modifies the state', () async {
    final repo = FakeClaimRepository();
    final initialClaim = Claim(
      id: '1',
      policyNumber: 'P1',
      patientName: 'John',
      status: ClaimStatus.draft,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    repo.seed([initialClaim]);

    final container = ProviderContainer(
      overrides: [claimRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    // Ensure initial load
    await container.read(claimsProvider.future);

    // Update
    final updatedClaim = initialClaim.copyWith(patientName: 'John Updated');
    await container.read(claimsProvider.notifier).updateClaim(updatedClaim);

    // Verify
    final claims = await container.read(claimsProvider.future);
    expect(claims.first.patientName, 'John Updated');
  });
}
