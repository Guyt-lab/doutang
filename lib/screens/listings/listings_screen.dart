import 'package:flutter/material.dart';

import '../../models/listing.dart';
import '../../services/listing_storage_service.dart';
import '../../services/project_service.dart';
import '../../services/visit_storage_service.dart';
import '../../theme/app_routes.dart';
import '../../theme/doutang_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/listing_card.dart';

class ListingsScreen extends StatefulWidget {
  const ListingsScreen({super.key});

  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  List<Listing> _listings = [];
  Map<String, double> _visitScoreByListingId = {};
  ListingStatus? _filterStatus;
  bool _isLoading = true;
  String _projectId = '';
  String _projectName = 'Doutang';

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    final project = await ProjectService.getActive();
    final projectId = project?.id ?? '';
    final listings = await ListingStorageService.load(projectId: projectId);
    final visits = await VisitStorageService.load(projectId: projectId);
    if (mounted) {
      setState(() {
        _projectId = projectId;
        _projectName = project?.name ?? 'Doutang';
        _listings = listings;
        _visitScoreByListingId = {
          for (final v in visits) v.listingId: v.score,
        };
        _isLoading = false;
      });
    }
  }

  List<Listing> get _filtered {
    if (_filterStatus == null) return _listings;
    return _listings.where((l) {
      if (l.status == _filterStatus) return true;
      if (_filterStatus == ListingStatus.visitee) {
        return _visitScoreByListingId.containsKey(l.id);
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final listings = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: Text(_projectName),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz_outlined),
            tooltip: 'Changer de projet',
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.projects,
              arguments: {'fromSwitch': true},
            ).then((_) => _loadListings()),
          ),
          IconButton(
            icon: const Icon(Icons.ios_share_outlined),
            tooltip: 'Partager / Importer',
            onPressed: () => _showShareSheet(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _listings.isEmpty
              ? const EmptyState(
                  icon: Icons.home_outlined,
                  title: 'Aucune annonce',
                  subtitle:
                      'Ajoute ta première annonce Jinka\nen tapant le + ci-dessous',
                )
              : Column(
                  children: [
                    _StatusFilterBar(
                      selected: _filterStatus,
                      onSelected: (s) => setState(() => _filterStatus = s),
                    ),
                    Expanded(
                      child: listings.isEmpty
                          ? Center(
                              child: Text(
                                'Aucune annonce dans cette catégorie',
                                style: TextStyle(
                                  color: DoutangTheme.textSecondary,
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(DSpacing.md),
                              itemCount: listings.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: DSpacing.sm),
                              itemBuilder: (context, index) {
                                final listing = listings[index];
                                return Dismissible(
                                  key: ValueKey(listing.id),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(
                                        right: DSpacing.md),
                                    decoration: BoxDecoration(
                                      color: DoutangTheme.danger,
                                      borderRadius: DRadius.card,
                                    ),
                                    child: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onDismissed: (_) async {
                                    await ListingStorageService.deleteById(
                                        listing.id,
                                        projectId: _projectId);
                                    _loadListings();
                                  },
                                  child: ListingCard(
                                    listing: listing,
                                    matchingScore: 0.85,
                                    visitScore:
                                        _visitScoreByListingId[listing.id],
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.listingDetail,
                                      arguments: listing,
                                    ).then((_) => _loadListings()),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addListing)
            .then((_) => _loadListings()),
        backgroundColor: DoutangTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(DSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Partage & sync',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: DSpacing.lg),
            ListTile(
              leading: const Icon(Icons.upload_outlined),
              title: const Text('Exporter mon fichier .doutang'),
              subtitle: const Text('Envoie-le à ton/ta partenaire'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text('Importer un fichier .doutang'),
              subtitle: const Text('Fusionne avec tes données'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Barre de filtre par statut ─────────────────────────────────────────────

class _StatusFilterBar extends StatelessWidget {
  final ListingStatus? selected;
  final ValueChanged<ListingStatus?> onSelected;

  const _StatusFilterBar({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: DSpacing.md,
        vertical: DSpacing.sm,
      ),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Toutes'),
            selected: selected == null,
            onSelected: (_) => onSelected(null),
          ),
          const SizedBox(width: DSpacing.sm),
          ...ListingStatus.values.map((status) => Padding(
                padding: const EdgeInsets.only(right: DSpacing.sm),
                child: FilterChip(
                  label: Text(status.label),
                  selected: selected == status,
                  onSelected: (_) => onSelected(status),
                ),
              )),
        ],
      ),
    );
  }
}
