/// Compatibility exceptions that existed before the architecture migration.
///
/// Every entry is intentionally narrow: a new import, singleton use, or UI
/// type reference must either remove an entry in its planned phase or add a
/// separately reviewed exception here.
enum LegacyBoundaryKind { coreToFeatureImport, sdkSingleton, serviceUiType }

enum LegacyOwner {
  appComposition,
  ledger,
  budget,
  notifications,
  reset,
  appUpdate,
  feedback,
}

enum RemovalPhase {
  pr2_1,
  pr2_3,
  pr3_2,
  pr4_1,
  pr5_1,
  pr5_3,
  pr5_4,
  pr6_1,
  pr6_3,
}

class LegacyBoundaryAllowance {
  const LegacyBoundaryAllowance({
    required this.filePath,
    required this.kind,
    required this.target,
    required this.reason,
    required this.owner,
    required this.removalPhase,
    this.expectedOccurrences = 1,
  });

  final String filePath;
  final LegacyBoundaryKind kind;
  final String target;
  final String reason;
  final LegacyOwner owner;
  final RemovalPhase removalPhase;
  final int expectedOccurrences;

  @override
  String toString() =>
      '$filePath: $target (${kind.name}; ${owner.name}; ${removalPhase.name})';
}

const allowedLegacyImports = <LegacyBoundaryAllowance>[];
