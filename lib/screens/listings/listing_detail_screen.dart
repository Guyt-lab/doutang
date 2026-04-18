import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../models/listing.dart';
import '../../models/profile.dart';
import '../../models/visit.dart';
import '../../services/profile_storage_service.dart';
import '../../services/project_service.dart';
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
    final projectId = await ProjectService.getActiveId() ?? '';
    final profile = await ProfileStorageService.load(projectId: projectId);
    final owner = profile?.owner ?? 'Moi';
    final visits = await VisitStorageService.load(projectId: projectId);
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (listing != null &&
                        (listing.propertyKind != null ||
                            listing.transactionKind != null)) ...[
                      Wrap(
                        spacing: DSpacing.sm,
                        children: [
                          if (listing.propertyKind != null)
                            _KindBadge(
                              label: listing.propertyKind ==
                                      ListingPropertyKind.appartement
                                  ? 'Appartement'
                                  : 'Maison',
                              icon: listing.propertyKind ==
                                      ListingPropertyKind.appartement
                                  ? Icons.apartment_outlined
                                  : Icons.cottage_outlined,
                            ),
                          if (listing.transactionKind != null)
                            _KindBadge(
                              label: listing.transactionKind ==
                                      ListingTransactionKind.achat
                                  ? 'Achat'
                                  : 'Location',
                              icon: listing.transactionKind ==
                                      ListingTransactionKind.achat
                                  ? Icons.sell_outlined
                                  : Icons.key_outlined,
                            ),
                        ],
                      ),
                      const SizedBox(height: DSpacing.sm),
                      const Divider(height: 0),
                      const SizedBox(height: DSpacing.sm),
                    ],
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

            // Contact
            _buildContactCard(listing),
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

  Widget _buildContactCard(Listing? listing) {
    final contact = listing?.contact;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: listing == null
            ? null
            : () => Navigator.pushNamed(
                  context,
                  AppRoutes.listingContact,
                  arguments: listing,
                ).then((updated) {
                  if (updated is Listing && mounted) {
                    setState(() => _listing = updated);
                  }
                }),
        child: Padding(
          padding: const EdgeInsets.all(DSpacing.md),
          child: Row(
            children: [
              Icon(
                contact?.isAgency == true
                    ? Icons.business_outlined
                    : Icons.person_outline,
                color: DoutangTheme.primary,
              ),
              const SizedBox(width: DSpacing.sm),
              Expanded(
                child: contact == null || contact.isEmpty
                    ? Text(
                        'Ajouter un contact',
                        style: TextStyle(color: DoutangTheme.textSecondary),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (contact.isAgency && contact.agencyName != null)
                            Text(contact.agencyName!,
                                style: Theme.of(context).textTheme.titleSmall),
                          if (contact.contactName != null)
                            Text(contact.contactName!,
                                style: Theme.of(context).textTheme.bodyMedium),
                          if (contact.phone != null)
                            Text(contact.phone!,
                                style: TextStyle(
                                    color: DoutangTheme.textSecondary,
                                    fontSize: 13)),
                        ],
                      ),
              ),
              Icon(Icons.edit_outlined,
                  size: 18, color: DoutangTheme.textSecondary),
            ],
          ),
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
    final projectId = await ProjectService.getActiveId() ?? '';
    final profile = await ProfileStorageService.load(projectId: projectId);
    if (!mounted) return;
    await Navigator.pushNamed(
      context,
      AppRoutes.visitStart,
      arguments: {
        'listing': listing,
        'profile': profile ?? UserProfile(owner: 'Moi'),
        if (existingVisit != null) 'existingVisit': existingVisit,
      },
    );
    await _loadVisit();
  }
}

class _KindBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  const _KindBadge({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: DoutangTheme.primarySurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DoutangTheme.primary, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: DoutangTheme.primary),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: DoutangTheme.primary)),
        ],
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
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
