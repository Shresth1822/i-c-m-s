import 'package:flutter/material.dart';
import '../../../../features/claims/domain/entities/claim_status.dart';

class StatusBadge extends StatelessWidget {
  final ClaimStatus status;

  const StatusBadge({super.key, required this.status});

  Color _getColor(BuildContext context) {
    switch (status) {
      case ClaimStatus.draft:
        return Colors.orange;
      case ClaimStatus.submitted:
        return Colors.blue;
      case ClaimStatus.approved:
        return Colors.green;
      case ClaimStatus.rejected:
        return Colors.red;
      case ClaimStatus.partiallySettled:
        return Colors.purple;
      case ClaimStatus.settled:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
