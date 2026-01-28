import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/supabase_claim_repository.dart';
import '../../domain/repositories/claim_repository.dart';

part 'claim_repository_provider.g.dart';

@riverpod
ClaimRepository claimRepository(Ref ref) {
  // We assume Supabase is initialized in main.dart
  return SupabaseClaimRepository(Supabase.instance.client);
}
