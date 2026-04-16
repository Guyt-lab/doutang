import 'package:flutter/material.dart';

import '../../models/listing.dart';
import '../../services/listing_storage_service.dart';
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
  ListingStatus? _filterStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    final listings = await ListingStorageService.load();
    if (mounted) {
      setState(() {
        _listings = listings;
        _isLoading = false;
      });
    }
  }

  List<Listing> get _filtered => _filterStatus == null
      ? _listings
      : _listings.where((l) => l.status == _filterStatus).toList();

  @override
  Widget build(BuildContext context) {
    final listings = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doutang'),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_outlined),
            tooltip: 'Partager / Importer',
            onPressed: () => _showShareSheet(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : listings.isEmpty
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
                      child: ListView.separated(
                        padding: const EdgeInsets.all(DSpacing.md),
                        itemCount: listings.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: DSpacing.sm),
                        itemBuilder: (context, index) {
                          return ListingCard(
                            listing: listings[index],
                            matchingScore: 0.85,
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.listingDetail,
                              arguments: listings[index],
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
                // TODO: FileService.export()
              },
            ),
            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text('Importer un fichier .doutang'),
              subtitle: const Text('Fusionne avec tes données'),
              onTap: () {
                Navigator.pop(context);
                // TODO: FileService.import() + MergeService.merge()
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
