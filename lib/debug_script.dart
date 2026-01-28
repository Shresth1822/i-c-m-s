// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/claims/data/repositories/supabase_claim_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load Env
  try {
    await dotenv.load(fileName: ".env");
    print("DEBUG: Loaded .env");
  } catch (e) {
    print("CRITICAL: Failed to load .env: $e");
    return;
  }

  // 2. Init Supabase (Manual init to see errors)
  final url = dotenv.env['SUPABASE_URL'];
  final key = dotenv.env['SUPABASE_ANON_KEY'];

  if (url == null || key == null) {
    print("CRITICAL: Missing SUPABASE_URL or SUPABASE_ANON_KEY");
    return;
  }

  print("DEBUG: Initializing Supabase with URL: $url");

  try {
    await Supabase.initialize(url: url, anonKey: key);
    print("DEBUG: Supabase initialized");
  } catch (e) {
    print("CRITICAL: Supabase init failed: $e");
    return;
  }

  // 3. Test Repository - GRANULAR
  // Step A: Simple Select
  print("\n--- STEP A: Simple Select ---");
  try {
    final claims = await Supabase.instance.client.from('claims').select();
    print("SUCCESS Step A: Fetched ${claims.length} claims (raw)");
  } catch (e) {
    print("FAILURE Step A: $e");
  }

  // Step B: Single Join
  print("\n--- STEP B: Select with Bills Join ---");
  try {
    final claims = await Supabase.instance.client
        .from('claims')
        .select('*, bills(*)');
    print("SUCCESS Step B: Fetched ${claims.length} claims with bills");
  } catch (e) {
    print("FAILURE Step B: $e");
  }

  // Step C: Full Query via Repo
  print("\n--- STEP C: Repository Full Query ---");
  final repo = SupabaseClaimRepository(Supabase.instance.client);
  try {
    final claims = await repo.getClaims();
    print("SUCCESS Step C: Fetched ${claims.length} claims via Repo");
  } catch (e, stack) {
    print("CRITICAL ERROR in Step C: $e");
    print(stack);
  }
}
