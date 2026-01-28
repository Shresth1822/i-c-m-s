import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/claim.dart';
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

  // Update logic to be added when needed
}
