enum ClaimStatus {
  draft,
  submitted,
  approved,
  rejected,
  partiallySettled;

  String get label {
    switch (this) {
      case ClaimStatus.draft:
        return 'Draft';
      case ClaimStatus.submitted:
        return 'Submitted';
      case ClaimStatus.approved:
        return 'Approved';
      case ClaimStatus.rejected:
        return 'Rejected';
      case ClaimStatus.partiallySettled:
        return 'Partially Settled';
    }
  }

  static ClaimStatus fromString(String status) {
    return ClaimStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == status.toLowerCase(),
      orElse: () => ClaimStatus.draft,
    );
  }
}
