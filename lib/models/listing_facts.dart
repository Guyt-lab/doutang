import 'enums.dart';
import '../services/listing_parser_service.dart';

/// Caractéristiques factuelles et objectives d'un bien immobilier.
///
/// Tous les champs sont nullable : ils sont renseignés progressivement
/// (avant/pendant/après visite) par n'importe quel owner.
/// Owner-agnostic : partagé entre partenaires, fusion par updated_at.
class ListingFacts {
  // ── Surfaces & pièces ──────────────────────────────────────────────────
  final double? surfaceTotal;
  final double? surfaceSejour;
  final int? rooms;
  final int? bedrooms;
  final int? floor;
  final int? floorsTotal;

  // ── Caractéristiques générales ─────────────────────────────────────────
  final bool? isFurnished;
  final int? buildingYear;
  final BuildingStyle? style;

  // ── Performance énergétique ────────────────────────────────────────────
  /// Classe DPE : "A" à "G" ou "NC".
  final String? dpe;
  final HeatingType? heatingType;
  final HeatingControl? heatingControl;

  // ── Menuiseries & isolation ────────────────────────────────────────────
  final GlazingType? doubleGlazing;
  final int? windowsCount;
  final bool? secureDoor;

  // ── Services & connectivité ────────────────────────────────────────────
  final bool? fiber;
  final WaterQuality? waterQuality;

  // ── Revêtements ───────────────────────────────────────────────────────
  final FloorType? floorTypeLiving;
  final FloorType? floorTypeBedroom;

  // ── Cuisine ───────────────────────────────────────────────────────────
  final KitchenType? kitchenType;
  final KitchenEnergy? kitchenEnergy;
  final bool? kitchenEquipped;

  // ── Luminosité ────────────────────────────────────────────────────────
  final LightingType? lightingLiving;
  final LightingType? lightingBedroom;

  // ── Extérieurs ────────────────────────────────────────────────────────
  final bool? hasBalcony;
  final double? balconySurface;
  final bool? hasTerrace;
  final double? terraceSurface;
  final bool? hasGarden;
  final double? gardenSurface;
  final bool? hasCourtyard;
  final bool? hasParking;
  final bool? hasCellar;

  // ── Prestations & caractère ───────────────────────────────────────────
  final bool? hasBeams;
  final bool? hasFireplace;
  final bool? fireplaceFunctional;
  final bool? hasMouldings;
  final bool? hasHallway;

  // ── Organisation intérieure ────────────────────────────────────────────
  final bool? separateToilet;
  final BathroomSize? bathroomSize;
  final bool? hasDressing;
  final Proximity? bedroomBathroomProximity;
  final Proximity? kitchenLivingProximity;

  // ── Charges ───────────────────────────────────────────────────────────
  /// Charges mensuelles en € (non comprises dans le loyer si indiquées à part).
  final double? charges;

  const ListingFacts({
    this.surfaceTotal,
    this.surfaceSejour,
    this.rooms,
    this.bedrooms,
    this.floor,
    this.floorsTotal,
    this.isFurnished,
    this.buildingYear,
    this.style,
    this.dpe,
    this.heatingType,
    this.heatingControl,
    this.doubleGlazing,
    this.windowsCount,
    this.secureDoor,
    this.fiber,
    this.waterQuality,
    this.floorTypeLiving,
    this.floorTypeBedroom,
    this.kitchenType,
    this.kitchenEnergy,
    this.kitchenEquipped,
    this.lightingLiving,
    this.lightingBedroom,
    this.hasBalcony,
    this.balconySurface,
    this.hasTerrace,
    this.terraceSurface,
    this.hasGarden,
    this.gardenSurface,
    this.hasCourtyard,
    this.hasParking,
    this.hasCellar,
    this.hasBeams,
    this.hasFireplace,
    this.fireplaceFunctional,
    this.hasMouldings,
    this.hasHallway,
    this.separateToilet,
    this.bathroomSize,
    this.hasDressing,
    this.bedroomBathroomProximity,
    this.kitchenLivingProximity,
    this.charges,
  });

  /// Vrai si aucun champ n'est renseigné.
  bool get isEmpty =>
      surfaceTotal == null &&
      surfaceSejour == null &&
      rooms == null &&
      bedrooms == null &&
      floor == null &&
      floorsTotal == null &&
      isFurnished == null &&
      buildingYear == null &&
      style == null &&
      dpe == null &&
      heatingType == null &&
      heatingControl == null &&
      doubleGlazing == null &&
      windowsCount == null &&
      secureDoor == null &&
      fiber == null &&
      waterQuality == null &&
      floorTypeLiving == null &&
      floorTypeBedroom == null &&
      kitchenType == null &&
      kitchenEnergy == null &&
      kitchenEquipped == null &&
      lightingLiving == null &&
      lightingBedroom == null &&
      hasBalcony == null &&
      hasTerrace == null &&
      hasGarden == null &&
      hasCourtyard == null &&
      hasParking == null &&
      hasCellar == null &&
      hasBeams == null &&
      hasFireplace == null &&
      fireplaceFunctional == null &&
      hasMouldings == null &&
      hasHallway == null &&
      separateToilet == null &&
      bathroomSize == null &&
      hasDressing == null &&
      bedroomBathroomProximity == null &&
      kitchenLivingProximity == null &&
      charges == null;

  /// Retourne un [ListingFacts] avec les champs non-null de [other]
  /// pour tous les champs qui sont null dans this.
  ListingFacts complement(ListingFacts? other) {
    if (other == null) return this;
    return ListingFacts(
      surfaceTotal: surfaceTotal ?? other.surfaceTotal,
      surfaceSejour: surfaceSejour ?? other.surfaceSejour,
      rooms: rooms ?? other.rooms,
      bedrooms: bedrooms ?? other.bedrooms,
      floor: floor ?? other.floor,
      floorsTotal: floorsTotal ?? other.floorsTotal,
      isFurnished: isFurnished ?? other.isFurnished,
      buildingYear: buildingYear ?? other.buildingYear,
      style: style ?? other.style,
      dpe: dpe ?? other.dpe,
      heatingType: heatingType ?? other.heatingType,
      heatingControl: heatingControl ?? other.heatingControl,
      doubleGlazing: doubleGlazing ?? other.doubleGlazing,
      windowsCount: windowsCount ?? other.windowsCount,
      secureDoor: secureDoor ?? other.secureDoor,
      fiber: fiber ?? other.fiber,
      waterQuality: waterQuality ?? other.waterQuality,
      floorTypeLiving: floorTypeLiving ?? other.floorTypeLiving,
      floorTypeBedroom: floorTypeBedroom ?? other.floorTypeBedroom,
      kitchenType: kitchenType ?? other.kitchenType,
      kitchenEnergy: kitchenEnergy ?? other.kitchenEnergy,
      kitchenEquipped: kitchenEquipped ?? other.kitchenEquipped,
      lightingLiving: lightingLiving ?? other.lightingLiving,
      lightingBedroom: lightingBedroom ?? other.lightingBedroom,
      hasBalcony: hasBalcony ?? other.hasBalcony,
      balconySurface: balconySurface ?? other.balconySurface,
      hasTerrace: hasTerrace ?? other.hasTerrace,
      terraceSurface: terraceSurface ?? other.terraceSurface,
      hasGarden: hasGarden ?? other.hasGarden,
      gardenSurface: gardenSurface ?? other.gardenSurface,
      hasCourtyard: hasCourtyard ?? other.hasCourtyard,
      hasParking: hasParking ?? other.hasParking,
      hasCellar: hasCellar ?? other.hasCellar,
      hasBeams: hasBeams ?? other.hasBeams,
      hasFireplace: hasFireplace ?? other.hasFireplace,
      fireplaceFunctional: fireplaceFunctional ?? other.fireplaceFunctional,
      hasMouldings: hasMouldings ?? other.hasMouldings,
      hasHallway: hasHallway ?? other.hasHallway,
      separateToilet: separateToilet ?? other.separateToilet,
      bathroomSize: bathroomSize ?? other.bathroomSize,
      hasDressing: hasDressing ?? other.hasDressing,
      bedroomBathroomProximity:
          bedroomBathroomProximity ?? other.bedroomBathroomProximity,
      kitchenLivingProximity:
          kitchenLivingProximity ?? other.kitchenLivingProximity,
      charges: charges ?? other.charges,
    );
  }

  Map<String, dynamic> toJson() => {
        'surface_total': surfaceTotal,
        'surface_sejour': surfaceSejour,
        'rooms': rooms,
        'bedrooms': bedrooms,
        'floor': floor,
        'floors_total': floorsTotal,
        'is_furnished': isFurnished,
        'building_year': buildingYear,
        'style': enumToJson(style),
        'dpe': dpe,
        'heating_type': enumToJson(heatingType),
        'heating_control': enumToJson(heatingControl),
        'double_glazing': enumToJson(doubleGlazing),
        'windows_count': windowsCount,
        'secure_door': secureDoor,
        'fiber': fiber,
        'water_quality': enumToJson(waterQuality),
        'floor_type_living': enumToJson(floorTypeLiving),
        'floor_type_bedroom': enumToJson(floorTypeBedroom),
        'kitchen_type': enumToJson(kitchenType),
        'kitchen_energy': enumToJson(kitchenEnergy),
        'kitchen_equipped': kitchenEquipped,
        'lighting_living': enumToJson(lightingLiving),
        'lighting_bedroom': enumToJson(lightingBedroom),
        'has_balcony': hasBalcony,
        'balcony_surface': balconySurface,
        'has_terrace': hasTerrace,
        'terrace_surface': terraceSurface,
        'has_garden': hasGarden,
        'garden_surface': gardenSurface,
        'has_courtyard': hasCourtyard,
        'has_parking': hasParking,
        'has_cellar': hasCellar,
        'has_beams': hasBeams,
        'has_fireplace': hasFireplace,
        'fireplace_functional': fireplaceFunctional,
        'has_mouldings': hasMouldings,
        'has_hallway': hasHallway,
        'separate_toilet': separateToilet,
        'bathroom_size': enumToJson(bathroomSize),
        'has_dressing': hasDressing,
        'bedroom_bathroom_proximity': enumToJson(bedroomBathroomProximity),
        'kitchen_living_proximity': enumToJson(kitchenLivingProximity),
        'charges': charges,
      };

  factory ListingFacts.fromJson(Map<String, dynamic> json) => ListingFacts(
        surfaceTotal: (json['surface_total'] as num?)?.toDouble(),
        surfaceSejour: (json['surface_sejour'] as num?)?.toDouble(),
        rooms: (json['rooms'] as num?)?.toInt(),
        bedrooms: (json['bedrooms'] as num?)?.toInt(),
        floor: (json['floor'] as num?)?.toInt(),
        floorsTotal: (json['floors_total'] as num?)?.toInt(),
        isFurnished: json['is_furnished'] as bool?,
        buildingYear: (json['building_year'] as num?)?.toInt(),
        style: enumFromJson(BuildingStyle.values, json['style'] as String?),
        dpe: json['dpe'] as String?,
        heatingType:
            enumFromJson(HeatingType.values, json['heating_type'] as String?),
        heatingControl: enumFromJson(
            HeatingControl.values, json['heating_control'] as String?),
        doubleGlazing:
            enumFromJson(GlazingType.values, json['double_glazing'] as String?),
        windowsCount: (json['windows_count'] as num?)?.toInt(),
        secureDoor: json['secure_door'] as bool?,
        fiber: json['fiber'] as bool?,
        waterQuality:
            enumFromJson(WaterQuality.values, json['water_quality'] as String?),
        floorTypeLiving: enumFromJson(
            FloorType.values, json['floor_type_living'] as String?),
        floorTypeBedroom: enumFromJson(
            FloorType.values, json['floor_type_bedroom'] as String?),
        kitchenType:
            enumFromJson(KitchenType.values, json['kitchen_type'] as String?),
        kitchenEnergy: enumFromJson(
            KitchenEnergy.values, json['kitchen_energy'] as String?),
        kitchenEquipped: json['kitchen_equipped'] as bool?,
        lightingLiving: enumFromJson(
            LightingType.values, json['lighting_living'] as String?),
        lightingBedroom: enumFromJson(
            LightingType.values, json['lighting_bedroom'] as String?),
        hasBalcony: json['has_balcony'] as bool?,
        balconySurface: (json['balcony_surface'] as num?)?.toDouble(),
        hasTerrace: json['has_terrace'] as bool?,
        terraceSurface: (json['terrace_surface'] as num?)?.toDouble(),
        hasGarden: json['has_garden'] as bool?,
        gardenSurface: (json['garden_surface'] as num?)?.toDouble(),
        hasCourtyard: json['has_courtyard'] as bool?,
        hasParking: json['has_parking'] as bool?,
        hasCellar: json['has_cellar'] as bool?,
        hasBeams: json['has_beams'] as bool?,
        hasFireplace: json['has_fireplace'] as bool?,
        fireplaceFunctional: json['fireplace_functional'] as bool?,
        hasMouldings: json['has_mouldings'] as bool?,
        hasHallway: json['has_hallway'] as bool?,
        separateToilet: json['separate_toilet'] as bool?,
        bathroomSize:
            enumFromJson(BathroomSize.values, json['bathroom_size'] as String?),
        hasDressing: json['has_dressing'] as bool?,
        bedroomBathroomProximity: enumFromJson(
            Proximity.values, json['bedroom_bathroom_proximity'] as String?),
        kitchenLivingProximity: enumFromJson(
            Proximity.values, json['kitchen_living_proximity'] as String?),
        charges: (json['charges'] as num?)?.toDouble(),
      );

  /// Crée un [ListingFacts] pré-rempli depuis les données extraites par le parser.
  static ListingFacts fromParsed(ParsedListing p) => ListingFacts(
        surfaceTotal: p.surface,
        rooms: p.rooms,
        bedrooms: p.bedrooms,
        floor: p.floor,
        floorsTotal: p.floorsTotal,
        isFurnished: p.isFurnished,
        buildingYear: p.constructionYear,
        dpe: p.dpe,
        heatingType: _heatingTypeFromString(p.heatingType),
        heatingControl: p.heatingCollective == true
            ? HeatingControl.collectif
            : p.heatingCollective == false
                ? HeatingControl.individuel
                : null,
        hasBalcony: p.hasBalcony,
        balconySurface: p.balconySurface,
        hasTerrace: p.hasTerrace,
        terraceSurface: p.terraceSurface,
        hasGarden: p.hasGarden,
        gardenSurface: p.gardenSurface,
        hasParking: p.hasParking,
        hasCellar: p.hasCellar,
        hasFireplace: p.hasFireplace,
        hasBeams: p.hasBeams,
        hasMouldings: p.hasMouldings,
        kitchenType: _kitchenTypeFromString(p.kitchenType),
        fiber: p.fiber,
        charges: p.charges,
      );

  static HeatingType? _heatingTypeFromString(String? s) => switch (s) {
        'gaz' => HeatingType.gaz,
        'electrique' => HeatingType.electrique,
        'fioul' => HeatingType.fioul,
        'pompeAChaleur' => HeatingType.pompeAChaleur,
        'bois' => HeatingType.bois,
        'climReversible' => HeatingType.climReversible,
        _ => s != null ? HeatingType.autre : null,
      };

  static KitchenType? _kitchenTypeFromString(String? s) => switch (s) {
        'ouverte' => KitchenType.ouverte,
        'fermee' => KitchenType.fermee,
        'semiOuverte' => KitchenType.semiOuverte,
        'americaine' => KitchenType.americaine,
        _ => null,
      };
}
