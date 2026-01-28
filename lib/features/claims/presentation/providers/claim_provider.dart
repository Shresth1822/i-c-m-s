import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/claim.dart';
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
    state = await AsyncValue.guard(() async {
      await ref.read(claimRepositoryProvider).addAdvance(claimId, advance);
      return ref.refresh(claimsProvider.future);
    });
  }

  Future<void> deleteAdvance(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(claimRepositoryProvider).deleteAdvance(id);
      return ref.refresh(claimsProvider.future);
    });
  }

  Future<void> addSettlement(String claimId, Settlement settlement) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(claimRepositoryProvider)
          .addSettlement(claimId, settlement);
      return ref.refresh(claimsProvider.future);
    });
  }

  Future<void> deleteSettlement(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(claimRepositoryProvider).deleteSettlement(id);
      return ref.refresh(claimsProvider.future);
    });
  }
}
