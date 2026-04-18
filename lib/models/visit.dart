import 'package:uuid/uuid.dart';

import 'renovation_answers.dart';

const _uuid = Uuid();

class Visit {
  final String id;
  final String listingId;
  final String owner;
  final DateTime visitedAt;
  final VisitAnswers answers;
  final int feeling;
  final double score;
  final List<String> photos;
  final DateTime updatedAt;

  Visit({
    String? id,
    required this.listingId,
    required this.owner,
    DateTime? visitedAt,
    VisitAnswers? answers,
    int? feeling,
    double? score,
    List<String>? photos,
    DateTime? updatedAt,
  })  : id = id ?? _uuid.v4(),
        visitedAt = visitedAt ?? DateTime.now(),
        answers = answers ?? VisitAnswers(),
        feeling = feeling ?? 3,
        score = score ?? 0.0,
        photos = photos ?? [],
        updatedAt = updatedAt ?? DateTime.now();

  Visit copyWith({
    VisitAnswers? answers,
    int? feeling,
    double? score,
    List<String>? photos,
  }) {
    return Visit(
      id: id,
      listingId: listingId,
      owner: owner,
      visitedAt: visitedAt,
      answers: answers ?? this.answers,
      feeling: feeling ?? this.feeling,
      score: score ?? this.score,
      photos: photos ?? this.photos,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'listing_id': listingId,
        'owner': owner,
        'visited_at': visitedAt.toIso8601String(),
        'answers': answers.toJson(),
        'feeling': feeling,
        'score': score,
        'photos': photos,
        'updated_at': updatedAt.toIso8601String(),
      };

  factory Visit.fromJson(Map<String, dynamic> json) => Visit(
        id: json['id'] as String,
        listingId: json['listing_id'] as String,
        owner: json['owner'] as String,
        visitedAt: DateTime.parse(json['visited_at'] as String),
        answers: VisitAnswers.fromJson(
            json['answers'] as Map<String, dynamic>),
        feeling: (json['feeling'] as num).toInt(),
        score: (json['score'] as num).toDouble(),
        photos: List<String>.from(json['photos'] as List? ?? []),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
}

/// Réponses complètes d'une visite.
///
/// Compatibilité ascendante garantie : tous les nouveaux champs sont nullable
/// et absents des fichiers v1 → désérialisés comme null sans erreur.
class VisitAnswers {
  // ── Champs v1 (conservés à l'identique) ──────────────────────────────────

  final int? luminosite;
  final int? calme;
  final int? etatGeneral;
  final int? cuisine;
  final int? salleDeBain;
  final int? rangements;
  final int? chauffage;
  final int? quartier;

  final bool? doubleVitrage;
  final bool? gardien;
  final bool? cave;
  final bool? balconOuTerrasse;
  final bool? ascenseur;
  final bool? digicode;

  final String? coupDeCoeur;
  final String? pointRedhibitoire;

  // ── Champs v2 : Transports & Quartier ────────────────────────────────────

  /// Note 1-5 : satisfaction globale du trajet.
  final int? transportScore;

  /// Durée réelle de trajet en minutes (utilisée pour le bloqueur transport).
  final int? transportMinutes;

  /// Description des moyens de transport utilisés.
  final String? transportType;

  /// Services de mobilité disponibles (vélos, trottinettes…).
  final String? mobilityService;

  final int? noiseScore;
  final int? neighborhoodScore;
  final int? safetyScore;
  final int? greenScore;

  // ── Champs v2 : Immeuble ─────────────────────────────────────────────────

  final int? commonAreasScore;
  final bool? elevatorOk;
  final bool? caveOk;
  final bool? secureDoorOk;
  final bool? bikeStorage;

  // ── Champs v2 : Luminosité & Vue ─────────────────────────────────────────

  /// Note 1-5 luminosité (champ v2, complète `luminosite`).
  final int? luminosityScore;

  /// Heure de la visite au format "HH:mm".
  final String? visitTime;
  final int? visAVisScore;

  // ── Champs v2 : Acoustique & Isolation ───────────────────────────────────

  /// Note 1-5 isolation phonique globale (utilisé pour le bloqueur phonics).
  final int? phonicsScore;
  final bool? humidityDetected;
  final int? heatingDistributionScore;
  final int? thermalInsulationScore;

  // ── Champs v2 : Équipements techniques ───────────────────────────────────

  final bool? towelRadiatorSdb;
  final int? lightingScore;
  final bool? waterPressureOk;
  final int? waterQualityScore;
  final bool? electricPanelOk;
  final bool? earthGroundOk;
  final int? outletsScore;
  final bool? mobileSignalOk;
  final bool? vmcOk;

  // ── Champs v2 : Cuisine ──────────────────────────────────────────────────

  final int? kitchenWorktopScore;
  final bool? fridgeSpaceOk;
  final bool? hoodOk;
  final bool? washingMachineSpace;

  // ── Champs v2 : Aspects pratiques & admin ────────────────────────────────

  final String? departureReason;
  final DateTime? availabilityDate;
  final double? agencyFees;
  final double? guaranteeDeposit;
  final double? landTax;
  final RenovationAnswers? renovation;
  final bool? liveIn2Years;

  // ── Champs v2 : Charges ───────────────────────────────────────────────────

  /// Montant des charges mensuelles (texte brut, parsé à l'affichage).
  final String? chargesAmount;

  // ── Champs v2 : Espaces extérieurs ───────────────────────────────────────

  /// JSON-encoded List<{type, surface?}> — ex. [{"type":"Balcon","surface":8.5}]
  final String? exteriorSpaces;

  // ── Champs v2 : Nouveaux équipements ─────────────────────────────────────

  /// Taille ascenseur (JSON-encoded List<String> : 'Petit', 'Moyen', 'Grand').
  final String? elevatorSize;
  final bool? parking;
  final bool? buildingConcierge;
  final bool? radiatorLiving;
  final bool? radiatorBathroom;
  final bool? radiatorBedroom;

  /// Texte libre décrivant le type/mode de chauffage.
  final String? heatingSystem;

  // ── Champs v2 : Immeuble complémentaires ─────────────────────────────────

  final bool? caveAccess;
  final bool? caveDoor;
  final bool? caveDry;
  final bool? bikeStorageSecured;
  final bool? bikeStorageSpace;
  final int? trashAccess;
  final bool? disabledAccess;

  // ── Champs v2 : Cuisine complémentaires ──────────────────────────────────

  final bool? dishwasherSpace;
  final bool? trashSpace;

  /// JSON-encoded List<String> : 'Ouverte', 'Semi-ouverte', 'Fermée'
  final String? kitchenOpenClosed;
  final bool? vmcKitchen;

  // ── Champs v2 : Salle de bain ─────────────────────────────────────────────

  /// JSON-encoded List<String> des équipements présents (douche, VMC…)
  final String? bathroomFeatures;

  // ── Champs v2 : Espaces extérieurs ──────────────────────────────────────

  final String? outdoorSurface;
  final int? outdoorNeighborExposure;
  final int? outdoorSunExposure;
  final int? outdoorViewQuality;

  VisitAnswers({
    // v1
    this.luminosite,
    this.calme,
    this.etatGeneral,
    this.cuisine,
    this.salleDeBain,
    this.rangements,
    this.chauffage,
    this.quartier,
    this.doubleVitrage,
    this.gardien,
    this.cave,
    this.balconOuTerrasse,
    this.ascenseur,
    this.digicode,
    this.coupDeCoeur,
    this.pointRedhibitoire,
    // v2
    this.transportScore,
    this.transportMinutes,
    this.transportType,
    this.mobilityService,
    this.noiseScore,
    this.neighborhoodScore,
    this.safetyScore,
    this.greenScore,
    this.commonAreasScore,
    this.elevatorOk,
    this.caveOk,
    this.secureDoorOk,
    this.bikeStorage,
    this.luminosityScore,
    this.visitTime,
    this.visAVisScore,
    this.phonicsScore,
    this.humidityDetected,
    this.heatingDistributionScore,
    this.thermalInsulationScore,
    this.towelRadiatorSdb,
    this.lightingScore,
    this.waterPressureOk,
    this.waterQualityScore,
    this.electricPanelOk,
    this.earthGroundOk,
    this.outletsScore,
    this.mobileSignalOk,
    this.vmcOk,
    this.kitchenWorktopScore,
    this.fridgeSpaceOk,
    this.hoodOk,
    this.washingMachineSpace,
    this.departureReason,
    this.availabilityDate,
    this.agencyFees,
    this.guaranteeDeposit,
    this.landTax,
    this.renovation,
    this.liveIn2Years,
    this.chargesAmount,
    this.exteriorSpaces,
    this.elevatorSize,
    this.parking,
    this.buildingConcierge,
    this.radiatorLiving,
    this.radiatorBathroom,
    this.radiatorBedroom,
    this.heatingSystem,
    this.caveAccess,
    this.caveDoor,
    this.caveDry,
    this.bikeStorageSecured,
    this.bikeStorageSpace,
    this.trashAccess,
    this.disabledAccess,
    this.dishwasherSpace,
    this.trashSpace,
    this.kitchenOpenClosed,
    this.vmcKitchen,
    this.bathroomFeatures,
    this.outdoorSurface,
    this.outdoorNeighborExposure,
    this.outdoorSunExposure,
    this.outdoorViewQuality,
  });

  /// Champs notés 1-5 utilisés pour le calcul du score v1 (rétrocompat).
  Map<String, int?> get ratedAnswers => {
        'luminosite': luminosite,
        'calme': calme,
        'etat_general': etatGeneral,
        'cuisine': cuisine,
        'salle_de_bain': salleDeBain,
        'rangements': rangements,
        'chauffage': chauffage,
        'quartier': quartier,
      };

  Map<String, dynamic> toJson() => {
        // v1
        'luminosite': luminosite,
        'calme': calme,
        'etat_general': etatGeneral,
        'cuisine': cuisine,
        'salle_de_bain': salleDeBain,
        'rangements': rangements,
        'chauffage': chauffage,
        'quartier': quartier,
        'double_vitrage': doubleVitrage,
        'gardien': gardien,
        'cave': cave,
        'balcon_ou_terrasse': balconOuTerrasse,
        'ascenseur': ascenseur,
        'digicode': digicode,
        'coup_de_coeur': coupDeCoeur,
        'point_redhibitoire': pointRedhibitoire,
        // v2
        'transport_score': transportScore,
        'transport_minutes': transportMinutes,
        'transport_type': transportType,
        'mobility_service': mobilityService,
        'noise_score': noiseScore,
        'neighborhood_score': neighborhoodScore,
        'safety_score': safetyScore,
        'green_score': greenScore,
        'common_areas_score': commonAreasScore,
        'elevator_ok': elevatorOk,
        'cave_ok': caveOk,
        'secure_door_ok': secureDoorOk,
        'bike_storage': bikeStorage,
        'luminosity_score': luminosityScore,
        'visit_time': visitTime,
        'vis_a_vis_score': visAVisScore,
        'phonics_score': phonicsScore,
        'humidity_detected': humidityDetected,
        'heating_distribution_score': heatingDistributionScore,
        'thermal_insulation_score': thermalInsulationScore,
        'towel_radiator_sdb': towelRadiatorSdb,
        'lighting_score': lightingScore,
        'water_pressure_ok': waterPressureOk,
        'water_quality_score': waterQualityScore,
        'electric_panel_ok': electricPanelOk,
        'earth_ground_ok': earthGroundOk,
        'outlets_score': outletsScore,
        'mobile_signal_ok': mobileSignalOk,
        'vmc_ok': vmcOk,
        'kitchen_worktop_score': kitchenWorktopScore,
        'fridge_space_ok': fridgeSpaceOk,
        'hood_ok': hoodOk,
        'washing_machine_space': washingMachineSpace,
        'departure_reason': departureReason,
        'availability_date': availabilityDate?.toIso8601String(),
        'agency_fees': agencyFees,
        'guarantee_deposit': guaranteeDeposit,
        'land_tax': landTax,
        'renovation': renovation?.toJson(),
        'live_in_2_years': liveIn2Years,
        'charges_amount': chargesAmount,
        'exterior_spaces': exteriorSpaces,
        'elevator_size': elevatorSize,
        'parking': parking,
        'building_concierge': buildingConcierge,
        'radiator_living': radiatorLiving,
        'radiator_bathroom': radiatorBathroom,
        'radiator_bedroom': radiatorBedroom,
        'heating_system': heatingSystem,
        'cave_access': caveAccess,
        'cave_door': caveDoor,
        'cave_dry': caveDry,
        'bike_storage_secured': bikeStorageSecured,
        'bike_storage_space': bikeStorageSpace,
        'trash_access': trashAccess,
        'disabled_access': disabledAccess,
        'dishwasher_space': dishwasherSpace,
        'trash_space': trashSpace,
        'kitchen_open_closed': kitchenOpenClosed,
        'vmc_kitchen': vmcKitchen,
        'bathroom_features': bathroomFeatures,
        'outdoor_surface': outdoorSurface,
        'outdoor_neighbor_exposure': outdoorNeighborExposure,
        'outdoor_sun_exposure': outdoorSunExposure,
        'outdoor_view_quality': outdoorViewQuality,
      };

  factory VisitAnswers.fromJson(Map<String, dynamic> json) => VisitAnswers(
        // v1
        luminosite: (json['luminosite'] as num?)?.toInt(),
        calme: (json['calme'] as num?)?.toInt(),
        etatGeneral: (json['etat_general'] as num?)?.toInt(),
        cuisine: (json['cuisine'] as num?)?.toInt(),
        salleDeBain: (json['salle_de_bain'] as num?)?.toInt(),
        rangements: (json['rangements'] as num?)?.toInt(),
        chauffage: (json['chauffage'] as num?)?.toInt(),
        quartier: (json['quartier'] as num?)?.toInt(),
        doubleVitrage: json['double_vitrage'] as bool?,
        gardien: json['gardien'] as bool?,
        cave: json['cave'] as bool?,
        balconOuTerrasse: json['balcon_ou_terrasse'] as bool?,
        ascenseur: json['ascenseur'] as bool?,
        digicode: json['digicode'] as bool?,
        coupDeCoeur: json['coup_de_coeur'] as String?,
        pointRedhibitoire: json['point_redhibitoire'] as String?,
        // v2
        transportScore: (json['transport_score'] as num?)?.toInt(),
        transportMinutes: (json['transport_minutes'] as num?)?.toInt(),
        transportType: json['transport_type'] as String?,
        mobilityService: json['mobility_service'] as String?,
        noiseScore: (json['noise_score'] as num?)?.toInt(),
        neighborhoodScore: (json['neighborhood_score'] as num?)?.toInt(),
        safetyScore: (json['safety_score'] as num?)?.toInt(),
        greenScore: (json['green_score'] as num?)?.toInt(),
        commonAreasScore: (json['common_areas_score'] as num?)?.toInt(),
        elevatorOk: json['elevator_ok'] as bool?,
        caveOk: json['cave_ok'] as bool?,
        secureDoorOk: json['secure_door_ok'] as bool?,
        bikeStorage: json['bike_storage'] as bool?,
        luminosityScore: (json['luminosity_score'] as num?)?.toInt(),
        visitTime: json['visit_time'] as String?,
        visAVisScore: (json['vis_a_vis_score'] as num?)?.toInt(),
        phonicsScore: (json['phonics_score'] as num?)?.toInt(),
        humidityDetected: json['humidity_detected'] as bool?,
        heatingDistributionScore:
            (json['heating_distribution_score'] as num?)?.toInt(),
        thermalInsulationScore:
            (json['thermal_insulation_score'] as num?)?.toInt(),
        towelRadiatorSdb: json['towel_radiator_sdb'] as bool?,
        lightingScore: (json['lighting_score'] as num?)?.toInt(),
        waterPressureOk: json['water_pressure_ok'] as bool?,
        waterQualityScore: (json['water_quality_score'] as num?)?.toInt(),
        electricPanelOk: json['electric_panel_ok'] as bool?,
        earthGroundOk: json['earth_ground_ok'] as bool?,
        outletsScore: (json['outlets_score'] as num?)?.toInt(),
        mobileSignalOk: json['mobile_signal_ok'] as bool?,
        vmcOk: json['vmc_ok'] as bool?,
        kitchenWorktopScore: (json['kitchen_worktop_score'] as num?)?.toInt(),
        fridgeSpaceOk: json['fridge_space_ok'] as bool?,
        hoodOk: json['hood_ok'] as bool?,
        washingMachineSpace: json['washing_machine_space'] as bool?,
        departureReason: json['departure_reason'] as String?,
        availabilityDate: json['availability_date'] != null
            ? DateTime.tryParse(json['availability_date'] as String)
            : null,
        agencyFees: (json['agency_fees'] as num?)?.toDouble(),
        guaranteeDeposit: (json['guarantee_deposit'] as num?)?.toDouble(),
        landTax: (json['land_tax'] as num?)?.toDouble(),
        renovation: json['renovation'] != null
            ? RenovationAnswers.fromJson(
                json['renovation'] as Map<String, dynamic>)
            : null,
        liveIn2Years: json['live_in_2_years'] as bool?,
        chargesAmount: json['charges_amount'] as String?,
        exteriorSpaces: json['exterior_spaces'] as String?,
        elevatorSize: json['elevator_size'] as String?,
        parking: json['parking'] as bool?,
        buildingConcierge: json['building_concierge'] as bool?,
        radiatorLiving: json['radiator_living'] as bool?,
        radiatorBathroom: json['radiator_bathroom'] as bool?,
        radiatorBedroom: json['radiator_bedroom'] as bool?,
        heatingSystem: json['heating_system'] as String?,
        caveAccess: json['cave_access'] as bool?,
        caveDoor: json['cave_door'] as bool?,
        caveDry: json['cave_dry'] as bool?,
        bikeStorageSecured: json['bike_storage_secured'] as bool?,
        bikeStorageSpace: json['bike_storage_space'] as bool?,
        trashAccess: (json['trash_access'] as num?)?.toInt(),
        disabledAccess: json['disabled_access'] as bool?,
        dishwasherSpace: json['dishwasher_space'] as bool?,
        trashSpace: json['trash_space'] as bool?,
        kitchenOpenClosed: json['kitchen_open_closed'] as String?,
        vmcKitchen: json['vmc_kitchen'] as bool?,
        bathroomFeatures: json['bathroom_features'] as String?,
        outdoorSurface: json['outdoor_surface'] as String?,
        outdoorNeighborExposure: (json['outdoor_neighbor_exposure'] as num?)?.toInt(),
        outdoorSunExposure: (json['outdoor_sun_exposure'] as num?)?.toInt(),
        outdoorViewQuality: (json['outdoor_view_quality'] as num?)?.toInt(),
      );
}
