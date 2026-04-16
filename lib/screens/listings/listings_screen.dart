import 'package:flutter/material.dart';
import '../../theme/doutang_theme.dart';
import '../../theme/app_routes.dart';
import '../../models/listing.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/empty_state.dart';

class ListingsScreen extends StatelessWidget {
  const ListingsScreen({super.key});

  // TODO: Remplacer par un provider/state management
  List<Listing> get _mockListings => [
        Listing(
          id: 'mock-1',
          title: 'Bel appart 2P lumineux — Paris 11',
          price: 1350,
          surface: 48,
          rooms: 2,
          address: 'Paris 11ème',
          addedBy: 'Moi',
          status: ListingStatus.aContacter,
        ),
        Listing(
          id: 'mock-2',
          title: 'Studio rénové avec balcon',
          price: 980,
          surface: 32,
          rooms: 1,
          address: 'Montreuil',
          addedBy: 'Moi',
          status: ListingStatus.visiteePlanifiee,
        ),
        Listing(
          id: 'mock-3',
          title: '3P calme cour intérieure',
          price: 1650,
          surface: 65,
          rooms: 3,
          address: 'Paris 12ème',
          addedBy: 'Moi',
          status: ListingStatus.visitee,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final listings = _mockListings;

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
      body: listings.isEmpty
          ? const EmptyState(
              icon: Icons.home_outlined,
              title: 'Aucune annonce',
              subtitle:
                  'Ajoute ta première annonce Jinka\nen tapant le + ci-dessous',
            )
          : Column(
              children: [
                _StatusFilterBar(),
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
        onPressed: () =>
            Navigator.pushNamed(context, AppRoutes.addListing),
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

class _StatusFilterBar extends StatefulWidget {
  @override
  State<_StatusFilterBar> createState() => _StatusFilterBarState();
}

class _StatusFilterBarState extends State<_StatusFilterBar> {
  ListingStatus? _selected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
          horizontal: DSpacing.md, vertical: DSpacing.sm),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Toutes'),
            selected: _selected == null,
            onSelected: (_) => setState(() => _selected = null),
          ),
          const SizedBox(width: DSpacing.sm),
          ...ListingStatus.values.map((status) => Padding(
                padding: const EdgeInsets.only(right: DSpacing.sm),
                child: FilterChip(
                  label: Text(status.label),
                  selected: _selected == status,
                  onSelected: (_) =>
                      setState(() => _selected = status),
                ),
              )),
        ],
      ),
    );
  }
}
