import '../entities/claim.dart';
import '../entities/bill.dart';
import '../entities/advance.dart';
import '../entities/settlement.dart';

abstract class ClaimRepository {
  Future<List<Claim>> getClaims();
  Future<Claim> createClaim(Claim claim);
  Future<Claim> updateClaim(Claim claim);
  Future<void> deleteClaim(String id);

  // Sub-items
  Future<void> addBill(String claimId, Bill bill);
  Future<void> deleteBill(String id);

  Future<void> addAdvance(String claimId, Advance advance);
  Future<void> deleteAdvance(String id);

  Future<void> addSettlement(String claimId, Settlement settlement);
  Future<void> deleteSettlement(String id);
}
