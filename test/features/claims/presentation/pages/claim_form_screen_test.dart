import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icms/features/claims/domain/entities/claim.dart';
import 'package:icms/features/claims/domain/entities/claim_status.dart';
import 'package:icms/features/claims/presentation/pages/claim_form_screen.dart';

// Mock the Provider/Notifier if needed, but for Widget testing UI logic,
// we can sometimes just rely on the fact that it tries to call the provider.
// However, creating a mock provider is safer to avoid actual DB calls (though our Repo is Supabase).
// For simplicity in this widget test, we'll override the provider with a fake/mock.

// Since generating Mocks requires build_runner which is slow, we will likely test
// the UI validation logic which doesn't depend on the provider
// until the save button is clicked.

void main() {
  testWidgets('ClaimFormScreen shows validation errors for empty fields', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ClaimFormScreen())),
    );

    // Verify initial state
    expect(find.text('New Claim'), findsOneWidget);
    expect(find.text('Create Claim'), findsOneWidget);

    // Tap Save without filling anything
    await tester.tap(find.text('Create Claim'));
    await tester.pump();

    // Verify validation errors
    expect(find.text('Please enter policy number'), findsOneWidget);
    expect(find.text('Please enter patient name'), findsOneWidget);
  });

  testWidgets('ClaimFormScreen populates fields in Edit mode', (tester) async {
    final claim = Claim(
      id: '123',
      policyNumber: 'POL-999',
      patientName: 'Jane Doe',
      patientEmail: 'jane@example.com',
      status: ClaimStatus.submitted,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: ClaimFormScreen(claim: claim)),
      ),
    );

    expect(find.text('Edit Claim'), findsOneWidget);
    expect(find.text('POL-999'), findsOneWidget);
    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.text('jane@example.com'), findsOneWidget);
    expect(find.text('Submitted'), findsOneWidget); // Dropdown value
  });
}
