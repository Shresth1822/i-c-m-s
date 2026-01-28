import '../entities/claim.dart';

abstract class ClaimRepository {
  Future<List<Claim>> getClaims();
  Future<Claim> createClaim(Claim claim);
  Future<Claim> updateClaim(Claim claim);
  Future<void> deleteClaim(String id);
}
