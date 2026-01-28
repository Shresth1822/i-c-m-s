import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icms/features/claims/domain/entities/claim.dart';
import 'package:icms/features/claims/domain/repositories/claim_repository.dart';
import 'package:icms/features/claims/presentation/providers/claim_repository_provider.dart';
import 'package:icms/features/dashboard/presentation/pages/home_screen.dart';

class FakeClaimRepository implements ClaimRepository {
  @override
  Future<Claim> createClaim(Claim claim) async => claim;

  @override
  Future<void> deleteClaim(String id) async {}

  @override
  Future<List<Claim>> getClaims() async => []; // Return empty list for empty state test

  @override
  Future<Claim> updateClaim(Claim claim) async => claim;
}

void main() {
  testWidgets('App displays dashboard with empty state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          claimRepositoryProvider.overrideWithValue(FakeClaimRepository()),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // Initial load might show spinner
    await tester.pump(); // Trigger build
    // Riverpod async loading...

    // Wait for animations and async tasks
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    // Verify AppBar title
    expect(find.text('Dashboard'), findsOneWidget);

    // Verify Overview section
    expect(find.text('Overview'), findsOneWidget);

    // Verify Empty State
    expect(find.text('No claims found.'), findsOneWidget);

    // Verify Floating Action Button
    expect(find.text('New Claim'), findsOneWidget);
  });
}
