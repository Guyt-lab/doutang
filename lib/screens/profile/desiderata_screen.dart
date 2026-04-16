import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/profile.dart';
import '../../services/profile_storage_service.dart';
import '../../theme/doutang_theme.dart';

class DesiderataScreen extends StatefulWidget {
  const DesiderataScreen({super.key});

  @override
  State<DesiderataScreen> createState() => _DesiderataScreenState();
}

class _DesiderataScreenState extends State<DesiderataScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ownerController = TextEditingController(text: 'Moi');
  final _budgetController = TextEditingController();
  final _surfaceController = TextEditingController();
  final _zoneController = TextEditingController();

  int _roomsMin = 1;
  String _projectType = 'location';
  List<String> _zones = [];
  Map<String, int> _weights = UserProfile.defaultWeights();

  bool _loading = true;
  bool _saving = false;

  static const Map<String, (String, IconData)> _weightLabels = {
    'budget': ('Budget', Icons.euro),
    'surface': ('Surface', Icons.square_foot),
    'transports': ('Transports', Icons.directions_transit),
    'luminosite': ('Luminosité', Icons.wb_sunny),
    'calme': ('Calme', Icons.volume_off),
    'etat': ('État général', Icons.home_repair_service),
    'quartier': ('Quartier', Icons.place),
    'exterieur': ('Extérieur', Icons.park),
  };

  // ── Cycle de vie ──────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _budgetController.dispose();
    _surfaceController.dispose();
    _zoneController.dispose();
    super.dispose();
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  Future<void> _loadProfile() async {
    final profile = await ProfileStorageService.load();
    if (profile != null && mounted) {
      setState(() {
        _ownerController.text = profile.owner;
        final c = profile.criteria;
        if (c.budgetMax != null) {
          _budgetController.text = c.budgetMax!.toInt().toString();
        }
        if (c.surfaceMin != null) {
          _surfaceController.text = c.surfaceMin!.toInt().toString();
        }
        _roomsMin = c.roomsMin ?? 1;
        _projectType = c.projectType ?? 'location';
        _zones = List<String>.from(c.zones);
        _weights = Map<String, int>.from(profile.weights);
      });
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final profile = UserProfile(
      owner: _ownerController.text.trim(),
      criteria: SearchCriteria(
        budgetMax: _budgetController.text.isEmpty
            ? null
            : double.tryParse(_budgetController.text),
        surfaceMin: _surfaceController.text.isEmpty
            ? null
            : double.tryParse(_surfaceController.text),
        roomsMin: _roomsMin,
        projectType: _projectType,
        zones: List<String>.from(_zones),
      ),
      weights: Map<String, int>.from(_weights),
    );

    await ProfileStorageService.save(profile);

    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Désidératas enregistrés'),
          backgroundColor: DoutangTheme.primary,
        ),
      );
      Navigator.pop(context);
    }
  }

  // ── Gestion des zones ─────────────────────────────────────────────────────

  void _addZone() {
    final zone = _zoneController.text.trim();
    if (zone.isNotEmpty && !_zones.contains(zone)) {
      setState(() {
        _zones.add(zone);
        _zoneController.clear();
      });
    }
  }

  void _removeZone(String zone) => setState(() => _zones.remove(zone));

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mes désidératas')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes désidératas'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: DSpacing.sm),
            child: TextButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Enregistrer'),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(DSpacing.md),
          children: [
            // ── Profil ──
            _SectionTitle('Mon profil'),
            const SizedBox(height: DSpacing.sm),
            _buildProfileSection(),
            const SizedBox(height: DSpacing.lg),

            // ── Critères ──
            _SectionTitle('Critères de recherche'),
            const SizedBox(height: DSpacing.sm),
            _buildCriteriaSection(),
            const SizedBox(height: DSpacing.lg),

            // ── Zones ──
            _SectionTitle('Zones souhaitées'),
            const SizedBox(height: DSpacing.sm),
            _buildZonesSection(),
            const SizedBox(height: DSpacing.lg),

            // ── Pondérations ──
            _SectionTitle('Ce qui compte pour moi'),
            const SizedBox(height: DSpacing.xs),
            Text(
              'Pondérez chaque critère de 1 (peu important) à 5 (indispensable)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: DSpacing.sm),
            _buildWeightsSection(),

            const SizedBox(height: DSpacing.xxl),
          ],
        ),
      ),
    );
  }

  // ── Sections ──────────────────────────────────────────────────────────────

  Widget _buildProfileSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _ownerController,
              decoration: const InputDecoration(
                labelText: 'Votre prénom',
                prefixIcon: Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requis' : null,
            ),
            const SizedBox(height: DSpacing.md),
            Text(
              'Type de projet',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: DSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'location',
                    label: Text('Location'),
                    icon: Icon(Icons.key_outlined),
                  ),
                  ButtonSegment(
                    value: 'achat',
                    label: Text('Achat'),
                    icon: Icon(Icons.home_outlined),
                  ),
                ],
                selected: {_projectType},
                onSelectionChanged: (selection) =>
                    setState(() => _projectType = selection.first),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCriteriaSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DSpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _budgetController,
                    decoration: InputDecoration(
                      labelText: _projectType == 'location'
                          ? 'Budget max (€/mois)'
                          : 'Budget max (€)',
                      prefixIcon: const Icon(Icons.euro),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: DSpacing.sm),
                Expanded(
                  child: TextFormField(
                    controller: _surfaceController,
                    decoration: const InputDecoration(
                      labelText: 'Surface min (m²)',
                      prefixIcon: Icon(Icons.square_foot),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSpacing.md),
            Row(
              children: [
                const Icon(
                  Icons.door_front_door_outlined,
                  size: 20,
                  color: DoutangTheme.textSecondary,
                ),
                const SizedBox(width: DSpacing.sm),
                Text(
                  'Pièces minimum',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Spacer(),
                _RoomsPicker(
                  value: _roomsMin,
                  onChanged: (v) => setState(() => _roomsMin = v),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZonesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _zoneController,
                    decoration: const InputDecoration(
                      hintText: 'Ex : Paris 11, Montreuil…',
                      prefixIcon: Icon(Icons.add_location_outlined),
                      isDense: true,
                    ),
                    textCapitalization: TextCapitalization.words,
                    onFieldSubmitted: (_) => _addZone(),
                  ),
                ),
                const SizedBox(width: DSpacing.sm),
                IconButton.filled(
                  onPressed: _addZone,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: DoutangTheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            if (_zones.isNotEmpty) ...[
              const SizedBox(height: DSpacing.sm),
              Wrap(
                spacing: DSpacing.sm,
                runSpacing: DSpacing.xs,
                children: _zones
                    .map(
                      (z) => Chip(
                        label: Text(z),
                        onDeleted: () => _removeZone(z),
                        deleteIconColor: DoutangTheme.textSecondary,
                        backgroundColor: DoutangTheme.primarySurface,
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeightsSection() {
    return Card(
      child: Column(
        children: _weightLabels.entries.map((entry) {
          final key = entry.key;
          final (label, icon) = entry.value;
          final value = _weights[key] ?? 3;
          return _WeightRow(
            icon: icon,
            label: label,
            value: value,
            onChanged: (v) => setState(() => _weights[key] = v),
          );
        }).toList(),
      ),
    );
  }
}

// ── Widgets auxiliaires ────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.headlineSmall);
}

class _RoomsPicker extends StatelessWidget {
  const _RoomsPicker({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: value > 1 ? () => onChanged(value - 1) : null,
          color: DoutangTheme.primary,
        ),
        SizedBox(
          width: 28,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => onChanged(value + 1),
          color: DoutangTheme.primary,
        ),
      ],
    );
  }
}

class _WeightRow extends StatelessWidget {
  const _WeightRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSpacing.md,
        vertical: DSpacing.xs,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: DoutangTheme.textSecondary),
          const SizedBox(width: DSpacing.sm),
          SizedBox(
            width: 92,
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Expanded(
            child: Slider(
              value: value.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: '$value',
              activeColor: DoutangTheme.primary,
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
          SizedBox(
            width: 20,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: DoutangTheme.primary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
