import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../claims/presentation/providers/claim_provider.dart';
import '../widgets/claim_card.dart';
import '../widgets/summary_stat_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final claimsAsync = ref.watch(claimsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: theme.colorScheme.secondaryContainer,
            child: Text(
              'A',
              style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          return ref.refresh(claimsProvider.future);
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overview',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Summary Cards
                    claimsAsync.when(
                      data: (claims) {
                        final pendingAmount = claims.fold<double>(
                          0,
                          (sum, claim) => sum + claim.pendingAmount,
                        );
                        return Row(
                          children: [
                            Expanded(
                              child: SummaryStatCard(
                                title: 'Pending Amount',
                                value: '\$${pendingAmount.toStringAsFixed(2)}',
                                icon: Icons.access_time,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SummaryStatCard(
                                title: 'Total Claims',
                                value: claims.length.toString(),
                                icon: Icons.assignment_outlined,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const _LoadingSummaryCards(),
                      error: (err, stack) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Recent Claims',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            // Claims List
            claimsAsync.when(
              data: (claims) {
                if (claims.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('No claims found.'),
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final claim = claims[index];
                      return ClaimCard(
                        claim: claim,
                        onTap: () {
                          // TODO: Navigate to detail
                        },
                      );
                    }, childCount: claims.length),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) =>
                  SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
            ),
            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to create claim
        },
        label: const Text('New Claim'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _LoadingSummaryCards extends StatelessWidget {
  const _LoadingSummaryCards();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 120,
            child: Card(child: Center(child: CircularProgressIndicator())),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 120,
            child: Card(child: Center(child: CircularProgressIndicator())),
          ),
        ),
      ],
    );
  }
}
