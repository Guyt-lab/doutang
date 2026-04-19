import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../models/listing.dart';
import '../../models/listing_facts.dart';
import '../../models/profile.dart';
import '../../models/visit.dart';
import '../../services/profile_storage_service.dart';
import '../../services/project_service.dart';
import '../../services/score_service.dart';
import '../../services/visit_storage_service.dart';
import '../../theme/app_routes.dart';
import '../../theme/doutang_theme.dart';
import '../../widgets/dpe_badge.dart';

class ListingDetailScreen extends StatefulWidget {
  const ListingDetailScreen({super.key});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  Listing? _listing;
  Visit? _existingVisit;
  UserProfile? _profile;
  double? _matchingScore;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final listing = ModalRoute.of(context)?.settings.arguments as Listing?;
    if (_listing == null && listing != null) {
      _listing = listing;
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (_listing == null) return;
    final projectId = await ProjectService.getActiveId() ?? '';
    final profile = await ProfileStorageService.load(projectId: projectId);
    final owner = profile?.owner ?? 'Moi';
    final visits = await VisitStorageService.load(projectId: projectId);
    final found = visits.where(
      (v) => v.listingId == _listing!.id && v.owner == owner,
    );
    final matching = profile != null && _listing != null
        ? ScoreService.calculateMatchingScore(_listing!, profile,
            facts: _listing!.facts)
        : null;
    if (mounted) {
      setState(() {
        _profile = profile;
        _existingVisit = found.isNotEmpty ? found.first : null;
        _matchingScore = matching;
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

            // Fiche technique
            _buildFactsCard(listing),
            const SizedBox(height: DSpacing.md),

            // Contact
            _buildContactCard(listing),
            const SizedBox(height: DSpacing.md),

            // Score matching
            _buildMatchingCard(listing),
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

  // ── Fiche technique ───────────────────────────────────────────────────────

  Widget _buildFactsCard(Listing? listing) {
    final facts = listing?.facts;
    final isEmpty = facts == null || facts.isEmpty;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: listing == null
            ? null
            : () => Navigator.pushNamed(
                  context,
                  AppRoutes.listingFacts,
                  arguments: listing,
                ).then((result) {
                  if (result is Listing && mounted) {
                    setState(() {
                      _listing = result;
                      if (_profile != null) {
                        _matchingScore = ScoreService.calculateMatchingScore(
                            result, _profile!,
                            facts: result.facts);
                      }
                    });
                  }
                }),
        child: Padding(
          padding: const EdgeInsets.all(DSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.home_work_outlined,
                      size: 18, color: DoutangTheme.primary),
                  const SizedBox(width: DSpacing.sm),
                  Text('Fiche technique',
                      style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  Text(
                    isEmpty ? 'Compléter →' : 'Modifier →',
                    style: const TextStyle(
                        fontSize: 13,
                        color: DoutangTheme.primary,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              if (isEmpty) ...[
                const SizedBox(height: DSpacing.sm),
                Text(
                  'Fiche non renseignée — Compléter pour améliorer le score',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: DoutangTheme.textHint),
                ),
              ] else ...[
                const SizedBox(height: DSpacing.sm),
                _FactsSummary(facts: facts),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Score matching ────────────────────────────────────────────────────────

  Widget _buildMatchingCard(Listing? listing) {
    final score = _matchingScore;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Score matching',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: DSpacing.sm),
            LinearProgressIndicator(
              value: score ?? 0.5,
              backgroundColor: DoutangTheme.border,
              valueColor: AlwaysStoppedAnimation(
                  DoutangTheme.scoreColor((score ?? 0.5) * 5)),
            ),
            const SizedBox(height: DSpacing.sm),
            Text(
              score != null
                  ? '${(score * 100).round()}% de tes critères couverts'
                  : 'Profil non configuré',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
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
                                style: const TextStyle(
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
            ).then((_) => _loadData()),
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
    await _loadData();
  }
}

// ── Résumé compact de la fiche ────────────────────────────────────────────────

class _FactsSummary extends StatelessWidget {
  const _FactsSummary({required this.facts});

  final ListingFacts facts;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];

    if (facts.dpe != null) items.add(DpeBadge(facts.dpe!));
    if (facts.surfaceTotal != null) {
      items.add(_chip('${facts.surfaceTotal!.round()} m²'));
    }
    if (facts.rooms != null) items.add(_chip('${facts.rooms} pièces'));
    if (facts.floor != null) {
      final f = facts.floor!;
      items.add(_chip(f == 0
          ? 'RDC'
          : f < 0
              ? 'Sous-sol'
              : 'Étage $f'));
    }
    if (facts.heatingType != null) {
      items.add(_chip(_heatingLabel(facts.heatingType!)));
    }
    if (facts.hasBalcony == true) items.add(_iconChip(Icons.balcony, 'Balcon'));
    if (facts.hasGarden == true) items.add(_iconChip(Icons.grass, 'Jardin'));
    if (facts.hasParking == true) {
      items.add(_iconChip(Icons.local_parking, 'Parking'));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(spacing: DSpacing.sm, runSpacing: DSpacing.xs, children: items);
  }

  Widget _chip(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: DoutangTheme.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: DoutangTheme.border),
        ),
        child: Text(label,
            style: const TextStyle(
                fontSize: 12, color: DoutangTheme.textSecondary)),
      );

  Widget _iconChip(IconData icon, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: DoutangTheme.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: DoutangTheme.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: DoutangTheme.textSecondary),
            const SizedBox(width: 3),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: DoutangTheme.textSecondary)),
          ],
        ),
      );

  String _heatingLabel(HeatingType t) => switch (t) {
        HeatingType.gaz => 'Gaz',
        HeatingType.electrique => 'Électrique',
        HeatingType.fioul => 'Fioul',
        HeatingType.pompeAChaleur => 'PAC',
        HeatingType.bois => 'Bois',
        HeatingType.climReversible => 'Clim réversible',
        HeatingType.autre => 'Autre',
      };
}

// ── Widgets partagés ──────────────────────────────────────────────────────────

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
