import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/claim.dart';
import '../../domain/entities/claim_status.dart';
import '../../domain/entities/bill.dart';
import '../../domain/entities/advance.dart';
import '../../domain/entities/settlement.dart';
import 'claim_repository_provider.dart';

part 'claim_provider.g.dart';

@riverpod
class Claims extends _$Claims {
  @override
  FutureOr<List<Claim>> build() async {
    final repository = ref.watch(claimRepositoryProvider);
    return repository.getClaims();
  }

  Future<void> addClaim(Claim claim) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(claimRepositoryProvider).createClaim(claim);
      return ref.refresh(claimsProvider.future);
    });
  }

  Future<void> deleteClaim(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(claimRepositoryProvider).deleteClaim(id);
      return ref.refresh(claimsProvider.future);
    });
  }

  Future<void> updateClaim(Claim claim) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(claimRepositoryProvider).updateClaim(claim);
      return ref.refresh(claimsProvider.future);
    });
  }

  Future<void> submitClaim(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(claimRepositoryProvider)
          .updateClaimStatus(id, ClaimStatus.submitted);
      return ref.refresh(claimsProvider.future);
    });
  }

  Future<void> approveClaim(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(claimRepositoryProvider)
          .updateClaimStatus(id, ClaimStatus.approved);
      return ref.refresh(claimsProvider.future);
    });
  }

  Future<void> rejectClaim(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(claimRepositoryProvider)
          .updateClaimStatus(id, ClaimStatus.rejected);
      return ref.refresh(claimsProvider.future);
    });
  }

  // Sub-items Management
  Future<void> addBill(String claimId, Bill bill) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(claimRepositoryProvider).addBill(claimId, bill);
      return ref.refresh(claimsProvider.future);
    });
  }

  Future<void> deleteBill(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(claimRepositoryProvider).deleteBill(id);
      return ref.refresh(claimsProvider.future);
    });
  }

  Future<void> addAdvance(String claimId, Advance advance) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(claimRepositoryProvider).addAdvance(claimId, advance);
      final claims = await ref.refresh(claimsProvider.future);

      // Check for auto-settlement or partial settlement
      final claim = claims.firstWhere((c) => c.id == claimId);
      if (claim.pendingAmount <= 0 && claim.status != ClaimStatus.settled) {
        await ref
            .read(claimRepositoryProvider)
            .updateClaimStatus(claimId, ClaimStatus.settled);
        state = await AsyncValue.guard(
          () => ref.refresh(claimsProvider.future),
        );
      } else if (claim.status == ClaimStatus.approved &&
          claim.pendingAmount > 0) {
        await ref
            .read(claimRepositoryProvider)
            .updateClaimStatus(claimId, ClaimStatus.partiallySettled);
        state = await AsyncValue.guard(
          () => ref.refresh(claimsProvider.future),
        );
      } else {
        state = AsyncValue.data(claims);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteAdvance(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(claimRepositoryProvider).deleteAdvance(id);

      // Get fresh data to check business logic
      var claims = await ref.refresh(claimsProvider.future);

      bool statusChanged = false;
      for (final claim in claims) {
        if (claim.status == ClaimStatus.settled && claim.pendingAmount > 0) {
          await ref
              .read(claimRepositoryProvider)
              .updateClaimStatus(claim.id, ClaimStatus.partiallySettled);
          statusChanged = true;
        }
      }

      // If we blindly refreshed inside the loop, we might do it multiple times.
      // Better to refresh once at the end if needed.
      if (statusChanged) {
        claims = await ref.refresh(claimsProvider.future);
      }

      return claims;
    });
  }

  Future<void> addSettlement(String claimId, Settlement settlement) async {
    state = const AsyncValue.loading();
    try {
      await ref
          .read(claimRepositoryProvider)
          .addSettlement(claimId, settlement);
      final claims = await ref.refresh(claimsProvider.future);

      // Check for auto-settlement
      final claim = claims.firstWhere((c) => c.id == claimId);
      if (claim.pendingAmount <= 0 && claim.status != ClaimStatus.settled) {
        await ref
            .read(claimRepositoryProvider)
            .updateClaimStatus(claimId, ClaimStatus.settled);
        state = await AsyncValue.guard(
          () => ref.refresh(claimsProvider.future),
        );
      } else if (claim.status == ClaimStatus.approved &&
          claim.pendingAmount > 0) {
        await ref
            .read(claimRepositoryProvider)
            .updateClaimStatus(claimId, ClaimStatus.partiallySettled);
        state = await AsyncValue.guard(
          () => ref.refresh(claimsProvider.future),
        );
      } else {
        state = AsyncValue.data(claims);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteSettlement(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(claimRepositoryProvider).deleteSettlement(id);

      var claims = await ref.refresh(claimsProvider.future);

      bool statusChanged = false;
      for (final claim in claims) {
        if (claim.status == ClaimStatus.settled && claim.pendingAmount > 0) {
          await ref
              .read(claimRepositoryProvider)
              .updateClaimStatus(claim.id, ClaimStatus.partiallySettled);
          statusChanged = true;
        }
      }

      if (statusChanged) {
        claims = await ref.refresh(claimsProvider.future);
      }

      return claims;
    });
  }
}
