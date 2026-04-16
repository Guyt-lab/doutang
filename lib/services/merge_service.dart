import '../models/listing_facts.dart';
import '../models/profile.dart';
import '../models/listing.dart';
import '../models/project.dart';
import '../models/visit.dart';

/// Service de fusion de deux projets Doutang.
///
/// Stratégie owner-based :
/// - Profiles  : union par owner, pas de conflit
/// - Listings  : union par id, updated_at le plus récent gagne
/// - Visits    : union par (listing_id + owner), pas de conflit inter-owners
class MergeService {
  /// Fusionne [incoming] dans [local] et retourne le projet résultant.
  static DoutangProject merge(
    DoutangProject local,
    DoutangProject incoming,
  ) {
    return local.copyWith(
      profiles: _mergeProfiles(local.profiles, incoming.profiles),
      listings: _mergeListings(local.listings, incoming.listings),
      visits: _mergeVisits(local.visits, incoming.visits),
      updatedAt: DateTime.now(),
    );
  }

  /// Fusionne les profils par owner — chacun garde le sien.
  static List<UserProfile> _mergeProfiles(
    List<UserProfile> local,
    List<UserProfile> incoming,
  ) {
    final merged = Map<String, UserProfile>.fromEntries(
      local.map((p) => MapEntry(p.owner, p)),
    );

    for (final profile in incoming) {
      final existing = merged[profile.owner];
      if (existing == null) {
        // Nouveau owner — on l'ajoute
        merged[profile.owner] = profile;
      } else {
        // Owner connu — on garde le plus récent
        if (profile.updatedAt.isAfter(existing.updatedAt)) {
          merged[profile.owner] = profile;
        }
      }
    }

    return merged.values.toList();
  }

  /// Fusionne les listings par id — updated_at le plus récent gagne.
  static List<Listing> _mergeListings(
    List<Listing> local,
    List<Listing> incoming,
  ) {
    final merged = Map<String, Listing>.fromEntries(
      local.map((l) => MapEntry(l.id, l)),
    );

    for (final listing in incoming) {
      final existing = merged[listing.id];
      if (existing == null) {
        // Nouvelle annonce — on l'ajoute
        merged[listing.id] = listing;
      } else {
        // Annonce existante — la plus récente gagne, mais on fusionne les facts
        // champ par champ pour ne pas perdre d'informations.
        final Listing winner =
            listing.updatedAt.isAfter(existing.updatedAt) ? listing : existing;
        final Listing loser =
            listing.updatedAt.isAfter(existing.updatedAt) ? existing : listing;
        // Fusionne les faits champ par champ : winner en priorité, loser
        // comble les champs null que winner ne connaît pas encore.
        final ListingFacts mergedFacts = winner.facts.complement(loser.facts);
        merged[listing.id] = winner.copyWith(facts: mergedFacts);
      }
    }

    return merged.values.toList()
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
  }

  /// Fusionne les visites par (listingId, owner) — pas de conflit inter-owners.
  static List<Visit> _mergeVisits(
    List<Visit> local,
    List<Visit> incoming,
  ) {
    final key = (Visit v) => '${v.listingId}__${v.owner}';

    final merged = Map<String, Visit>.fromEntries(
      local.map((v) => MapEntry(key(v), v)),
    );

    for (final visit in incoming) {
      final k = key(visit);
      final existing = merged[k];
      if (existing == null) {
        merged[k] = visit;
      } else {
        // Même owner, même annonce — on garde la plus récente
        if (visit.updatedAt.isAfter(existing.updatedAt)) {
          merged[k] = visit;
        }
      }
    }

    return merged.values.toList()
      ..sort((a, b) => b.visitedAt.compareTo(a.visitedAt));
  }

  /// Retourne un résumé des changements apportés par le merge.
  static MergeSummary summarize(
    DoutangProject before,
    DoutangProject after,
  ) {
    final newListings = after.listings
        .where((l) => !before.listings.any((b) => b.id == l.id))
        .length;

    final newVisits = after.visits
        .where((v) => !before.visits.any((b) => b.id == v.id))
        .length;

    final newProfiles = after.profiles
        .where((p) => !before.profiles.any((b) => b.owner == p.owner))
        .length;

    return MergeSummary(
      newListings: newListings,
      newVisits: newVisits,
      newProfiles: newProfiles,
    );
  }
}

class MergeSummary {
  final int newListings;
  final int newVisits;
  final int newProfiles;

  const MergeSummary({
    required this.newListings,
    required this.newVisits,
    required this.newProfiles,
  });

  bool get hasChanges => newListings > 0 || newVisits > 0 || newProfiles > 0;

  @override
  String toString() =>
      '$newListings annonce(s), $newVisits visite(s), $newProfiles profil(s) ajouté(s)';
}
