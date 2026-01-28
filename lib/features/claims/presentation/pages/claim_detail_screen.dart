import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/claim.dart';
import '../../domain/entities/claim_status.dart';
import '../../domain/entities/bill.dart';
import '../../domain/entities/advance.dart';
import '../../domain/entities/settlement.dart';
import '../providers/claim_provider.dart';
import '../widgets/item_list_section.dart';
import '../../../auth/presentation/providers/role_provider.dart';

import 'claim_form_screen.dart';

// Assuming Status Badge is available or we use a simple Chip.
// If StatusBadge is in dashboard, we should move it to common or import it.
// For now, I'll use a simple Chip if imports fail, or try to import from dashboard if allowed.
// But better to duplicate or move. I'll check file structure later.
// Actually, I'll allow the user to fix the import or I'll use a local helper.

import '../../../dashboard/presentation/widgets/status_badge.dart';

class ClaimDetailScreen extends ConsumerWidget {
  final Claim claim;

  const ClaimDetailScreen({super.key, required this.claim});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat('MMM dd, yyyy');

    // We watch the provider to get the latest version of this claim
    // (in case sub-items are added/removed)
    // (in case sub-items are added/removed)
    final claimsAsync = ref.watch(claimsProvider);
    final role = ref.watch(roleProvider);

    // Find the specific claim in the list
    final latestClaim =
        claimsAsync.value?.firstWhere(
          (c) => c.id == claim.id,
          orElse: () => claim,
        ) ??
        claim;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Claim Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClaimFormScreen(claim: latestClaim),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Claim?'),
                  content: const Text('This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await ref
                    .read(claimsProvider.notifier)
                    .deleteClaim(latestClaim.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        latestClaim.patientName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Policy: ${latestClaim.policyNumber}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: latestClaim.status),
              ],
            ),
            const SizedBox(height: 24),

            // Financial Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      context,
                      'Total Bill',
                      currencyFormat.format(latestClaim.totalBillAmount),
                    ),
                    _buildSummaryItem(
                      context,
                      'Paid',
                      currencyFormat.format(
                        latestClaim.totalSettledAmount +
                            latestClaim.totalAdvanceAmount,
                      ),
                      color: Colors.green,
                    ),
                    _buildSummaryItem(
                      context,
                      'Pending',
                      currencyFormat.format(latestClaim.pendingAmount),
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Bills Section
            ItemListSection<Bill>(
              title: 'Bills',
              items: latestClaim.bills,
              onAdd: role == UserRole.user
                  ? () => _showAddBillDialog(context, ref, latestClaim.id)
                  : null,
              onDelete: role == UserRole.user
                  ? (bill) => _confirmDelete(
                      context,
                      'Bill',
                      () =>
                          ref.read(claimsProvider.notifier).deleteBill(bill.id),
                    )
                  : null,
              itemBuilder: (context, bill) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(bill.description ?? 'Bill'),
                subtitle: Text(dateFormat.format(bill.date)),
                trailing: Text(
                  currencyFormat.format(bill.amount),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Divider(height: 48),

            // Advances Section
            ItemListSection<Advance>(
              title: 'Advances',
              items: latestClaim.advances,
              onAdd: role == UserRole.admin
                  ? () => _showAddAdvanceDialog(context, ref, latestClaim.id)
                  : null,
              onDelete: role == UserRole.admin
                  ? (adv) => _confirmDelete(
                      context,
                      'Advance',
                      () => ref
                          .read(claimsProvider.notifier)
                          .deleteAdvance(adv.id),
                    )
                  : null,
              itemBuilder: (context, adv) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(adv.reason ?? 'Advance'),
                subtitle: Text(dateFormat.format(adv.date)),
                trailing: Text(
                  currencyFormat.format(adv.amount),
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const Divider(height: 48),

            // Settlements Section
            ItemListSection<Settlement>(
              title: 'Settlements',
              items: latestClaim.settlements,
              onAdd: role == UserRole.admin
                  ? () => _showAddSettlementDialog(context, ref, latestClaim.id)
                  : null,
              onDelete: role == UserRole.admin
                  ? (st) => ref
                        .read(claimsProvider.notifier)
                        .deleteSettlement(st.id)
                  : null,
              itemBuilder: (context, st) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(st.notes ?? 'Settlement'),
                subtitle: Text(dateFormat.format(st.date)),
                trailing: Text(
                  currencyFormat.format(st.amount),
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const Divider(height: 48),
            if (role == UserRole.user &&
                latestClaim.status == ClaimStatus.draft) ...[
              _buildActionButtons(context, ref, latestClaim),
            ] else if (role == UserRole.admin &&
                latestClaim.status == ClaimStatus.submitted) ...[
              _buildActionButtons(context, ref, latestClaim),
            ] else if (latestClaim.status == ClaimStatus.rejected ||
                latestClaim.status == ClaimStatus.settled) ...[
              _buildActionButtons(context, ref, latestClaim),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, Claim claim) {
    if (claim.status == ClaimStatus.draft) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () => _performAction(
            context,
            () => ref.read(claimsProvider.notifier).submitClaim(claim.id),
            successMessage: 'Claim submitted successfully',
          ),
          icon: const Icon(Icons.send),
          label: const Text('Submit Claim'),
        ),
      );
    } else if (claim.status == ClaimStatus.submitted) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _performAction(
                context,
                () => ref.read(claimsProvider.notifier).rejectClaim(claim.id),
                successMessage: 'Claim rejected',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              icon: const Icon(Icons.close),
              label: const Text('Reject'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton.icon(
              onPressed: () => _performAction(
                context,
                () => ref.read(claimsProvider.notifier).approveClaim(claim.id),
                successMessage: 'Claim approved',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.check),
              label: const Text('Approve'),
            ),
          ),
        ],
      );
    } else if (claim.status == ClaimStatus.rejected) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
        ),
        child: const Text(
          'This claim has been rejected.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      );
    } else if (claim.status == ClaimStatus.settled) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.teal.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.teal.withValues(alpha: 0.5)),
        ),
        child: const Text(
          'This claim is fully settled.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value, {
    Color? color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Future<void> _showAddBillDialog(
    BuildContext context,
    WidgetRef ref,
    String claimId,
  ) async {
    final amountController = TextEditingController();
    final descController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Bill'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0) {
                final bill = Bill(
                  id: '', // let DB generate
                  amount: amount,
                  date: DateTime.now(),
                  description: descController.text,
                  claimId: claimId,
                );
                Navigator.pop(ctx); // Close dialog first
                _performAction(
                  context,
                  () =>
                      ref.read(claimsProvider.notifier).addBill(claimId, bill),
                  successMessage: 'Bill added',
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddAdvanceDialog(
    BuildContext context,
    WidgetRef ref,
    String claimId,
  ) async {
    final amountController = TextEditingController();
    final reasonController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Advance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Reason'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0) {
                final advance = Advance(
                  id: '',
                  amount: amount,
                  date: DateTime.now(),
                  reason: reasonController.text,
                  claimId: claimId,
                );
                Navigator.pop(ctx);
                _performAction(
                  context,
                  () => ref
                      .read(claimsProvider.notifier)
                      .addAdvance(claimId, advance),
                  successMessage: 'Advance added',
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddSettlementDialog(
    BuildContext context,
    WidgetRef ref,
    String claimId,
  ) async {
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Settlement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0) {
                final settlement = Settlement(
                  id: '',
                  amount: amount,
                  date: DateTime.now(),
                  notes: notesController.text,
                  claimId: claimId,
                );
                Navigator.pop(ctx);
                _performAction(
                  context,
                  () => ref
                      .read(claimsProvider.notifier)
                      .addSettlement(claimId, settlement),
                  successMessage: 'Settlement added',
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

Future<void> _performAction(
  BuildContext context,
  Future<void> Function() action, {
  String successMessage = 'Operation successful',
}) async {
  try {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await action();

    if (context.mounted) {
      Navigator.pop(context); // Dismiss loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage), backgroundColor: Colors.green),
      );
    }
  } catch (e) {
    if (context.mounted) {
      Navigator.pop(context); // Dismiss loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

Future<void> _confirmDelete(
  BuildContext context,
  String title,
  VoidCallback onDelete,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Delete $title?'),
      content: const Text('This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  if (confirmed == true && context.mounted) {
    await _performAction(
      context,
      () async => onDelete(),
      successMessage: '$title deleted successfully',
    );
  }
}
