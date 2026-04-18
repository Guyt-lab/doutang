import 'package:flutter/material.dart';

import '../../models/listing.dart';
import '../../models/visit.dart';
import '../../services/listing_storage_service.dart';
import '../../services/project_service.dart';
import '../../services/visit_storage_service.dart';
import '../../theme/app_routes.dart';
import '../../theme/doutang_theme.dart';
import '../../widgets/empty_state.dart';

class VisitsScreen extends StatefulWidget {
  const VisitsScreen({super.key});

  @override
  State<VisitsScreen> createState() => _VisitsScreenState();
}

class _VisitsScreenState extends State<VisitsScreen> {
  List<Visit> _visits = [];
  Map<String, Listing> _listingsById = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final projectId = await ProjectService.getActiveId() ?? '';
    final visits = await VisitStorageService.load(projectId: projectId);
    final listings = await ListingStorageService.load(projectId: projectId);
    if (mounted) {
      setState(() {
        _visits = visits..sort((a, b) => b.visitedAt.compareTo(a.visitedAt));
        _listingsById = {for (final l in listings) l.id: l};
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes visites')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _visits.isEmpty
              ? const EmptyState(
                  icon: Icons.door_front_door_outlined,
                  title: 'Aucune visite',
                  subtitle:
                      'Démarre une visite depuis\nle détail d\'une annonce',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(DSpacing.md),
                  itemCount: _visits.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: DSpacing.sm),
                  itemBuilder: (context, index) {
                    final visit = _visits[index];
                    final listing = _listingsById[visit.listingId];
                    return _VisitTile(
                      visit: visit,
                      listing: listing,
                      onTap: listing == null
                          ? null
                          : () => Navigator.pushNamed(
                                context,
                                AppRoutes.visitDetail,
                                arguments: {
                                  'visit': visit,
                                  'listing': listing,
                                },
                              ).then((_) => _load()),
                    );
                  },
                ),
    );
  }
}

class _VisitTile extends StatelessWidget {
  const _VisitTile({
    required this.visit,
    required this.listing,
    required this.onTap,
  });

  final Visit visit;
  final Listing? listing;
  final VoidCallback? onTap;

  static const _feelingEmoji = ['', '😟', '😕', '😐', '😊', '😍'];

  Color get _scoreColor {
    final s = visit.score;
    if (s >= 75) return DoutangTheme.scoreExcellent;
    if (s >= 55) return DoutangTheme.scoreGood;
    if (s >= 35) return DoutangTheme.scoreMid;
    if (s >= 20) return DoutangTheme.scoreLow;
    return DoutangTheme.scorePoor;
  }

  @override
  Widget build(BuildContext context) {
    final title = listing?.title ?? 'Annonce supprimée';
    final emoji = visit.feeling >= 1 && visit.feeling <= 5
        ? _feelingEmoji[visit.feeling]
        : '😐';
    final dateStr = _formatDate(visit.visitedAt);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: DRadius.card,
        child: Padding(
          padding: const EdgeInsets.all(DSpacing.md),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _scoreColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: _scoreColor, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    visit.score.round().toString(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _scoreColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: DSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: DoutangTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$emoji  $dateStr',
                      style: const TextStyle(
                        fontSize: 12,
                        color: DoutangTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: DoutangTheme.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      '',
      'jan',
      'fév',
      'mar',
      'avr',
      'mai',
      'jun',
      'jul',
      'aoû',
      'sep',
      'oct',
      'nov',
      'déc',
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }
}
