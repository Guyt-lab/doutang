import 'package:flutter/material.dart';

import '../../models/listing.dart';
import '../../models/profile.dart';
import '../../models/visit.dart';
import '../../theme/app_routes.dart';
import '../../theme/doutang_theme.dart';

/// Écran intermédiaire avant le questionnaire : choix de la date et de l'heure
/// de la visite.
///
/// Reçoit via [settings.arguments] un `Map<String, dynamic>` avec :
/// - `'listing'`       : [Listing]
/// - `'profile'`       : [UserProfile]
/// - `'existingVisit'` : [Visit] (optionnel, mode ré-édition)
class VisitStartScreen extends StatefulWidget {
  final Listing listing;
  final UserProfile profile;
  final Visit? existingVisit;

  const VisitStartScreen({
    super.key,
    required this.listing,
    required this.profile,
    this.existingVisit,
  });

  @override
  State<VisitStartScreen> createState() => _VisitStartScreenState();
}

class _VisitStartScreenState extends State<VisitStartScreen> {
  late DateTime _date;
  late TimeOfDay _time;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingVisit?.visitedAt;
    _date = existing ?? DateTime.now();
    _time = existing != null
        ? TimeOfDay(hour: existing.hour, minute: existing.minute)
        : TimeOfDay.now();
  }

  String get _formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(_date.year, _date.month, _date.day);
    if (selected == today) return "Aujourd'hui";
    final diff = selected.difference(today).inDays;
    if (diff == -1) return 'Hier';
    return '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}';
  }

  String get _formattedTime =>
      '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null && mounted) setState(() => _time = picked);
  }

  void _start() {
    final visitedAt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.visitQuestionnaire,
      arguments: {
        'listing': widget.listing,
        'profile': widget.profile,
        if (widget.existingVisit != null) 'existingVisit': widget.existingVisit,
        'visitedAt': visitedAt,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Démarrer la visite'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(DSpacing.md),
        children: [
          Text(
            widget.listing.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: DoutangTheme.textSecondary,
                ),
          ),
          const SizedBox(height: DSpacing.lg),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: const Text('Date de la visite'),
                  trailing: Text(
                    _formattedDate,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: DoutangTheme.primary,
                        ),
                  ),
                  onTap: _pickDate,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.access_time_outlined),
                  title: const Text('Heure de la visite'),
                  trailing: Text(
                    _formattedTime,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: DoutangTheme.primary,
                        ),
                  ),
                  onTap: _pickTime,
                ),
              ],
            ),
          ),
          const SizedBox(height: DSpacing.xs),
          Padding(
            padding: const EdgeInsets.only(left: DSpacing.sm),
            child: Text(
              "L'heure aide à interpréter la luminosité observée.",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: DoutangTheme.textSecondary,
                  ),
            ),
          ),
          const SizedBox(height: DSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _start,
              icon: const Icon(Icons.play_arrow_outlined),
              label: const Text('Commencer le questionnaire'),
            ),
          ),
        ],
      ),
    );
  }
}
