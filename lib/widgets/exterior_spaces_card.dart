import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/exterior_space.dart';
import '../theme/doutang_theme.dart';

const _kTypes = ['Balcon', 'Terrasse', 'Jardin', 'Cour'];

const _kTypeIcons = <String, IconData>{
  'Balcon': Icons.balcony_outlined,
  'Terrasse': Icons.deck_outlined,
  'Jardin': Icons.park_outlined,
  'Cour': Icons.yard_outlined,
};

/// Carte de saisie des espaces extérieurs d'un bien.
///
/// Affiche 4 types (Balcon, Terrasse, Jardin, Cour) sous forme de cases à
/// cocher. Lorsqu'un type est coché, un champ de saisie de surface (m²)
/// apparaît en dessous. Plusieurs types peuvent être sélectionnés.
///
/// [value] : liste courante des espaces sélectionnés avec leurs surfaces.
/// [onChanged] : appelé à chaque modification.
class ExteriorSpacesCard extends StatefulWidget {
  final List<ExteriorSpace> value;
  final ValueChanged<List<ExteriorSpace>> onChanged;

  const ExteriorSpacesCard({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<ExteriorSpacesCard> createState() => _ExteriorSpacesCardState();
}

class _ExteriorSpacesCardState extends State<ExteriorSpacesCard> {
  late final Map<String, TextEditingController> _controllers;
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _controllers = {for (final t in _kTypes) t: TextEditingController()};
    _selected = {};
    for (final space in widget.value) {
      _selected.add(space.type);
      if (space.surface != null) {
        _controllers[space.type]?.text =
            space.surface!.toString().replaceAll('.0', '');
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _toggle(String type) {
    setState(() {
      if (_selected.contains(type)) {
        _selected.remove(type);
      } else {
        _selected.add(type);
      }
    });
    _notify();
  }

  void _notify() {
    final spaces = _kTypes
        .where(_selected.contains)
        .map((type) {
          final text =
              (_controllers[type]?.text ?? '').replaceAll(',', '.');
          final surface = double.tryParse(text);
          return ExteriorSpace(type: type, surface: surface);
        })
        .toList();
    widget.onChanged(spaces);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: DSpacing.md,
        vertical: DSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: DoutangTheme.cardBg,
        borderRadius: DRadius.card,
        border: Border.all(color: DoutangTheme.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              DSpacing.md,
              DSpacing.md,
              DSpacing.md,
              DSpacing.sm,
            ),
            child: Text(
              'Espaces extérieurs',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: DoutangTheme.textPrimary,
              ),
            ),
          ),
          for (final type in _kTypes) ...[
            _buildTypeRow(type),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: _selected.contains(type)
                  ? _buildSurfaceField(type)
                  : const SizedBox.shrink(),
            ),
          ],
          const SizedBox(height: DSpacing.sm),
        ],
      ),
    );
  }

  Widget _buildTypeRow(String type) {
    final selected = _selected.contains(type);
    return InkWell(
      onTap: () => _toggle(type),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DSpacing.md,
          vertical: DSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(
              _kTypeIcons[type] ?? Icons.yard_outlined,
              size: 20,
              color: selected ? DoutangTheme.primary : DoutangTheme.textHint,
            ),
            const SizedBox(width: DSpacing.sm),
            Expanded(
              child: Text(
                type,
                style: TextStyle(
                  fontSize: 15,
                  color: selected
                      ? DoutangTheme.textPrimary
                      : DoutangTheme.textSecondary,
                  fontWeight:
                      selected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: selected
                    ? DoutangTheme.primary
                    : DoutangTheme.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: selected
                      ? DoutangTheme.primary
                      : DoutangTheme.border,
                  width: selected ? 0 : 1.5,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurfaceField(String type) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DSpacing.md + 28,
        0,
        DSpacing.md,
        DSpacing.sm,
      ),
      child: TextField(
        controller: _controllers[type],
        onChanged: (_) => _notify(),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
        ],
        textInputAction: TextInputAction.done,
        style: const TextStyle(fontSize: 14, color: DoutangTheme.textPrimary),
        decoration: InputDecoration(
          hintText: 'Surface en m²',
          hintStyle: const TextStyle(
            fontSize: 13,
            color: DoutangTheme.textHint,
          ),
          suffixText: 'm²',
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: DSpacing.sm,
            vertical: DSpacing.sm,
          ),
        ),
      ),
    );
  }
}
