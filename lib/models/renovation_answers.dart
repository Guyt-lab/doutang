import 'enums.dart';

/// Évaluation des travaux de rénovation nécessaires poste par poste.
class RenovationAnswers {
  final RenovationLevel? floors;
  final RenovationLevel? walls;
  final RenovationLevel? bathroom;
  final RenovationLevel? kitchen;
  final RenovationLevel? electric;
  final RenovationLevel? plumbing;
  final RenovationLevel? windows;
  final RenovationLevel? heating;
  final String? notes;

  const RenovationAnswers({
    this.floors,
    this.walls,
    this.bathroom,
    this.kitchen,
    this.electric,
    this.plumbing,
    this.windows,
    this.heating,
    this.notes,
  });

  /// Fourchette budgétaire estimée calculée depuis les niveaux de rénovation.
  ///
  /// Règles :
  /// - ≥1 `structural` OU ≥3 `important` → above20k
  /// - ≥1 `important` OU ≥3 `cosmetic`   → between5and20k
  /// - ≥1 `cosmetic`                      → under5k
  /// - Tout `none` / null                 → none
  BudgetRange get computedBudgetRange {
    final levels = [
      floors,
      walls,
      bathroom,
      kitchen,
      electric,
      plumbing,
      windows,
      heating,
    ].whereType<RenovationLevel>().toList();

    if (levels.isEmpty) return BudgetRange.none;

    final structuralCount =
        levels.where((l) => l == RenovationLevel.structural).length;
    final importantCount =
        levels.where((l) => l == RenovationLevel.important).length;
    final cosmeticCount =
        levels.where((l) => l == RenovationLevel.cosmetic).length;

    if (structuralCount >= 1 || importantCount >= 3)
      return BudgetRange.above20k;
    if (importantCount >= 1 || cosmeticCount >= 3)
      return BudgetRange.between5and20k;
    if (cosmeticCount >= 1) return BudgetRange.under5k;
    return BudgetRange.none;
  }

  Map<String, dynamic> toJson() => {
        'floors': enumToJson(floors),
        'walls': enumToJson(walls),
        'bathroom': enumToJson(bathroom),
        'kitchen': enumToJson(kitchen),
        'electric': enumToJson(electric),
        'plumbing': enumToJson(plumbing),
        'windows': enumToJson(windows),
        'heating': enumToJson(heating),
        'notes': notes,
      };

  factory RenovationAnswers.fromJson(Map<String, dynamic> json) =>
      RenovationAnswers(
        floors: enumFromJson(RenovationLevel.values, json['floors'] as String?),
        walls: enumFromJson(RenovationLevel.values, json['walls'] as String?),
        bathroom:
            enumFromJson(RenovationLevel.values, json['bathroom'] as String?),
        kitchen:
            enumFromJson(RenovationLevel.values, json['kitchen'] as String?),
        electric:
            enumFromJson(RenovationLevel.values, json['electric'] as String?),
        plumbing:
            enumFromJson(RenovationLevel.values, json['plumbing'] as String?),
        windows:
            enumFromJson(RenovationLevel.values, json['windows'] as String?),
        heating:
            enumFromJson(RenovationLevel.values, json['heating'] as String?),
        notes: json['notes'] as String?,
      );
}
