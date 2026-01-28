import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icms/features/claims/domain/entities/claim.dart';
import 'package:icms/features/claims/domain/entities/claim_status.dart';
import 'package:icms/features/claims/domain/repositories/claim_repository.dart';
import 'package:icms/features/claims/presentation/providers/claim_provider.dart';
import 'package:icms/features/claims/presentation/providers/claim_repository_provider.dart';

class FakeClaimRepository implements ClaimRepository {
  final List<Claim> _claims = [];

  @override
  Future<Claim> createClaim(Claim claim) async {
    final newClaim = Claim(
      id: 'new-id', // Simulate DB ID generation
      policyNumber: claim.policyNumber,
      patientName: claim.patientName,
      status: claim.status,
      createdAt: claim.createdAt,
      updatedAt: claim.updatedAt,
    );
    _claims.add(newClaim);
    return newClaim;
  }

  @override
  Future<void> deleteClaim(String id) async {
    _claims.removeWhere((c) => c.id == id);
  }

  @override
  Future<List<Claim>> getClaims() async {
    return List.from(_claims);
  }

  @override
  Future<Claim> updateClaim(Claim claim) async {
    final index = _claims.indexWhere((c) => c.id == claim.id);
    if (index != -1) {
      _claims[index] = claim;
    }
    return claim;
  }

  void seed(List<Claim> claims) {
    _claims.addAll(claims);
  }
}

void main() {
  late ProviderContainer container;
  late FakeClaimRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeClaimRepository();
    container = ProviderContainer(
      overrides: [claimRepositoryProvider.overrideWithValue(fakeRepository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('initial state is loading then empty list', () async {
    final subscription = container.listen(claimsProvider, (previous, next) {});
    addTearDown(subscription.close);

    // Expect loading first (AsyncValue.loading())
    expect(container.read(claimsProvider), isA<AsyncLoading>());

    // Wait for the future to complete
    await container.read(claimsProvider.future);

    expect(container.read(claimsProvider).value, isEmpty);
  });

  test('addClaim updates the list', () async {
    final subscription = container.listen(claimsProvider, (previous, next) {});
    addTearDown(subscription.close);

    await container.read(claimsProvider.future);

    final newClaim = Claim(
      id: '',
      policyNumber: '123',
      patientName: 'Test',
      status: ClaimStatus.draft,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await container.read(claimsProvider.notifier).addClaim(newClaim);

    final state = container.read(claimsProvider);
    expect(state.value, hasLength(1));
    expect(state.value!.first.id, 'new-id');
  });

  test('updateClaim modifies the list', () async {
    final subscription = container.listen(claimsProvider, (previous, next) {});
    addTearDown(subscription.close);

    await container.read(claimsProvider.future);

    // Seed with a claim
    final claim = Claim(
      id: '1',
      policyNumber: 'Old',
      patientName: 'Old',
      status: ClaimStatus.draft,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    fakeRepository.seed([claim]);

    // Refresh to get seeded data
    container.refresh(claimsProvider);
    await container.read(claimsProvider.future);

    final updatedClaim = claim.copyWith(policyNumber: 'New');
    await container.read(claimsProvider.notifier).updateClaim(updatedClaim);

    final state = container.read(claimsProvider);
    expect(state.value!.first.policyNumber, 'New');
  });
}
