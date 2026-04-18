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
const kQElevatorSize = 'q_elevator_size';
const kQCave = 'q_cave';
const kQCaveAccess = 'q_cave_access';
const kQCaveDoor = 'q_cave_door';
const kQCaveDry = 'q_cave_dry';
const kQBikeStorage = 'q_bike_storage';
const kQBikeStorageSecured = 'q_bike_storage_secured';
const kQBikeStorageSpace = 'q_bike_storage_space';
const kQParking = 'q_parking';
const kQTrashAccess = 'q_trash_access';
const kQDisabledAccess = 'q_disabled_access';
const kQSecureDoor = 'q_secure_door';
const kQBuildingConcierge = 'q_building_concierge';

// s3 — Luminosité & Vue
const kQLuminosityLiving = 'q_luminosity_living';
const kQLuminosityBedroom = 'q_luminosity_bedroom';
const kQExposure = 'q_exposure';
const kQVisAVis = 'q_vis_a_vis';
const kQVisitTime = 'q_visit_time'; // conservé pour rétrocompat

// s4 — Acoustique & Isolation
const kQPhonicsFloors = 'q_phonics_floors';
const kQPhonicsNeighbors = 'q_phonics_neighbors';
const kQPhonicsStreet = 'q_phonics_street';
const kQThermalInsulation = 'q_thermal_insulation';
const kQHumidityDetected = 'q_humidity_detected';
const kQDoubleGlazing = 'q_double_glazing';

// s5 — État général
const kQGeneralState = 'q_general_state';
const kQFloorsState = 'q_floors_state';
const kQWallsState = 'q_walls_state';

// s_living — Pièce à vivre / Salon
const kQLivingRoomSize = 'q_living_room_size';
const kQHallway = 'q_hallway';
const kQSeparateToilet = 'q_separate_toilet';
const kQRadiatorLiving = 'q_radiator_living';

// s_kitchen — Cuisine
const kQKitchenLayout = 'q_kitchen_layout';
const kQKitchenOpenClosed = 'q_kitchen_open_closed';
const kQKitchenWorktop = 'q_kitchen_worktop';
const kQKitchenStorage = 'q_kitchen_storage';
const kQKitchenHood = 'q_kitchen_hood';
const kQWashingMachineSpace = 'q_washing_machine_space';
const kQDishwasherSpace = 'q_dishwasher_space';
const kQFridgeSpace = 'q_fridge_space';
const kQTrashSpace = 'q_trash_space';
const kQVmcKitchen = 'q_vmc_kitchen';

// s_bathroom — Salle de bain
const kQBathroomSize = 'q_bathroom_size';
const kQBathroomFeatures = 'q_bathroom_features';
const kQTowelRadiator = 'q_towel_radiator';
const kQRadiatorBathroom = 'q_radiator_bathroom';

// s_bedrooms — Chambres
const kQBedroomCount = 'q_bedroom_count';
const kQStorageSpace = 'q_storage_space';
const kQRadiatorBedroom = 'q_radiator_bedroom';

// s_elec — Électricité
const kQElectricPanel = 'q_electric_panel';
const kQEarthGround = 'q_earth_ground';
const kQOutlets = 'q_outlets';
const kQMobileSignal = 'q_mobile_signal';

// s_heating — Chauffage
const kQHeatingSystem = 'q_heating_system';
const kQHeatingDistribution = 'q_heating_distribution'; // conservé rétrocompat

// s_water — Eau
const kQWaterPressure = 'q_water_pressure';
const kQWaterQuality = 'q_water_quality';
const kQVmc = 'q_vmc';

// s7 — Espaces extérieurs (visite)
const kQBalconyTerrace = 'q_balcony_terrace'; // conservé rétrocompat
const kQOutdoorSurface = 'q_outdoor_surface';
const kQOutdoorNeighborExposure = 'q_outdoor_neighbor_exposure';
const kQOutdoorSunExposure = 'q_outdoor_sun_exposure';
const kQOutdoorViewQuality = 'q_outdoor_view_quality';

// s8 — Aspects pratiques & Administration
const kQRentPrice = 'q_rent_price';
const kQChargesIncluded = 'q_charges_included';
const kQChargesAmount = 'q_charges_amount';
const kQAgencyFees = 'q_agency_fees';
const kQDeposit = 'q_deposit';
const kQAvailability = 'q_availability';
const kQDepartureReason = 'q_departure_reason';
const kQLandTax = 'q_land_tax';
const kQRenovationNeeded = 'q_renovation_needed';
const kQCoupDeCoeur = 'q_coup_de_coeur';
const kQPointRedhibitoire = 'q_point_redhibitoire';

const List<QuestionTemplate> kDefaultQuestions = [

  // ── s1 : Transports & Quartier ────────────────────────────────────────────

  QuestionTemplate(
    id: kQTransportMinutes,
    section: 's1',
    text: 'Proximité des transports',
    hint: '5 = station à moins de 5 min à pied, 1 = très éloigné',
    level: QuestionLevel.critical,
    type: QuestionType.score,
    timing: QuestionTiming.avant,
  ),
  QuestionTemplate(
    id: kQTransportType,
    section: 's1',
    text: 'Moyens de transports à proximité',
    level: QuestionLevel.important,
    type: QuestionType.multiChoice,
    timing: QuestionTiming.avant,
    options: ['Métro', 'RER', 'Train', 'Bus', 'Tramway', 'Vélo'],
  ),
  QuestionTemplate(
    id: kQMobilityServices,
    section: 's1',
    text: 'Services de mobilité disponibles à proximité',
    level: QuestionLevel.nice,
    type: QuestionType.multiChoice,
    timing: QuestionTiming.avant,
    options: ['Vélib', 'Trottinette', 'Scooter'],
  ),
  QuestionTemplate(
    id: kQNoiseStreet,
    section: 's1',
    text: 'Niveau sonore depuis la rue',
    hint: '5 = très calme, 1 = très bruyant',
    level: QuestionLevel.important,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
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

  // ── s2 : Immeuble & Parties communes ─────────────────────────────────────

  QuestionTemplate(
    id: kQElevatorPresent,
    section: 's2',
    text: 'Y a-t-il un ascenseur dans l\'immeuble ?',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.avant,
    appliesTo: [ProjectFilter.appartement],
  ),
  QuestionTemplate(
    id: kQCave,
    section: 's2',
    text: 'Y a-t-il une cave incluse ?',
    level: QuestionLevel.nice,
    type: QuestionType.yesNo,
    timing: QuestionTiming.avant,
  ),
  QuestionTemplate(
    id: kQBikeStorage,
    section: 's2',
    text: 'Y a-t-il un local vélos sécurisé ?',
    level: QuestionLevel.nice,
    type: QuestionType.yesNo,
    timing: QuestionTiming.avant,
    appliesTo: [ProjectFilter.appartement],
  ),
  QuestionTemplate(
    id: kQParking,
    section: 's2',
    text: 'Y a-t-il un parking ?',
    hint: 'Box, place en sous-sol, parking extérieur…',
    level: QuestionLevel.nice,
    type: QuestionType.yesNo,
    timing: QuestionTiming.avant,
  ),
  QuestionTemplate(
    id: kQSecureDoor,
    section: 's2',
    text: 'Porte d\'entrée d\'immeuble sécurisée (digicode ou interphone) ?',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.avant,
    appliesTo: [ProjectFilter.appartement],
  ),
  QuestionTemplate(
    id: kQBuildingConcierge,
    section: 's2',
    text: 'Y a-t-il un gardien ?',
    level: QuestionLevel.nice,
    type: QuestionType.yesNo,
    timing: QuestionTiming.avant,
    appliesTo: [ProjectFilter.appartement],
  ),
  QuestionTemplate(
    id: kQBuildingCondition,
    section: 's2',
    text: 'État général de l\'immeuble',
    hint: 'Façade, hall, boîtes aux lettres, interphone',
    level: QuestionLevel.important,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
    withPhoto: true,
    appliesTo: [ProjectFilter.appartement],
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
    appliesTo: [ProjectFilter.appartement],
  ),
  QuestionTemplate(
    id: kQElevatorOk,
    section: 's2',
    text: 'L\'ascenseur est-il en bon état de fonctionnement ?',
    level: QuestionLevel.nice,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
    appliesTo: [ProjectFilter.appartement],
  ),
  QuestionTemplate(
    id: kQElevatorSize,
    section: 's2',
    text: 'Taille de l\'ascenseur ?',
    level: QuestionLevel.nice,
    type: QuestionType.multiChoice,
    timing: QuestionTiming.pendant,
    options: ['Petit', 'Moyen', 'Grand'],
    appliesTo: [ProjectFilter.appartement],
  ),
  QuestionTemplate(
    id: kQCaveAccess,
    section: 's2',
    text: 'Accès à la cave sécurisé (clé / badge) ?',
    level: QuestionLevel.nice,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
    appliesTo: [ProjectFilter.appartement],
  ),
  QuestionTemplate(
    id: kQCaveDoor,
    section: 's2',
    text: 'Porte de cave sécurisée ?',
    level: QuestionLevel.nice,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
    appliesTo: [ProjectFilter.appartement],
  ),
  QuestionTemplate(
    id: kQCaveDry,
    section: 's2',
    text: 'Cave sèche (pas d\'humidité) ?',
    level: QuestionLevel.nice,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
    appliesTo: [ProjectFilter.appartement],
  ),
  QuestionTemplate(
    id: kQBikeStorageSecured,
    section: 's2',
    text: 'Local à vélos sécurisé ?',
    level: QuestionLevel.nice,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
    appliesTo: [ProjectFilter.appartement],
  ),
  QuestionTemplate(
    id: kQBikeStorageSpace,
    section: 's2',
    text: 'Place disponible dans le local à vélos ?',
    level: QuestionLevel.nice,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
    appliesTo: [ProjectFilter.appartement],
  ),
  QuestionTemplate(
    id: kQTrashAccess,
    section: 's2',
    text: 'Accès au local poubelle',
    hint: '5 = très accessible et propre, 1 = difficile d\'accès',
    level: QuestionLevel.nice,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
    appliesTo: [ProjectFilter.appartement],
  ),
  QuestionTemplate(
    id: kQDisabledAccess,
    section: 's2',
    text: 'Accès mobilité réduite à l\'immeuble ?',
    level: QuestionLevel.nice,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
    appliesTo: [ProjectFilter.appartement],
  ),

  // ── s3 : Luminosité & Vue ─────────────────────────────────────────────────

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

  // ── s4 : Acoustique & Isolation ───────────────────────────────────────────

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
    id: kQDoubleGlazing,
    section: 's4',
    text: 'Double vitrage aux fenêtres ?',
    hint: 'Vérifiez en frappant sur la vitre',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
  ),

  // ── s5 : État général ─────────────────────────────────────────────────────

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

  // ── s_living : Pièce à vivre / Salon ──────────────────────────────────────

  QuestionTemplate(
    id: kQLivingRoomSize,
    section: 's_living',
    text: 'Taille et confort du salon / séjour',
    hint: '5 = grand et agréable, 1 = trop petit',
    level: QuestionLevel.critical,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
    withPhoto: true,
  ),
  QuestionTemplate(
    id: kQHallway,
    section: 's_living',
    text: 'Présence d\'un couloir ou hall d\'entrée ?',
    hint: 'Limite les nuisances acoustiques et visuelles',
    level: QuestionLevel.nice,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQRadiatorLiving,
    section: 's_living',
    text: 'Présence d\'un radiateur dans le salon ?',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
  ),

  // ── s_kitchen : Cuisine ───────────────────────────────────────────────────

  QuestionTemplate(
    id: kQKitchenLayout,
    section: 's_kitchen',
    text: 'Configuration et espace de la cuisine',
    hint: 'Superficie, circulation, ergonomie',
    level: QuestionLevel.important,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
    withPhoto: true,
  ),
  QuestionTemplate(
    id: kQKitchenOpenClosed,
    section: 's_kitchen',
    text: 'Cuisine ouverte ou fermée ?',
    level: QuestionLevel.nice,
    type: QuestionType.multiChoice,
    timing: QuestionTiming.pendant,
    options: ['Ouverte', 'Semi-ouverte', 'Fermée'],
  ),
  QuestionTemplate(
    id: kQKitchenWorktop,
    section: 's_kitchen',
    text: 'Plans de travail suffisants',
    hint: '5 = très généreux, 1 = quasi inexistant',
    level: QuestionLevel.important,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQKitchenStorage,
    section: 's_kitchen',
    text: 'Rangements cuisine (placards, tiroirs)',
    hint: '5 = très bon, 1 = insuffisant',
    level: QuestionLevel.important,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQKitchenHood,
    section: 's_kitchen',
    text: 'Hotte aspirante présente ?',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQWashingMachineSpace,
    section: 's_kitchen',
    text: 'Place pour un lave-linge ?',
    hint: 'En cuisine, SdB ou cellier',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQFridgeSpace,
    section: 's_kitchen',
    text: 'Place pour un réfrigérateur de taille correcte ?',
    level: QuestionLevel.nice,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQDishwasherSpace,
    section: 's_kitchen',
    text: 'Place pour un lave-vaisselle ?',
    level: QuestionLevel.nice,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQTrashSpace,
    section: 's_kitchen',
    text: 'Place pour les poubelles de tri ?',
    level: QuestionLevel.nice,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQVmcKitchen,
    section: 's_kitchen',
    text: 'Ventilation / VMC en cuisine ?',
    hint: 'Hotte raccordée ou aération murale',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
  ),

  // ── s_bathroom : Salle de bain ────────────────────────────────────────────

  QuestionTemplate(
    id: kQBathroomSize,
    section: 's_bathroom',
    text: 'Taille et fonctionnalité de la salle de bain',
    hint: '5 = spacieuse et bien agencée, 1 = exiguë',
    level: QuestionLevel.important,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
    withPhoto: true,
  ),
  QuestionTemplate(
    id: kQBathroomFeatures,
    section: 's_bathroom',
    text: 'Équipements présents',
    level: QuestionLevel.important,
    type: QuestionType.multiChoice,
    timing: QuestionTiming.pendant,
    options: [
      'Douche',
      'Douche italienne',
      'Baignoire',
      'Vasque unique',
      'Double vasque',
      'WC',
      'Présence VMC',
      'Présence fenêtre',
    ],
  ),
  QuestionTemplate(
    id: kQSeparateToilet,
    section: 's_bathroom',
    text: 'WC séparés de la salle de bain ?',
    level: QuestionLevel.nice,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQTowelRadiator,
    section: 's_bathroom',
    text: 'Sèche-serviettes dans la salle de bain ?',
    level: QuestionLevel.nice,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQRadiatorBathroom,
    section: 's_bathroom',
    text: 'Présence d\'un radiateur dans la salle de bain ?',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
  ),

  // ── s_bedrooms : Chambres ─────────────────────────────────────────────────

  QuestionTemplate(
    id: kQBedroomCount,
    section: 's_bedrooms',
    text: 'Nombre et taille des chambres',
    hint: '5 = nombreuses et spacieuses, 1 = insuffisant',
    level: QuestionLevel.critical,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
    withPhoto: true,
  ),
  QuestionTemplate(
    id: kQStorageSpace,
    section: 's_bedrooms',
    text: 'Espaces de rangement (placards, dressing)',
    hint: '5 = excellent, 1 = quasi inexistant',
    level: QuestionLevel.important,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQRadiatorBedroom,
    section: 's_bedrooms',
    text: 'Présence d\'un radiateur dans les chambres ?',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
  ),

  // ── s_elec : Électricité ──────────────────────────────────────────────────

  QuestionTemplate(
    id: kQElectricPanel,
    section: 's_elec',
    text: 'Tableau électrique en bon état ?',
    hint: 'Disjoncteurs identifiés, pas de bricolage visible',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
    withPhoto: true,
  ),
  QuestionTemplate(
    id: kQEarthGround,
    section: 's_elec',
    text: 'Présence d\'une prise de terre ?',
    hint: 'Testez avec un détecteur ou regardez les prises (3 trous)',
    level: QuestionLevel.nice,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQOutlets,
    section: 's_elec',
    text: 'Nombre et qualité des prises électriques',
    hint: '5 = nombreuses et bien placées, 1 = insuffisant',
    level: QuestionLevel.important,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQMobileSignal,
    section: 's_elec',
    text: 'Bon signal mobile dans l\'appartement ?',
    hint: 'Testez dans les pièces les plus enclavées',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
  ),

  // ── s_heating : Chauffage ─────────────────────────────────────────────────

  QuestionTemplate(
    id: kQHeatingSystem,
    section: 's_heating',
    text: 'Type et mode de chauffage',
    level: QuestionLevel.important,
    type: QuestionType.multiChoice,
    timing: QuestionTiming.pendant,
    options: [
      'Gaz individuel',
      'Gaz collectif',
      'Électrique',
      'Pompe à chaleur',
      'Plancher chauffant',
      'Poêle',
      'Climatisation réversible',
    ],
  ),

  // ── s_water : Eau ─────────────────────────────────────────────────────────

  QuestionTemplate(
    id: kQWaterPressure,
    section: 's_water',
    text: 'Pression d\'eau suffisante ?',
    hint: 'Ouvrez les robinets, testez la douche',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQWaterQuality,
    section: 's_water',
    text: 'Qualité de l\'eau (goût, dureté)',
    hint: '5 = excellente, 1 = très calcaire ou mauvais goût',
    level: QuestionLevel.nice,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
  ),

  // ── s7 : Espaces extérieurs (visite) ──────────────────────────────────────

  QuestionTemplate(
    id: kQOutdoorSurface,
    section: 's7',
    text: 'Superficie de l\'espace extérieur',
    hint: 'En m²',
    level: QuestionLevel.important,
    type: QuestionType.text,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQOutdoorNeighborExposure,
    section: 's7',
    text: 'Exposé aux voisins',
    hint: '5 = très intimiste, 1 = très exposé',
    level: QuestionLevel.important,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
  ),
  QuestionTemplate(
    id: kQOutdoorSunExposure,
    section: 's7',
    text: 'Exposition au soleil',
    hint: '5 = très ensoleillé, 1 = à l\'ombre toute la journée',
    level: QuestionLevel.important,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
    withPhoto: true,
  ),
  QuestionTemplate(
    id: kQOutdoorViewQuality,
    section: 's7',
    text: 'Qualité de la vue',
    hint: '5 = vue dégagée et agréable, 1 = vue sur un mur ou rue',
    level: QuestionLevel.nice,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
    withPhoto: true,
  ),

  // ── s8 : Aspects pratiques & Administration ───────────────────────────────

  QuestionTemplate(
    id: kQRentPrice,
    section: 's8',
    text: 'Loyer mensuel',
    hint: 'En €',
    level: QuestionLevel.critical,
    type: QuestionType.text,
    timing: QuestionTiming.avant,
    appliesTo: [ProjectFilter.location],
  ),
  QuestionTemplate(
    id: kQChargesIncluded,
    section: 's8',
    text: 'Charges comprises ?',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.avant,
    appliesTo: [ProjectFilter.location],
  ),
  QuestionTemplate(
    id: kQChargesAmount,
    section: 's8',
    text: 'Montant des charges',
    hint: 'En € / mois',
    level: QuestionLevel.important,
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
    id: kQDepartureReason,
    section: 's8',
    text: 'Raison du départ du locataire / vendeur précédent ?',
    hint: 'Révèle parfois des problèmes cachés',
    level: QuestionLevel.important,
    type: QuestionType.text,
    timing: QuestionTiming.pendant,
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
