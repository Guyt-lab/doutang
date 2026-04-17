import 'package:flutter/material.dart';

import '../../models/listing.dart';
import '../../models/profile.dart';
import '../../models/visit.dart';
import '../../services/profile_storage_service.dart';
import '../../services/visit_storage_service.dart';
import '../../theme/app_routes.dart';
import '../../theme/doutang_theme.dart';

class ListingDetailScreen extends StatefulWidget {
  const ListingDetailScreen({super.key});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  Listing? _listing;
  Visit? _existingVisit;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final listing = ModalRoute.of(context)?.settings.arguments as Listing?;
    if (_listing == null && listing != null) {
      _listing = listing;
      _loadVisit();
    }
  }

  Future<void> _loadVisit() async {
    if (_listing == null) return;
    final profile = await ProfileStorageService.load();
    final owner = profile?.owner ?? 'Moi';
    final visits = await VisitStorageService.load();
    final found = visits.where(
      (v) => v.listingId == _listing!.id && v.owner == owner,
    );
    if (mounted) {
      setState(() {
        _existingVisit = found.isNotEmpty ? found.first : null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final listing = _listing;

    return Scaffold(
      appBar: AppBar(
        title: Text(listing?.title ?? 'Annonce'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: listing == null
                ? null
                : () => Navigator.pushNamed(
                      context,
                      AppRoutes.addListing,
                      arguments: listing,
                    ).then((_) {
                      if (context.mounted) Navigator.pop(context);
                    }),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Infos clés
            Card(
              child: Padding(
                padding: const EdgeInsets.all(DSpacing.md),
                child: Column(
                  children: [
                    _InfoRow(
                        icon: Icons.euro,
                        label: 'Prix',
                        value: listing?.price != null
                            ? '${listing!.price!.toStringAsFixed(0)} €'
                            : '—'),
                    _InfoRow(
                        icon: Icons.square_foot,
                        label: 'Surface',
                        value: listing?.surface != null
                            ? '${listing!.surface} m²'
                            : '—'),
                    _InfoRow(
                        icon: Icons.meeting_room_outlined,
                        label: 'Pièces',
                        value: listing?.rooms?.toString() ?? '—'),
                    _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Adresse',
                        value: listing?.address ?? '—'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: DSpacing.md),

            // Score matching
            Card(
              child: Padding(
                padding: const EdgeInsets.all(DSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Score matching',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: DSpacing.sm),
                    const LinearProgressIndicator(value: 0.85),
                    const SizedBox(height: DSpacing.sm),
                    Text('85% de tes critères couverts',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(height: DSpacing.lg),

            // Boutons visite
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_existingVisit != null)
              _buildVisitedActions(listing!, _existingVisit!)
            else
              _buildStartVisitButton(listing),
          ],
        ),
      ),
    );
  }

  Widget _buildStartVisitButton(Listing? listing) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: listing == null ? null : () => _startVisit(listing),
        icon: const Icon(Icons.door_front_door_outlined),
        label: const Text('Démarrer la visite'),
      ),
    );
  }

  Widget _buildVisitedActions(Listing listing, Visit existingVisit) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.visitDetail,
              arguments: {'visit': existingVisit, 'listing': listing},
            ).then((_) => _loadVisit()),
            style: ElevatedButton.styleFrom(
              backgroundColor: DoutangTheme.scoreGood,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.assignment_turned_in_outlined),
            label: const Text('Voir le bilan de visite'),
          ),
        ),
        const SizedBox(height: DSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _startVisit(listing, existingVisit: existingVisit),
            icon: const Icon(Icons.refresh_outlined),
            label: const Text('Refaire la visite'),
          ),
        ),
      ],
    );
  }

  Future<void> _startVisit(Listing listing, {Visit? existingVisit}) async {
    final profile = await ProfileStorageService.load();
    if (!mounted) return;
    await Navigator.pushNamed(
      context,
      AppRoutes.visitQuestionnaire,
      arguments: {
        'listing': listing,
        'profile': profile ?? UserProfile(owner: 'Moi'),
        if (existingVisit != null) 'existingVisit': existingVisit,
      },
    );
    await _loadVisit();
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: DoutangTheme.primary),
          const SizedBox(width: DSpacing.sm),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
