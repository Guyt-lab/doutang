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

// s1 — Transports (conditionnel)
const kQTransportStations = 'q_transport_stations';

// s8 — Administration complémentaire
const kQTaxeHabitation = 'q_taxe_habitation';
const kQCoproprietieMaison = 'q_copropriete_maison';

// s_facade — Extérieur & Structure (maison)
const kQFacadeFissures = 'q_facade_fissures';
const kQSolAffaissement = 'q_sol_affaissement';
const kQMursDeformation = 'q_murs_deformation';
const kQHumiditeExterieure = 'q_humidite_exterieure';

// s_toiture — Toiture (maison)
const kQToitureTuiles = 'q_toiture_tuiles';
const kQGoutieres = 'q_goutieres';
const kQCharpente = 'q_charpente';
const kQIsolationToiture = 'q_isolation_toiture';
const kQToitureRenovation = 'q_toiture_renovation';

// s_drainage — Drainage & Eau (maison)
const kQTerrainPente = 'q_terrain_pente';
const kQEauStagnante = 'q_eau_stagnante';
const kQDrains = 'q_drains';
const kQTracesInondation = 'q_traces_inondation';

// s_terrain — Terrain & Environnement (maison)
const kQTerrainVoisinsProximite = 'q_terrain_voisins_proximite';
const kQIncidentsVoisins = 'q_incidents_voisins';
const kQArbresProches = 'q_arbres_proches';
const kQOrientationTerrain = 'q_orientation_terrain';
const kQNuisancesTerrain = 'q_nuisances_terrain';

// s_urbanisme — Urbanisme (maison, apres)
const kQProjetsConstruction = 'q_projets_construction';
const kQPlu = 'q_plu';
const kQTerrainsConstructibles = 'q_terrains_constructibles';

// s_raccordements — Raccordements (maison)
const kQRaccordementEauElecGaz = 'q_raccordement_eau_elec_gaz';
const kQToutALegout = 'q_tout_a_legout';
const kQFibreMaison = 'q_fibre_maison';
const kQBranchementsEtat = 'q_branchements_etat';

// s_facade_ext — Façade & Isolation extérieure (maison)
const kQCrepiEtat = 'q_crepi_etat';
const kQFacadeHumidite = 'q_facade_humidite';
const kQIte = 'q_ite';

// s_acces — Accès & Stationnement (maison)
const kQAccesRoute = 'q_acces_route';
const kQStationnementMaison = 'q_stationnement_maison';
const kQServitudes = 'q_servitudes';

// s_risques — Risques naturels (maison, apres)
const kQErpConsulte = 'q_erp_consulte';
const kQRisqueInondation = 'q_risque_inondation';
const kQRisqueGlissement = 'q_risque_glissement';
const kQPollutionSols = 'q_pollution_sols';
const kQNuisancesEnvironnement = 'q_nuisances_environnement';

// s_diagnostics — Diagnostics techniques (achat + appartement, apres)
const kQRavelementDate = 'q_ravalement_date';
const kQTravauxVotes = 'q_travaux_votes';
const kQProceduresCopro = 'q_procedures_copro';
const kQEvacuationsCommunes = 'q_evacuations_communes';
const kQFibreImmeuble = 'q_fibre_immeuble';
const kQDpeNiveau = 'q_dpe_niveau';
const kQElecAge = 'q_elec_age';
const kQDiagElec = 'q_diag_elec';
const kQGazAge = 'q_gaz_age';
const kQDiagGaz = 'q_diag_gaz';
const kQDateConstruction = 'q_date_construction';
const kQDiagAmiante = 'q_diag_amiante';
const kQDiagPlomb = 'q_diag_plomb';

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

  // ── s_facade : Extérieur & Structure ─────────────────────────────────────

  QuestionTemplate(
    id: kQFacadeFissures,
    section: 's_facade',
    text: 'Présence de fissures en façade ?',
    level: QuestionLevel.critical,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
    withPhoto: true,
    appliesTo: [ProjectFilter.maison],
  ),
  QuestionTemplate(
    id: kQSolAffaissement,
    section: 's_facade',
    text: 'Affaissement du sol ou de la maison visible ?',
    level: QuestionLevel.critical,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
    withPhoto: true,
    appliesTo: [ProjectFilter.maison],
  ),
  QuestionTemplate(
    id: kQMursDeformation,
    section: 's_facade',
    text: 'Déformation des murs ou de la façade ?',
    level: QuestionLevel.critical,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
    withPhoto: true,
    appliesTo: [ProjectFilter.maison],
  ),
  QuestionTemplate(
    id: kQHumiditeExterieure,
    section: 's_facade',
    text: 'Traces d\'humidité extérieure ?',
    level: QuestionLevel.critical,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
    withPhoto: true,
    appliesTo: [ProjectFilter.maison],
  ),

  // ── s_toiture : Toiture ───────────────────────────────────────────────────

  QuestionTemplate(
    id: kQToitureTuiles,
    section: 's_toiture',
    text: 'État des tuiles/ardoises (cassées, mousse) ?',
    hint: '5 = parfait état, 1 = remplacement urgent',
    level: QuestionLevel.critical,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
    withPhoto: true,
    appliesTo: [ProjectFilter.maison],
  ),
  QuestionTemplate(
    id: kQGoutieres,
    section: 's_toiture',
    text: 'Gouttières en bon état (fuites, écoulement) ?',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
    appliesTo: [ProjectFilter.maison],
  ),
  QuestionTemplate(
    id: kQCharpente,
    section: 's_toiture',
    text: 'Charpente visible et en bon état ?',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
    appliesTo: [ProjectFilter.maison],
  ),
  QuestionTemplate(
    id: kQIsolationToiture,
    section: 's_toiture',
    text: 'Isolation sous toiture présente ?',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
    appliesTo: [ProjectFilter.maison],
  ),
  QuestionTemplate(
    id: kQToitureRenovation,
    section: 's_toiture',
    text: 'Rénovation toiture à prévoir ?',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
    appliesTo: [ProjectFilter.maison],
  ),

  // ── s_drainage : Drainage & Eau ───────────────────────────────────────────

  QuestionTemplate(
    id: kQTerrainPente,
    section: 's_drainage',
    text: 'Terrain en pente vers la maison ?',
    level: QuestionLevel.critical,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
    appliesTo: [ProjectFilter.maison],
  ),
  QuestionTemplate(
    id: kQEauStagnante,
    section: 's_drainage',
    text: 'Eau stagnante visible après pluie ?',
    level: QuestionLevel.critical,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
    appliesTo: [ProjectFilter.maison],
  ),
  QuestionTemplate(
    id: kQDrains,
    section: 's_drainage',
    text: 'Présence de drains ou caniveaux ?',
    level: QuestionLevel.nice,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
    appliesTo: [ProjectFilter.maison],
  ),
  QuestionTemplate(
    id: kQTracesInondation,
    section: 's_drainage',
    text: 'Traces d\'inondation ou remontées d\'eau ?',
    level: QuestionLevel.critical,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
    withPhoto: true,
    appliesTo: [ProjectFilter.maison],
  ),

  // ── s_terrain : Terrain & Environnement ──────────────────────────────────

  QuestionTemplate(
    id: kQTerrainVoisinsProximite,
    section: 's_terrain',
    text: 'Proximité des voisins (vis-à-vis) ?',
    hint: '5 = très intimiste, 1 = très exposé',
    level: QuestionLevel.important,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
    appliesTo: [ProjectFilter.maison],
  ),
  QuestionTemplate(
    id: kQIncidentsVoisins,
    section: 's_terrain',
    text: 'Incidents connus avec les voisins ?',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
    appliesTo: [ProjectFilter.maison],
  ),
  QuestionTemplate(
    id: kQArbresProches,
    section: 's_terrain',
    text: 'Arbres proches (racines, risque chute) ?',
    level: QuestionLevel.nice,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
    appliesTo: [ProjectFilter.maison],
  ),
  QuestionTemplate(
    id: kQOrientationTerrain,
    section: 's_terrain',
    text: 'Orientation et ensoleillement',
    hint: 'Sud, Sud-Ouest, Est, Nord…',
    level: QuestionLevel.important,
    type: QuestionType.text,
    timing: QuestionTiming.pendant,
    appliesTo: [ProjectFilter.maison],
  ),
  QuestionTemplate(
    id: kQNuisancesTerrain,
    section: 's_terrain',
    text: 'Nuisances sonores (route, train, bars)',
    hint: '5 = très calme, 1 = très bruyant',
    level: QuestionLevel.critical,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
    appliesTo: [ProjectFilter.maison],
  ),

  // ── s_raccordements : Raccordements ───────────────────────────────────────

  QuestionTemplate(
    id: kQRaccordementEauElecGaz,
    section: 's_raccordements',
    text: 'Eau, électricité, gaz raccordés ?',
    level: QuestionLevel.critical,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
    appliesTo: [ProjectFilter.maison],
  ),
  QuestionTemplate(
    id: kQToutALegout,
    section: 's_raccordements',
    text: 'Tout-à-l\'égout ou fosse septique ?',
    hint: 'Précisez le type et l\'état',
    level: QuestionLevel.critical,
    type: QuestionType.text,
    timing: QuestionTiming.pendant,
    appliesTo: [ProjectFilter.maison],
  ),
  QuestionTemplate(
    id: kQFibreMaison,
    section: 's_raccordements',
    text: 'Fibre internet disponible ?',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
    appliesTo: [ProjectFilter.maison],
  ),
  QuestionTemplate(
    id: kQBranchementsEtat,
    section: 's_raccordements',
    text: 'État des branchements visibles',
    hint: '5 = parfait état, 1 = vétuste',
    level: QuestionLevel.important,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
    appliesTo: [ProjectFilter.maison],
  ),

  // ── s_facade_ext : Façade & Isolation extérieure ──────────────────────────

  QuestionTemplate(
    id: kQCrepiEtat,
    section: 's_facade_ext',
    text: 'État du crépi ou des murs extérieurs',
    hint: '5 = impeccable, 1 = dégradé',
    level: QuestionLevel.important,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
    withPhoto: true,
    appliesTo: [ProjectFilter.maison],
  ),
  QuestionTemplate(
    id: kQFacadeHumidite,
    section: 's_facade_ext',
    text: 'Traces de fissures ou d\'humidité en façade',
    level: QuestionLevel.critical,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
    withPhoto: true,
    appliesTo: [ProjectFilter.maison],
  ),
  QuestionTemplate(
    id: kQIte,
    section: 's_facade_ext',
    text: 'Isolation thermique par l\'extérieur (ITE) présente ?',
    level: QuestionLevel.nice,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
    appliesTo: [ProjectFilter.maison],
  ),

  // ── s_acces : Accès & Stationnement ──────────────────────────────────────

  QuestionTemplate(
    id: kQAccesRoute,
    section: 's_acces',
    text: 'Facilité d\'accès (route étroite, pente) ?',
    hint: '5 = très accessible, 1 = difficile',
    level: QuestionLevel.important,
    type: QuestionType.score,
    timing: QuestionTiming.pendant,
    appliesTo: [ProjectFilter.maison],
  ),
  QuestionTemplate(
    id: kQStationnementMaison,
    section: 's_acces',
    text: 'Stationnement disponible (garage, rue) ?',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.pendant,
    appliesTo: [ProjectFilter.maison],
  ),
  QuestionTemplate(
    id: kQServitudes,
    section: 's_acces',
    text: 'Servitudes de passage éventuelles ?',
    level: QuestionLevel.nice,
    type: QuestionType.yesNo,
    timing: QuestionTiming.apres,
    appliesTo: [ProjectFilter.maison],
  ),

  // ── s_urbanisme : Urbanisme ───────────────────────────────────────────────

  QuestionTemplate(
    id: kQProjetsConstruction,
    section: 's_urbanisme',
    text: 'Projets de construction à proximité ?',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.apres,
    appliesTo: [ProjectFilter.maison],
  ),
  QuestionTemplate(
    id: kQPlu,
    section: 's_urbanisme',
    text: 'PLU consulté (Plan Local d\'Urbanisme) ?',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.apres,
    appliesTo: [ProjectFilter.maison],
  ),
  QuestionTemplate(
    id: kQTerrainsConstructibles,
    section: 's_urbanisme',
    text: 'Terrains constructibles autour ?',
    level: QuestionLevel.nice,
    type: QuestionType.yesNo,
    timing: QuestionTiming.apres,
    appliesTo: [ProjectFilter.maison],
  ),

  // ── s_risques : Risques naturels ──────────────────────────────────────────

  QuestionTemplate(
    id: kQErpConsulte,
    section: 's_risques',
    text: 'ERP consulté (État des Risques et Pollutions) ?',
    level: QuestionLevel.critical,
    type: QuestionType.yesNo,
    timing: QuestionTiming.apres,
    appliesTo: [ProjectFilter.maison],
  ),
  QuestionTemplate(
    id: kQRisqueInondation,
    section: 's_risques',
    text: 'Zone inondable ?',
    level: QuestionLevel.critical,
    type: QuestionType.yesNo,
    timing: QuestionTiming.apres,
    appliesTo: [ProjectFilter.maison],
  ),
  QuestionTemplate(
    id: kQRisqueGlissement,
    section: 's_risques',
    text: 'Risque de glissement de terrain ?',
    level: QuestionLevel.critical,
    type: QuestionType.yesNo,
    timing: QuestionTiming.apres,
    appliesTo: [ProjectFilter.maison],
  ),
  QuestionTemplate(
    id: kQPollutionSols,
    section: 's_risques',
    text: 'Pollution des sols connue ?',
    level: QuestionLevel.critical,
    type: QuestionType.yesNo,
    timing: QuestionTiming.apres,
    appliesTo: [ProjectFilter.maison],
  ),
  QuestionTemplate(
    id: kQNuisancesEnvironnement,
    section: 's_risques',
    text: 'Nuisances environnementales (lignes HT, antennes) ?',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.apres,
    appliesTo: [ProjectFilter.maison],
  ),

  // ── s_diagnostics : Diagnostics techniques ────────────────────────────────

  QuestionTemplate(
    id: kQRavelementDate,
    section: 's_diagnostics',
    text: 'Date du dernier ravalement de façade',
    hint: 'Demandez au syndic',
    level: QuestionLevel.important,
    type: QuestionType.text,
    timing: QuestionTiming.apres,
    appliesTo: [ProjectFilter.achat, ProjectFilter.appartement],
  ),
  QuestionTemplate(
    id: kQTravauxVotes,
    section: 's_diagnostics',
    text: 'Des travaux sont-ils votés en copropriété ?',
    level: QuestionLevel.critical,
    type: QuestionType.yesNo,
    timing: QuestionTiming.apres,
    appliesTo: [ProjectFilter.achat, ProjectFilter.appartement],
  ),
  QuestionTemplate(
    id: kQProceduresCopro,
    section: 's_diagnostics',
    text: 'Procédures en cours (litiges, non-paiement) ?',
    level: QuestionLevel.critical,
    type: QuestionType.yesNo,
    timing: QuestionTiming.apres,
    appliesTo: [ProjectFilter.achat, ProjectFilter.appartement],
  ),
  QuestionTemplate(
    id: kQEvacuationsCommunes,
    section: 's_diagnostics',
    text: 'Évacuations d\'eau dans les parties communes ?',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.apres,
    appliesTo: [ProjectFilter.achat, ProjectFilter.appartement],
  ),
  QuestionTemplate(
    id: kQFibreImmeuble,
    section: 's_diagnostics',
    text: 'Fibre optique installée dans l\'immeuble ?',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.apres,
    appliesTo: [ProjectFilter.achat, ProjectFilter.appartement],
  ),
  QuestionTemplate(
    id: kQDpeNiveau,
    section: 's_diagnostics',
    text: 'Niveau DPE et date de réalisation',
    hint: 'Ex : C — réalisé le 01/01/2022',
    level: QuestionLevel.critical,
    type: QuestionType.text,
    timing: QuestionTiming.apres,
    appliesTo: [ProjectFilter.achat, ProjectFilter.appartement],
  ),
  QuestionTemplate(
    id: kQElecAge,
    section: 's_diagnostics',
    text: 'Installation électrique de plus de 15 ans ?',
    level: QuestionLevel.critical,
    type: QuestionType.yesNo,
    timing: QuestionTiming.apres,
    appliesTo: [ProjectFilter.achat, ProjectFilter.appartement],
  ),
  QuestionTemplate(
    id: kQDiagElec,
    section: 's_diagnostics',
    text: 'Diagnostic électrique réalisé ? Date ?',
    hint: 'Obligatoire si installation > 15 ans',
    level: QuestionLevel.critical,
    type: QuestionType.text,
    timing: QuestionTiming.apres,
    appliesTo: [ProjectFilter.achat, ProjectFilter.appartement],
  ),
  QuestionTemplate(
    id: kQGazAge,
    section: 's_diagnostics',
    text: 'Installation gaz de plus de 15 ans ?',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.apres,
    appliesTo: [ProjectFilter.achat, ProjectFilter.appartement],
  ),
  QuestionTemplate(
    id: kQDiagGaz,
    section: 's_diagnostics',
    text: 'Diagnostic gaz réalisé ? Date ?',
    level: QuestionLevel.important,
    type: QuestionType.text,
    timing: QuestionTiming.apres,
    appliesTo: [ProjectFilter.achat, ProjectFilter.appartement],
  ),
  QuestionTemplate(
    id: kQDateConstruction,
    section: 's_diagnostics',
    text: 'Date de construction du bâtiment',
    hint: 'Vérifiez sur le cadastre ou l\'acte notarié',
    level: QuestionLevel.important,
    type: QuestionType.text,
    timing: QuestionTiming.apres,
    appliesTo: [ProjectFilter.achat, ProjectFilter.appartement],
  ),
  QuestionTemplate(
    id: kQDiagAmiante,
    section: 's_diagnostics',
    text: 'Bâtiment antérieur à 1997 → diagnostic amiante réalisé ? Date ?',
    level: QuestionLevel.critical,
    type: QuestionType.text,
    timing: QuestionTiming.apres,
    appliesTo: [ProjectFilter.achat, ProjectFilter.appartement],
  ),
  QuestionTemplate(
    id: kQDiagPlomb,
    section: 's_diagnostics',
    text: 'Bâtiment antérieur à 1949 → diagnostic plomb réalisé ? Date ?',
    level: QuestionLevel.critical,
    type: QuestionType.text,
    timing: QuestionTiming.apres,
    appliesTo: [ProjectFilter.achat, ProjectFilter.appartement],
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
    id: kQTaxeHabitation,
    section: 's8',
    text: 'Taxe d\'habitation annuelle ?',
    hint: 'En €',
    level: QuestionLevel.important,
    type: QuestionType.text,
    timing: QuestionTiming.avant,
    appliesTo: [ProjectFilter.location],
  ),
  QuestionTemplate(
    id: kQCoproprietieMaison,
    section: 's8',
    text: 'Le bien est-il en copropriété ?',
    level: QuestionLevel.important,
    type: QuestionType.yesNo,
    timing: QuestionTiming.avant,
    appliesTo: [ProjectFilter.achat, ProjectFilter.maison],
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
