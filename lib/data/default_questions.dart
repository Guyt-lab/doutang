import '../models/enums.dart';
import '../models/question_template.dart';

// ── Constantes d'ID (stables entre versions) ─────────────────────────────────
// s1 — Transports & Quartier
const kQTransportMinutes = 'q_transport_minutes';
const kQTransportType = 'q_transport_type';
const kQMobilityServices = 'q_mobility_services';
const kQNoiseStreet = 'q_noise_street';
const kQNeighborhoodVibe = 'q_neighborhood_vibe';
const kQSafetyFeeling = 'q_safety_feeling';
const kQGreenSpaces = 'q_green_spaces';
const kQServicesProximity = 'q_services_proximity';

// s2 — Immeuble & Parties communes
const kQBuildingCondition = 'q_building_condition';
const kQCommonAreas = 'q_common_areas';
const kQElevatorPresent = 'q_elevator_present';
const kQElevatorOk = 'q_elevator_ok';
const kQCave = 'q_cave';
const kQBikeStorage = 'q_bike_storage';
const kQSecureDoor = 'q_secure_door';

// s3 — Luminosité & Vue
const kQLuminosityLiving = 'q_luminosity_living';
const kQLuminosityBedroom = 'q_luminosity_bedroom';
const kQExposure = 'q_exposure';
const kQVisAVis = 'q_vis_a_vis';
const kQVisitTime = 'q_visit_time';
const kQDoubleGlazing = 'q_double_glazing';

// s4 — Acoustique & Isolation
const kQPhonicsFloors = 'q_phonics_floors';
const kQPhonicsNeighbors = 'q_phonics_neighbors';
const kQPhonicsStreet = 'q_phonics_street';
const kQThermalInsulation = 'q_thermal_insulation';
const kQHumidityDetected = 'q_humidity_detected';
const kQHeatingDistribution = 'q_heating_distribution';

// s5 — État général & Équipements techniques
const kQGeneralState = 'q_general_state';
const kQFloorsState = 'q_floors_state';
const kQWallsState = 'q_walls_state';
const kQElectricPanel = 'q_electric_panel';
const kQEarthGround = 'q_earth_ground';
const kQOutlets = 'q_outlets';
const kQWaterPressure = 'q_water_pressure';
const kQWaterQuality = 'q_water_quality';
const kQMobileSignal = 'q_mobile_signal';
const kQVmc = 'q_vmc';

// s6 — Cuisine & Salle de bain
const kQKitchenLayout = 'q_kitchen_layout';
const kQKitchenWorktop = 'q_kitchen_worktop';
const kQKitchenStorage = 'q_kitchen_storage';
const kQKitchenHood = 'q_kitchen_hood';
const kQWashingMachineSpace = 'q_washing_machine_space';
const kQFridgeSpace = 'q_fridge_space';
const kQBathroomSize = 'q_bathroom_size';
const kQTowelRadiator = 'q_towel_radiator';

// s7 — Chambres & Espaces de vie
const kQLivingRoomSize = 'q_living_room_size';
const kQBedroomCount = 'q_bedroom_count';
const kQStorageSpace = 'q_storage_space';
const kQHallway = 'q_hallway';
const kQSeparateToilet = 'q_separate_toilet';
const kQBalconyTerrace = 'q_balcony_terrace';
const kQOutdoorQuality = 'q_outdoor_quality';

// s8 — Aspects pratiques & Administration
const kQRentPrice = 'q_rent_price';
const kQAgencyFees = 'q_agency_fees';
const kQDeposit = 'q_deposit';
const kQAvailability = 'q_availability';
const kQDepartureReason = 'q_departure_reason';
const kQChargesIncluded = 'q_charges_included';
const kQLandTax = 'q_land_tax';
const kQRenovationNeeded = 'q_renovation_needed';
const kQCoupDeCoeur = 'q_coup_de_coeur';
const kQPointRedhibitoire = 'q_point_redhibitoire';

/// Liste des 62 questions du questionnaire de visite par défaut.
///
/// Organisées par section (s1 à s8).
/// Les IDs sont stables — utiliser les constantes kQ* pour les références.
const List<QuestionTemplate> kDefaultQuestions = [
  // ── s1 : Transports & Quartier (8) ──────────────────────────────────────

  QuestionTemplate(
    id: kQTransportMinutes,
    section: 's1',
    text: 'Combien de minutes de trajet jusqu\'à votre lieu de travail ?',
    hint: 'Testez en conditions réelles (heure de pointe si possible)',
    level: QuestionLevel.critical,
    type: QuestionType.score,
    timing: QuestionTiming.avant,
  ),
  QuestionTemplate(
    id: kQTransportType,
    section: 's1',
    text: 'Quels moyens de transport avez-vous utilisés ?',
    hint: 'Métro, bus, vélo, voiture, à pied…',
    level: QuestionLevel.important,
    type: QuestionType.text,
    timing: QuestionTiming.avant,
  ),
  QuestionTemplate(
    id: kQMobilityServices,
    section: 's1',
    text: 'Y a-t-il des services de mobilité en libre-service à proximité ?',
    hint: 'Vélib, trottinettes, covoiturage…',
    level: QuestionLevel.nice,
    type: QuestionType.text,
    timing: QuestionTiming.avant,
  ),
  QuestionTemplate(
    id: kQNoiseStreet,
    section: 's1',
    text: 'Niveau sonore depuis la rue',
    hint: '5 = très calme, 1 = très bruyant',
    level: QuestionLevel.important,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
    withPhoto: false,
  ),
  QuestionTemplate(
    id: kQNeighborhoodVibe,
    section: 's1',
    text: 'Ambiance générale du quartier',
    hint: 'Dynamisme, propreté, mixité, convivialité',
    level: QuestionLevel.important,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQSafetyFeeling,
    section: 's1',
    text: 'Sentiment de sécurité dans le quartier',
    hint: '5 = très rassurant, 1 = préoccupant',
    level: QuestionLevel.important,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQGreenSpaces,
    section: 's1',
    text: 'Espaces verts accessibles à pied',
    hint: 'Parcs, squares, jardins…',
    level: QuestionLevel.nice,
    type: QuestionType.score,
    timing: QuestionTiming.avant,
  ),
  QuestionTemplate(
    id: kQServicesProximity,
    section: 's1',
    text: 'Commerces et services à proximité',
    hint: 'Supérette, pharmacie, médecin, école…',
    level: QuestionLevel.important,
    type: QuestionType.score,
    timing: QuestionTiming.avant,
  ),

  // ── s2 : Immeuble & Parties communes (7) ────────────────────────────────

  QuestionTemplate(
    id: kQBuildingCondition,
    section: 's2',
    text: 'État général de l\'immeuble',
    hint: 'Façade, hall, boîtes aux lettres, interphone',
    level: QuestionLevel.important,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
    withPhoto: true,
  ),
  QuestionTemplate(
    id: kQCommonAreas,
    section: 's2',
    text: 'État et propreté des parties communes',
    hint: 'Couloirs, escaliers, ascenseur',
    level: QuestionLevel.important,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
    withPhoto: true,
  ),
  QuestionTemplate(
    id: kQElevatorPresent,
    section: 's2',
    text: 'Y a-t-il un ascenseur dans l\'immeuble ?',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.avant,
  ),
  QuestionTemplate(
    id: kQElevatorOk,
    section: 's2',
    text: 'L\'ascenseur est-il en bon état de fonctionnement ?',
    level: QuestionLevel.nice,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQCave,
    section: 's2',
    text: 'Y a-t-il une cave incluse ?',
    level: QuestionLevel.nice,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQBikeStorage,
    section: 's2',
    text: 'Y a-t-il un local vélos sécurisé ?',
    level: QuestionLevel.nice,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQSecureDoor,
    section: 's2',
    text: 'Porte d\'entrée sécurisée (digicode ou interphone) ?',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.avant,
  ),

  // ── s3 : Luminosité & Vue (6) ────────────────────────────────────────────

  QuestionTemplate(
    id: kQLuminosityLiving,
    section: 's3',
    text: 'Luminosité naturelle du séjour',
    hint: '5 = baigné de lumière, 1 = très sombre',
    level: QuestionLevel.critical,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
    withPhoto: true,
  ),
  QuestionTemplate(
    id: kQLuminosityBedroom,
    section: 's3',
    text: 'Luminosité naturelle des chambres',
    hint: '5 = excellente, 1 = insuffisante',
    level: QuestionLevel.important,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
    withPhoto: true,
  ),
  QuestionTemplate(
    id: kQExposure,
    section: 's3',
    text: 'Orientation principale du logement',
    hint: 'Sud, Sud-Ouest, Est, Nord… Précisez',
    level: QuestionLevel.important,
    type: QuestionType.text,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQVisAVis,
    section: 's3',
    text: 'Vis-à-vis depuis les fenêtres principales',
    hint: '5 = aucun vis-à-vis, 1 = très exposé',
    level: QuestionLevel.important,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQVisitTime,
    section: 's3',
    text: 'À quelle heure avez-vous visité ?',
    hint: 'Important pour interpréter la luminosité',
    level: QuestionLevel.important,
    type: QuestionType.text,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQDoubleGlazing,
    section: 's3',
    text: 'Double vitrage aux fenêtres ?',
    hint: 'Vérifiez en frappant sur la vitre',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
  ),

  // ── s4 : Acoustique & Isolation (6) ─────────────────────────────────────

  QuestionTemplate(
    id: kQPhonicsFloors,
    section: 's4',
    text: 'Isolation phonique entre les étages',
    hint: '5 = excellent, 1 = on entend tout',
    level: QuestionLevel.important,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQPhonicsNeighbors,
    section: 's4',
    text: 'Bruits de voisinage perceptibles',
    hint: '5 = silencieux, 1 = bruyant',
    level: QuestionLevel.important,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQPhonicsStreet,
    section: 's4',
    text: 'Bruits de la rue à l\'intérieur',
    hint: '5 = inaudible, 1 = très présent',
    level: QuestionLevel.critical,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQThermalInsulation,
    section: 's4',
    text: 'Isolation thermique ressentie',
    hint: 'Courants d\'air, froid, condensation',
    level: QuestionLevel.important,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQHumidityDetected,
    section: 's4',
    text: 'Signes d\'humidité ou taches d\'humidité ?',
    hint: 'Regardez les angles, derrière les meubles, plafond SdB',
    level: QuestionLevel.critical,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
    withPhoto: true,
  ),
  QuestionTemplate(
    id: kQHeatingDistribution,
    section: 's4',
    text: 'Homogénéité du chauffage dans toutes les pièces',
    hint: '5 = parfaitement uniforme, 1 = très inégal',
    level: QuestionLevel.important,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
  ),

  // ── s5 : État général & Équipements techniques (10) ─────────────────────

  QuestionTemplate(
    id: kQGeneralState,
    section: 's5',
    text: 'État général de l\'appartement',
    hint: 'Vue d\'ensemble : propreté, finitions, fraîcheur',
    level: QuestionLevel.critical,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
    withPhoto: true,
  ),
  QuestionTemplate(
    id: kQFloorsState,
    section: 's5',
    text: 'État des sols',
    hint: 'Rayures, gonflements, décollement…',
    level: QuestionLevel.important,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
    withPhoto: true,
  ),
  QuestionTemplate(
    id: kQWallsState,
    section: 's5',
    text: 'État des murs et plafonds',
    hint: 'Fissures, traces, peinture écaillée',
    level: QuestionLevel.important,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
    withPhoto: true,
  ),
  QuestionTemplate(
    id: kQElectricPanel,
    section: 's5',
    text: 'Tableau électrique en bon état ?',
    hint: 'Disjoncteurs identifiés, pas de bricolage visible',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
    withPhoto: true,
  ),
  QuestionTemplate(
    id: kQEarthGround,
    section: 's5',
    text: 'Présence d\'une prise de terre ?',
    hint: 'Testez avec un détecteur ou regardez les prises (3 trous)',
    level: QuestionLevel.nice,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQOutlets,
    section: 's5',
    text: 'Nombre et qualité des prises électriques',
    hint: '5 = nombreuses et bien placées, 1 = insuffisant',
    level: QuestionLevel.important,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQWaterPressure,
    section: 's5',
    text: 'Pression d\'eau suffisante ?',
    hint: 'Ouvrez les robinets, testez la douche',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQWaterQuality,
    section: 's5',
    text: 'Qualité de l\'eau (goût, dureté)',
    hint: '5 = excellente, 1 = très calcaire ou mauvais goût',
    level: QuestionLevel.nice,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQMobileSignal,
    section: 's5',
    text: 'Bon signal mobile dans l\'appartement ?',
    hint: 'Testez dans les pièces les plus enclavées',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQVmc,
    section: 's5',
    text: 'VMC / ventilation présente et fonctionnelle ?',
    hint: 'Aérations dans SdB, cuisine, WC',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
  ),

  // ── s6 : Cuisine & Salle de bain (8) ────────────────────────────────────

  QuestionTemplate(
    id: kQKitchenLayout,
    section: 's6',
    text: 'Configuration et espace de la cuisine',
    hint: 'Superficie, circulation, ergonomie',
    level: QuestionLevel.important,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
    withPhoto: true,
  ),
  QuestionTemplate(
    id: kQKitchenWorktop,
    section: 's6',
    text: 'Plans de travail suffisants',
    hint: '5 = très généreux, 1 = quasi inexistant',
    level: QuestionLevel.important,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQKitchenStorage,
    section: 's6',
    text: 'Rangements cuisine (placards, tiroirs)',
    hint: '5 = très bon, 1 = insuffisant',
    level: QuestionLevel.important,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQKitchenHood,
    section: 's6',
    text: 'Hotte aspirante présente ?',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQWashingMachineSpace,
    section: 's6',
    text: 'Place pour un lave-linge ?',
    hint: 'En cuisine, SdB ou cellier',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQFridgeSpace,
    section: 's6',
    text: 'Place pour un réfrigérateur de taille correcte ?',
    level: QuestionLevel.nice,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQBathroomSize,
    section: 's6',
    text: 'Taille et fonctionnalité de la salle de bain',
    hint: '5 = spacieuse et bien agencée, 1 = exiguë',
    level: QuestionLevel.important,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
    withPhoto: true,
  ),
  QuestionTemplate(
    id: kQTowelRadiator,
    section: 's6',
    text: 'Sèche-serviettes dans la salle de bain ?',
    level: QuestionLevel.nice,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
  ),

  // ── s7 : Chambres & Espaces de vie (7) ──────────────────────────────────

  QuestionTemplate(
    id: kQLivingRoomSize,
    section: 's7',
    text: 'Taille et confort du salon / séjour',
    hint: '5 = grand et agréable, 1 = trop petit',
    level: QuestionLevel.critical,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
    withPhoto: true,
  ),
  QuestionTemplate(
    id: kQBedroomCount,
    section: 's7',
    text: 'Nombre et taille des chambres',
    hint: '5 = nombreuses et spacieuses, 1 = insuffisant',
    level: QuestionLevel.critical,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
    withPhoto: true,
  ),
  QuestionTemplate(
    id: kQStorageSpace,
    section: 's7',
    text: 'Espaces de rangement (placards, dressing)',
    hint: '5 = excellent, 1 = quasi inexistant',
    level: QuestionLevel.important,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQHallway,
    section: 's7',
    text: 'Présence d\'un couloir ou hall d\'entrée ?',
    hint: 'Limite les nuisances acoustiques et visuelles',
    level: QuestionLevel.nice,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQSeparateToilet,
    section: 's7',
    text: 'WC séparés de la salle de bain ?',
    level: QuestionLevel.nice,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQBalconyTerrace,
    section: 's7',
    text: 'Balcon, terrasse ou jardin ?',
    level: QuestionLevel.nice,
    type: QuestionType.yesNo,
    timing: QuestionTiming.avant,
  ),
  QuestionTemplate(
    id: kQOutdoorQuality,
    section: 's7',
    text: 'Qualité de l\'espace extérieur',
    hint: '5 = grand et agréable, 1 = petit ou peu pratique',
    level: QuestionLevel.nice,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
    withPhoto: true,
  ),

  // ── s8 : Aspects pratiques & Administration (10) ────────────────────────

  QuestionTemplate(
    id: kQRentPrice,
    section: 's8',
    text: 'Loyer mensuel (charges comprises ou non) ?',
    hint: 'Précisez si CC ou HC',
    level: QuestionLevel.critical,
    type: QuestionType.text,
    timing: QuestionTiming.avant,
    appliesTo: [ProjectFilter.location],
  ),
  QuestionTemplate(
    id: kQAgencyFees,
    section: 's8',
    text: 'Montant des honoraires d\'agence ?',
    hint: 'En €, plafonné par la loi Alur',
    level: QuestionLevel.important,
    type: QuestionType.text,
    timing: QuestionTiming.avant,
    appliesTo: [ProjectFilter.location],
  ),
  QuestionTemplate(
    id: kQDeposit,
    section: 's8',
    text: 'Caution demandée ?',
    hint: 'Maximum 2 mois de loyer HC pour une location vide',
    level: QuestionLevel.important,
    type: QuestionType.text,
    timing: QuestionTiming.avant,
    appliesTo: [ProjectFilter.location],
  ),
  QuestionTemplate(
    id: kQAvailability,
    section: 's8',
    text: 'Date de disponibilité ?',
    hint: 'Préavis en cours, logement libre…',
    level: QuestionLevel.important,
    type: QuestionType.text,
    timing: QuestionTiming.avant,
  ),
  QuestionTemplate(
    id: kQDepartureReason,
    section: 's8',
    text: 'Raison du départ du locataire / vendeur précédent ?',
    hint: 'Révèle parfois des problèmes cachés',
    level: QuestionLevel.important,
    type: QuestionType.text,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQChargesIncluded,
    section: 's8',
    text: 'Les charges sont-elles incluses dans le loyer ?',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.avant,
    appliesTo: [ProjectFilter.location],
  ),
  QuestionTemplate(
    id: kQLandTax,
    section: 's8',
    text: 'Taxe foncière annuelle ?',
    hint: 'Demandez la dernière quittance au vendeur',
    level: QuestionLevel.important,
    type: QuestionType.text,
    timing: QuestionTiming.avant,
    appliesTo: [ProjectFilter.achat],
  ),
  QuestionTemplate(
    id: kQRenovationNeeded,
    section: 's8',
    text: 'Importance des travaux à prévoir',
    hint: '5 = clé en main, 1 = gros chantier',
    level: QuestionLevel.important,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQCoupDeCoeur,
    section: 's8',
    text: 'Coup de cœur : qu\'est-ce qui vous a le plus séduit ?',
    hint: 'Ce que vous retiendrez longtemps',
    level: QuestionLevel.nice,
    type: QuestionType.text,
    timing: QuestionTiming.apres,
  ),
  QuestionTemplate(
    id: kQPointRedhibitoire,
    section: 's8',
    text: 'Point rédhibitoire : qu\'est-ce qui vous a bloqué ?',
    hint: 'Le défaut qui pèse le plus dans la balance',
    level: QuestionLevel.critical,
    type: QuestionType.text,
    timing: QuestionTiming.apres,
  ),
];

// 62 questions total : s1×8 + s2×7 + s3×6 + s4×6 + s5×10 + s6×8 + s7×7 + s8×10
