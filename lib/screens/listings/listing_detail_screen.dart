// listing_detail_screen.dart
import 'package:flutter/material.dart';
import '../../theme/doutang_theme.dart';
import '../../theme/app_routes.dart';
import '../../models/listing.dart';

class ListingDetailScreen extends StatelessWidget {
  const ListingDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final listing = ModalRoute.of(context)?.settings.arguments as Listing?;

    return Scaffold(
      appBar: AppBar(
        title: Text(listing?.title ?? 'Annonce'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {}, // TODO
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
                    // TODO: ScoreBar widget
                    const LinearProgressIndicator(value: 0.85),
                    const SizedBox(height: DSpacing.sm),
                    Text('85% de tes critères couverts',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(height: DSpacing.lg),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.visitQuestionnaire,
                  arguments: listing,
                ),
                icon: const Icon(Icons.door_front_door_outlined),
                label: const Text('Démarrer la visite'),
              ),
            ),
          ],
        ),
      ),
    );
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
          Text(label,
              style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(value,
              style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
