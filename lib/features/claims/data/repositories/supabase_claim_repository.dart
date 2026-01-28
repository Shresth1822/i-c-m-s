import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/claim.dart';
import '../../domain/entities/claim_status.dart';
import '../../domain/entities/bill.dart';
import '../../domain/entities/advance.dart';
import '../../domain/entities/settlement.dart';
import '../../domain/repositories/claim_repository.dart';

class SupabaseClaimRepository implements ClaimRepository {
  final SupabaseClient _client;

  SupabaseClaimRepository(this._client);

  @override
  Future<List<Claim>> getClaims() async {
    try {
      final response = await _client
          .from('claims')
          .select('*, bills(*), advances(*), settlements(*)')
          .order('created_at', ascending: false);

      // response is PostgrestList which acts as List<Map<String, dynamic>>
      final data = response;

      return data.map((json) {
        try {
          return Claim.fromJson(json);
        } catch (e, stack) {
          log(
            'Error parsing claim JSON: $json',
            name: 'SupabaseClaimRepository',
            error: e,
            stackTrace: stack,
          );
          // Return a placeholder or rethrow. Rethrowing to make it visible.
          // In production, we might want to skip malformed items:
          // return null;
          rethrow;
        }
      }).toList();
    } catch (e, stack) {
      log(
        'Error fetching claims',
        name: 'SupabaseClaimRepository',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  @override
  Future<Claim> createClaim(Claim claim) async {
    // We only insert the main claim data first.
    // Bills, Advances, Settlement creation is usually handled separately or via RPC,
    // but for simplicity in this phase, we'll assume we are creating the parent claim.
    // Note: The UI for creating a claim usually saves the claim first, then adds items.
    // If we want to save everything at once, we'd need to do multiple inserts.
    // For now, let's insert the claim itself.

    // We exclude 'bills', 'advances', 'settlements' from the claim JSON for insertion
    // because they are separate tables.
    final claimJson = claim.toJson();
    claimJson.remove('bills');
    claimJson.remove('advances');
    claimJson.remove('settlements');
    claimJson.remove(
      'id',
    ); // ID is gen_random_uuid() DB side, or we generate it client side.
    // If we generate client side, we keep it. If we want DB to generate, we remove it.
    // The model has 'id' required. Let's assume we let DB generate if it's empty/temp,
    // but our model requires it. A better approach is to let the Repo handle ID generation
    // or return the new object with the DB-generated ID.
    // For this implementation, let's assume we omit ID if it's new/empty and let DB return it.
    if (claim.id.isEmpty) {
      claimJson.remove('id');
    }

    final response = await _client
        .from('claims')
        .insert(claimJson)
        .select()
        .single();

    return Claim.fromJson(response);
  }

  @override
  Future<Claim> updateClaim(Claim claim) async {
    final claimJson = claim.toJson();
    // Remove related data that shouldn't be updated via the claims table
    claimJson.remove('bills');
    claimJson.remove('advances');
    claimJson.remove('settlements');
    // We don't update created_at usually
    claimJson.remove('created_at');
    claimJson['updated_at'] = DateTime.now().toIso8601String();

    final response = await _client
        .from('claims')
        .update(claimJson)
        .eq('id', claim.id)
        .select()
        .single();

    return Claim.fromJson(response);
  }

  @override
  Future<void> deleteClaim(String id) async {
    await _client.from('claims').delete().eq('id', id);
  }

  @override
  Future<void> updateClaimStatus(String id, ClaimStatus status) async {
    await _client
        .from('claims')
        .update({
          'status': status.name,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  }

  @override
  Future<void> addBill(String claimId, Bill bill) async {
    final json = bill.toJson();
    json['claim_id'] = claimId;
    if (bill.id.isEmpty) json.remove('id'); // Let DB generate ID
    await _client.from('bills').insert(json);
  }

  @override
  Future<void> deleteBill(String id) async {
    await _client.from('bills').delete().eq('id', id);
  }

  @override
  Future<void> addAdvance(String claimId, Advance advance) async {
    final json = advance.toJson();
    json['claim_id'] = claimId;
    if (advance.id.isEmpty) json.remove('id');
    await _client.from('advances').insert(json);
  }

  @override
  Future<void> deleteAdvance(String id) async {
    await _client.from('advances').delete().eq('id', id);
  }

  @override
  Future<void> addSettlement(String claimId, Settlement settlement) async {
    final json = settlement.toJson();
    json['claim_id'] = claimId;
    if (settlement.id.isEmpty) json.remove('id');
    await _client.from('settlements').insert(json);
  }

  @override
  Future<void> deleteSettlement(String id) async {
    await _client.from('settlements').delete().eq('id', id);
  }
}
