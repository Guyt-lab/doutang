import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/enums.dart';
import '../../models/listing.dart';
import '../../models/listing_facts.dart';
import '../../models/visit.dart';
import '../../services/facts_sync_service.dart';
import '../../services/listing_storage_service.dart';
import '../../services/project_service.dart';
import '../../theme/doutang_theme.dart';
import '../../widgets/dpe_badge.dart';

class ListingFactsScreen extends StatefulWidget {
  const ListingFactsScreen({super.key, required this.listing});

  final Listing listing;

  @override
  State<ListingFactsScreen> createState() => _ListingFactsScreenState();
}

class _ListingFactsScreenState extends State<ListingFactsScreen> {
  bool _isSaving = false;

  // ── Général ──────────────────────────────────────────────────────────────
  late final TextEditingController _priceCtrl;
  late final TextEditingController _chargesCtrl;
  late final TextEditingController _surfaceTotalCtrl;
  late final TextEditingController _surfaceSejourCtrl;
  int? _rooms;
  int? _bedrooms;
  int? _floor;
  int? _floorsTotal;
  bool? _isFurnished;
  late final TextEditingController _buildingYearCtrl;
  BuildingStyle? _style;

  // ── Technique ─────────────────────────────────────────────────────────────
  String? _dpe;
  HeatingType? _heatingType;
  HeatingControl? _heatingControl;
  GlazingType? _doubleGlazing;
  int? _windowsCount;
  bool? _secureDoor;
  bool? _fiber;
  WaterQuality? _waterQuality;

  // ── Sols ──────────────────────────────────────────────────────────────────
  FloorType? _floorTypeLiving;
  FloorType? _floorTypeBedroom;

  // ── Cuisine ───────────────────────────────────────────────────────────────
  KitchenType? _kitchenType;
  KitchenEnergy? _kitchenEnergy;
  bool? _kitchenEquipped;

  // ── Éclairage ─────────────────────────────────────────────────────────────
  LightingType? _lightingLiving;
  LightingType? _lightingBedroom;

  // ── Extérieur ─────────────────────────────────────────────────────────────
  bool? _hasBalcony;
  late final TextEditingController _balconySurfCtrl;
  bool? _hasTerrace;
  late final TextEditingController _terraceSurfCtrl;
  bool? _hasGarden;
  late final TextEditingController _gardenSurfCtrl;
  bool? _hasCourtyard;
  bool? _hasParking;
  bool? _hasCellar;

  // ── Charme ────────────────────────────────────────────────────────────────
  bool? _hasBeams;
  bool? _hasFireplace;
  bool? _fireplaceFunctional;
  bool? _hasMouldings;

  // ── Plan ──────────────────────────────────────────────────────────────────
  bool? _hasHallway;
  bool? _separateToilet;
  bool? _hasDressing;
  BathroomSize? _bathroomSize;
  Proximity? _bedroomBathroomProximity;
  Proximity? _kitchenLivingProximity;

  Set<String> get _af => widget.listing.autoFilledFields;

  @override
  void initState() {
    super.initState();
    final f = widget.listing.facts;
    final l = widget.listing;

    _priceCtrl = TextEditingController(
        text: l.price != null ? l.price!.toInt().toString() : '');
    _chargesCtrl = TextEditingController(
        text: f.charges != null ? f.charges!.toInt().toString() : '');
    _surfaceTotalCtrl = TextEditingController(
        text: (f.surfaceTotal ?? l.surface) != null
            ? (f.surfaceTotal ?? l.surface)!.toInt().toString()
            : '');
    _surfaceSejourCtrl = TextEditingController(
        text:
            f.surfaceSejour != null ? f.surfaceSejour!.toInt().toString() : '');
    _rooms = f.rooms ?? l.rooms;
    _bedrooms = f.bedrooms;
    _floor = f.floor;
    _floorsTotal = f.floorsTotal;
    _isFurnished = f.isFurnished;
    _buildingYearCtrl =
        TextEditingController(text: f.buildingYear?.toString() ?? '');
    _style = f.style;
    _dpe = f.dpe;
    _heatingType = f.heatingType;
    _heatingControl = f.heatingControl;
    _doubleGlazing = f.doubleGlazing;
    _windowsCount = f.windowsCount;
    _secureDoor = f.secureDoor;
    _fiber = f.fiber;
    _waterQuality = f.waterQuality;
    _floorTypeLiving = f.floorTypeLiving;
    _floorTypeBedroom = f.floorTypeBedroom;
    _kitchenType = f.kitchenType;
    _kitchenEnergy = f.kitchenEnergy;
    _kitchenEquipped = f.kitchenEquipped;
    _lightingLiving = f.lightingLiving;
    _lightingBedroom = f.lightingBedroom;
    _hasBalcony = f.hasBalcony;
    _balconySurfCtrl = TextEditingController(
        text: f.balconySurface != null
            ? f.balconySurface!.toInt().toString()
            : '');
    _hasTerrace = f.hasTerrace;
    _terraceSurfCtrl = TextEditingController(
        text: f.terraceSurface != null
            ? f.terraceSurface!.toInt().toString()
            : '');
    _hasGarden = f.hasGarden;
    _gardenSurfCtrl = TextEditingController(
        text:
            f.gardenSurface != null ? f.gardenSurface!.toInt().toString() : '');
    _hasCourtyard = f.hasCourtyard;
    _hasParking = f.hasParking;
    _hasCellar = f.hasCellar;
    _hasBeams = f.hasBeams;
    _hasFireplace = f.hasFireplace;
    _fireplaceFunctional = f.fireplaceFunctional;
    _hasMouldings = f.hasMouldings;
    _hasHallway = f.hasHallway;
    _separateToilet = f.separateToilet;
    _hasDressing = f.hasDressing;
    _bathroomSize = f.bathroomSize;
    _bedroomBathroomProximity = f.bedroomBathroomProximity;
    _kitchenLivingProximity = f.kitchenLivingProximity;
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _chargesCtrl.dispose();
    _surfaceTotalCtrl.dispose();
    _surfaceSejourCtrl.dispose();
    _buildingYearCtrl.dispose();
    _balconySurfCtrl.dispose();
    _terraceSurfCtrl.dispose();
    _gardenSurfCtrl.dispose();
    super.dispose();
  }

  // ── Sauvegarde ────────────────────────────────────────────────────────────

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final projectId = await ProjectService.getActiveId() ?? '';

    final facts = ListingFacts(
      surfaceTotal: double.tryParse(_surfaceTotalCtrl.text),
      surfaceSejour: double.tryParse(_surfaceSejourCtrl.text),
      rooms: _rooms,
      bedrooms: _bedrooms,
      floor: _floor,
      floorsTotal: _floorsTotal,
      isFurnished: _isFurnished,
      buildingYear: int.tryParse(_buildingYearCtrl.text),
      style: _style,
      dpe: _dpe?.isEmpty == true ? null : _dpe,
      heatingType: _heatingType,
      heatingControl: _heatingControl,
      doubleGlazing: _doubleGlazing,
      windowsCount: _windowsCount,
      secureDoor: _secureDoor,
      fiber: _fiber,
      waterQuality: _waterQuality,
      floorTypeLiving: _floorTypeLiving,
      floorTypeBedroom: _floorTypeBedroom,
      kitchenType: _kitchenType,
      kitchenEnergy: _kitchenEnergy,
      kitchenEquipped: _kitchenEquipped,
      lightingLiving: _lightingLiving,
      lightingBedroom: _lightingBedroom,
      hasBalcony: _hasBalcony,
      balconySurface:
          _hasBalcony == true ? double.tryParse(_balconySurfCtrl.text) : null,
      hasTerrace: _hasTerrace,
      terraceSurface:
          _hasTerrace == true ? double.tryParse(_terraceSurfCtrl.text) : null,
      hasGarden: _hasGarden,
      gardenSurface:
          _hasGarden == true ? double.tryParse(_gardenSurfCtrl.text) : null,
      hasCourtyard: _hasCourtyard,
      hasParking: _hasParking,
      hasCellar: _hasCellar,
      hasBeams: _hasBeams,
      hasFireplace: _hasFireplace,
      fireplaceFunctional: _hasFireplace == true ? _fireplaceFunctional : null,
      hasMouldings: _hasMouldings,
      hasHallway: _hasHallway,
      separateToilet: _separateToilet,
      hasDressing: _hasDressing,
      bathroomSize: _bathroomSize,
      bedroomBathroomProximity: _bedroomBathroomProximity,
      kitchenLivingProximity: _kitchenLivingProximity,
      charges: double.tryParse(_chargesCtrl.text),
    );

    final syncedAnswers = FactsSyncService.syncFactsToAnswers(
      facts,
      widget.listing.preFilledAnswers ?? VisitAnswers(),
    );

    final priceText = _priceCtrl.text.trim();
    final updated = Listing(
      id: widget.listing.id,
      url: widget.listing.url,
      title: widget.listing.title,
      price:
          priceText.isEmpty ? widget.listing.price : double.tryParse(priceText),
      surface: facts.surfaceTotal ?? widget.listing.surface,
      rooms: _rooms ?? widget.listing.rooms,
      address: widget.listing.address,
      status: widget.listing.status,
      notes: widget.listing.notes,
      addedBy: widget.listing.addedBy,
      addedAt: widget.listing.addedAt,
      facts: facts,
      contact: widget.listing.contact,
      propertyKind: widget.listing.propertyKind,
      transactionKind: widget.listing.transactionKind,
      autoFilledFields: widget.listing.autoFilledFields,
      preFilledAnswers: syncedAnswers,
    );

    await ListingStorageService.update(updated, projectId: projectId);

    if (mounted) {
      Navigator.pop(context, updated);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fiche technique'),
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : TextButton(
                  onPressed: _save,
                  child: const Text('Enregistrer',
                      style: TextStyle(
                          color: DoutangTheme.primary,
                          fontWeight: FontWeight.w700)),
                ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(DSpacing.md),
        children: [
          _sectionGeneral(),
          _sectionTechnique(),
          _sectionSols(),
          _sectionCuisine(),
          _sectionEclairage(),
          _sectionExterieur(),
          _sectionCharme(),
          _sectionPlan(),
          const SizedBox(height: DSpacing.xl),
        ],
      ),
    );
  }

  // ── Sections ──────────────────────────────────────────────────────────────

  Widget _sectionGeneral() {
    final isAchat =
        widget.listing.transactionKind == ListingTransactionKind.achat;
    return _Section(
      title: 'Général',
      initiallyExpanded: true,
      children: [
        _fieldRow(
          isAchat ? 'Prix d\'achat (€)' : 'Loyer mensuel (€/mois)',
          _numField(_priceCtrl, '0', af: _af.contains('price')),
          af: _af.contains('price'),
        ),
        _fieldRow(
          'Charges mensuelles (€)',
          _numField(_chargesCtrl, '0', af: _af.contains('charges')),
          af: _af.contains('charges'),
        ),
        _fieldRow(
          'Surface totale (m²)',
          _numField(_surfaceTotalCtrl, '0', af: _af.contains('surface')),
          af: _af.contains('surface'),
        ),
        _fieldRow(
          'Surface séjour (m²)',
          _numField(_surfaceSejourCtrl, '0'),
        ),
        _fieldRow(
          'Nombre de pièces',
          _stepper(_rooms, 0, (v) => setState(() => _rooms = v)),
        ),
        _fieldRow(
          'Nombre de chambres',
          _stepper(_bedrooms, 0, (v) => setState(() => _bedrooms = v)),
        ),
        _fieldRow(
          'Étage (−1 = sous-sol, 0 = RDC)',
          _stepper(_floor, -1, (v) => setState(() => _floor = v),
              af: _af.contains('floor')),
          af: _af.contains('floor'),
        ),
        _fieldRow(
          'Nombre total d\'étages',
          _stepper(_floorsTotal, 0, (v) => setState(() => _floorsTotal = v)),
        ),
        _switchField(
          'Meublé',
          _isFurnished,
          (v) => setState(() => _isFurnished = v),
          af: _af.contains('is_furnished'),
        ),
        _fieldRow(
          'Année de construction',
          _numField(_buildingYearCtrl, 'ex: 1965',
              keyboardType: TextInputType.number),
        ),
        _fieldRow(
          'Style',
          _chips(
            [
              (BuildingStyle.haussmannien, 'Haussmannien'),
              (BuildingStyle.moderne, 'Moderne'),
              (BuildingStyle.ancien, 'Ancien'),
              (BuildingStyle.contemporain, 'Contemporain'),
              (BuildingStyle.brique, 'Brique'),
              (BuildingStyle.autre, 'Autre'),
            ],
            _style,
            (v) => setState(() => _style = v),
          ),
        ),
      ],
    );
  }

  Widget _sectionTechnique() {
    return _Section(
      title: 'Technique',
      children: [
        _fieldRow(
          'DPE',
          _DpeSelector(
            selected: _dpe,
            onChanged: (v) => setState(() => _dpe = v),
          ),
          af: _af.contains('dpe'),
        ),
        _fieldRow(
          'Type de chauffage',
          _chips(
            [
              (HeatingType.gaz, 'Gaz'),
              (HeatingType.electrique, 'Électrique'),
              (HeatingType.fioul, 'Fioul'),
              (HeatingType.pompeAChaleur, 'PAC'),
              (HeatingType.bois, 'Bois'),
              (HeatingType.climReversible, 'Clim réversible'),
              (HeatingType.autre, 'Autre'),
            ],
            _heatingType,
            (v) => setState(() => _heatingType = v),
          ),
        ),
        _fieldRow(
          'Contrôle chauffage',
          _chips(
            [
              (HeatingControl.individuel, 'Individuel'),
              (HeatingControl.collectif, 'Collectif'),
              (HeatingControl.mitige, 'Mitigé'),
            ],
            _heatingControl,
            (v) => setState(() => _heatingControl = v),
          ),
        ),
        _fieldRow(
          'Double vitrage',
          _chips(
            [
              (GlazingType.doubleVitrage, 'Partout'),
              (GlazingType.simple, 'Aucun'),
              (GlazingType.tripleVitrage, 'Triple'),
            ],
            _doubleGlazing,
            (v) => setState(() => _doubleGlazing = v),
          ),
        ),
        _fieldRow(
          'Nombre de fenêtres',
          _stepper(_windowsCount, 0, (v) => setState(() => _windowsCount = v)),
        ),
        _switchField('Porte blindée', _secureDoor,
            (v) => setState(() => _secureDoor = v)),
        _switchField(
            'Fibre disponible', _fiber, (v) => setState(() => _fiber = v)),
        _fieldRow(
          'Qualité de l\'eau',
          _chips(
            [
              (WaterQuality.normale, 'Bonne'),
              (WaterQuality.calcaire, 'Calcaire'),
              (WaterQuality.douce, 'Douce'),
            ],
            _waterQuality,
            (v) => setState(() => _waterQuality = v),
          ),
        ),
      ],
    );
  }

  Widget _sectionSols() {
    const options = [
      (FloorType.parquet, 'Parquet'),
      (FloorType.parquetFlottant, 'Parquet flottant'),
      (FloorType.carrelage, 'Carrelage'),
      (FloorType.betonCire, 'Béton ciré'),
      (FloorType.moquette, 'Moquette'),
      (FloorType.stratifie, 'Stratifié'),
      (FloorType.tomette, 'Tomette'),
      (FloorType.autre, 'Autre'),
    ];
    return _Section(
      title: 'Sols & revêtements',
      children: [
        _fieldRow(
          'Sol séjour',
          _chips(options, _floorTypeLiving,
              (v) => setState(() => _floorTypeLiving = v)),
        ),
        _fieldRow(
          'Sol chambre(s)',
          _chips(options, _floorTypeBedroom,
              (v) => setState(() => _floorTypeBedroom = v)),
        ),
      ],
    );
  }

  Widget _sectionCuisine() {
    return _Section(
      title: 'Cuisine',
      children: [
        _fieldRow(
          'Configuration',
          _chips(
            [
              (KitchenType.ouverte, 'Ouverte'),
              (KitchenType.semiOuverte, 'Semi-ouverte'),
              (KitchenType.fermee, 'Fermée'),
              (KitchenType.americaine, 'Américaine'),
            ],
            _kitchenType,
            (v) => setState(() => _kitchenType = v),
          ),
        ),
        _fieldRow(
          'Énergie',
          _chips(
            [
              (KitchenEnergy.gaz, 'Gaz'),
              (KitchenEnergy.electrique, 'Électrique'),
              (KitchenEnergy.induction, 'Induction'),
            ],
            _kitchenEnergy,
            (v) => setState(() => _kitchenEnergy = v),
          ),
        ),
        _switchField('Cuisine équipée', _kitchenEquipped,
            (v) => setState(() => _kitchenEquipped = v)),
      ],
    );
  }

  Widget _sectionEclairage() {
    const options = [
      (LightingType.excellente, 'Excellente'),
      (LightingType.bonne, 'Bonne'),
      (LightingType.moyenne, 'Moyenne'),
      (LightingType.sombre, 'Sombre'),
    ];
    return _Section(
      title: 'Éclairage naturel',
      children: [
        _fieldRow(
          'Séjour',
          _chips(options, _lightingLiving,
              (v) => setState(() => _lightingLiving = v)),
        ),
        _fieldRow(
          'Chambre(s)',
          _chips(options, _lightingBedroom,
              (v) => setState(() => _lightingBedroom = v)),
        ),
      ],
    );
  }

  Widget _sectionExterieur() {
    return _Section(
      title: 'Extérieur',
      children: [
        _switchField(
          'Balcon',
          _hasBalcony,
          (v) => setState(() => _hasBalcony = v),
          af: _af.contains('has_balcony'),
        ),
        if (_hasBalcony == true)
          _fieldRow(
            'Surface balcon (m²)',
            _numField(_balconySurfCtrl, '0'),
          ),
        _switchField(
          'Terrasse',
          _hasTerrace,
          (v) => setState(() => _hasTerrace = v),
          af: _af.contains('has_terrace'),
        ),
        if (_hasTerrace == true)
          _fieldRow(
            'Surface terrasse (m²)',
            _numField(_terraceSurfCtrl, '0'),
          ),
        _switchField(
          'Jardin',
          _hasGarden,
          (v) => setState(() => _hasGarden = v),
          af: _af.contains('has_garden'),
        ),
        if (_hasGarden == true)
          _fieldRow(
            'Surface jardin (m²)',
            _numField(_gardenSurfCtrl, '0'),
          ),
        _switchField('Cour intérieure', _hasCourtyard,
            (v) => setState(() => _hasCourtyard = v)),
        _switchField(
          'Parking inclus',
          _hasParking,
          (v) => setState(() => _hasParking = v),
          af: _af.contains('has_parking'),
        ),
        _switchField(
          'Cave incluse',
          _hasCellar,
          (v) => setState(() => _hasCellar = v),
          af: _af.contains('has_cellar'),
        ),
      ],
    );
  }

  Widget _sectionCharme() {
    return _Section(
      title: 'Charme & caractère',
      children: [
        _switchField('Poutres apparentes', _hasBeams,
            (v) => setState(() => _hasBeams = v)),
        _switchField('Cheminée', _hasFireplace,
            (v) => setState(() => _hasFireplace = v)),
        if (_hasFireplace == true)
          _switchField('Cheminée fonctionnelle', _fireplaceFunctional,
              (v) => setState(() => _fireplaceFunctional = v)),
        _switchField('Moulures', _hasMouldings,
            (v) => setState(() => _hasMouldings = v)),
      ],
    );
  }

  Widget _sectionPlan() {
    return _Section(
      title: 'Plan & circulation',
      children: [
        _switchField('Couloir d\'entrée', _hasHallway,
            (v) => setState(() => _hasHallway = v)),
        _switchField('WC séparés', _separateToilet,
            (v) => setState(() => _separateToilet = v)),
        _switchField(
            'Dressing', _hasDressing, (v) => setState(() => _hasDressing = v)),
        _fieldRow(
          'Taille salle de bain',
          _chips(
            [
              (BathroomSize.petite, 'Petite (<4m²)'),
              (BathroomSize.moyenne, 'Standard (4-7m²)'),
              (BathroomSize.grande, 'Grande (>7m²)'),
            ],
            _bathroomSize,
            (v) => setState(() => _bathroomSize = v),
          ),
        ),
        _fieldRow(
          'Proximité chambre-SdB',
          _chips(
            [
              (Proximity.direct, 'Adjacente'),
              (Proximity.proche, 'Proche'),
              (Proximity.eloigne, 'Éloignée'),
            ],
            _bedroomBathroomProximity,
            (v) => setState(() => _bedroomBathroomProximity = v),
          ),
        ),
        _fieldRow(
          'Proximité cuisine-séjour',
          _chips(
            [
              (Proximity.direct, 'Ouverte'),
              (Proximity.proche, 'Séparée proche'),
              (Proximity.eloigne, 'Séparée éloignée'),
            ],
            _kitchenLivingProximity,
            (v) => setState(() => _kitchenLivingProximity = v),
          ),
        ),
      ],
    );
  }

  // ── Helpers UI ────────────────────────────────────────────────────────────

  Widget _fieldRow(String label, Widget control, {bool af = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 13, color: DoutangTheme.textSecondary)),
              const SizedBox(width: 4),
              if (af)
                const Icon(Icons.check_circle,
                    size: 13, color: DoutangTheme.scoreExcellent)
              else
                const Icon(Icons.edit_outlined,
                    size: 13, color: DoutangTheme.textHint),
            ],
          ),
          const SizedBox(height: 6),
          control,
        ],
      ),
    );
  }

  Widget _switchField(String label, bool? value, void Function(bool) onChanged,
      {bool af = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(label),
                const SizedBox(width: 4),
                if (af)
                  const Icon(Icons.check_circle,
                      size: 13, color: DoutangTheme.scoreExcellent)
                else
                  const Icon(Icons.edit_outlined,
                      size: 13, color: DoutangTheme.textHint),
              ],
            ),
          ),
          Switch(value: value ?? false, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _numField(
    TextEditingController ctrl,
    String hint, {
    bool af = false,
    TextInputType? keyboardType,
  }) {
    return SizedBox(
      width: 140,
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType ??
            const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
        ],
        decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          suffixIcon: af
              ? const Icon(Icons.check_circle,
                  size: 16, color: DoutangTheme.scoreExcellent)
              : null,
        ),
      ),
    );
  }

  Widget _stepper(int? value, int min, void Function(int?) onChanged,
      {bool af = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          icon: const Icon(Icons.remove_circle_outline),
          color: DoutangTheme.primary,
          onPressed:
              value != null && value > min ? () => onChanged(value - 1) : null,
        ),
        SizedBox(
          width: 44,
          child: Text(
            value?.toString() ?? '—',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          icon: const Icon(Icons.add_circle_outline),
          color: DoutangTheme.primary,
          onPressed: () => onChanged((value ?? (min - 1)) + 1),
        ),
        if (value != null)
          GestureDetector(
            onTap: () => onChanged(null),
            child: const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(Icons.close, size: 16, color: DoutangTheme.textHint),
            ),
          ),
        if (af)
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Icon(Icons.check_circle,
                size: 13, color: DoutangTheme.scoreExcellent),
          ),
      ],
    );
  }

  Widget _chips<T>(
    List<(T, String)> options,
    T? selected,
    void Function(T?) onChanged,
  ) {
    return Wrap(
      spacing: DSpacing.sm,
      runSpacing: 4,
      children: options.map((opt) {
        final (val, label) = opt;
        final isSelected = selected == val;
        return ChoiceChip(
          label: Text(label, style: const TextStyle(fontSize: 12)),
          selected: isSelected,
          onSelected: (s) => onChanged(s ? val : null),
          visualDensity: VisualDensity.compact,
        );
      }).toList(),
    );
  }
}

// ── Sélecteur DPE ─────────────────────────────────────────────────────────────

class _DpeSelector extends StatelessWidget {
  const _DpeSelector({required this.selected, required this.onChanged});

  final String? selected;
  final void Function(String?) onChanged;

  static const _letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: DSpacing.sm,
      children: _letters.map((l) {
        final isSelected = selected?.toUpperCase() == l;
        return GestureDetector(
          onTap: () => onChanged(isSelected ? null : l),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? dpeColor(l) : DoutangTheme.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected ? dpeColor(l) : DoutangTheme.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              l,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: isSelected
                    ? (l == 'D' ? Colors.black87 : Colors.white)
                    : DoutangTheme.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Section wrapper ───────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.children,
    this.initiallyExpanded = false,
  });

  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: DSpacing.sm),
      child: ExpansionTile(
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: DoutangTheme.textPrimary)),
        initiallyExpanded: initiallyExpanded,
        childrenPadding:
            const EdgeInsets.fromLTRB(DSpacing.md, 0, DSpacing.md, DSpacing.md),
        children: children,
      ),
    );
  }
}
