import '../models/listing_facts.dart';
import '../models/visit.dart';

/// Synchronisation bidirectionnelle entre [ListingFacts] et [VisitAnswers].
///
/// Utilise un round-trip JSON pour respecter les valeurs déjà saisies :
/// seuls les champs null de la cible sont écrasés.
class FactsSyncService {
  FactsSyncService._();

  /// Propage les champs de [facts] vers [existing] (VisitAnswers).
  /// Les champs déjà non-null dans [existing] ne sont pas modifiés.
  static VisitAnswers syncFactsToAnswers(
    ListingFacts facts,
    VisitAnswers existing,
  ) {
    final json = Map<String, dynamic>.from(existing.toJson());

    void set(String key, Object? value) {
      if (value != null) json[key] ??= value;
    }

    set('dpe_niveau', facts.dpe);
    set('heating_system', facts.heatingType?.name);
    set('date_construction', facts.buildingYear?.toString());
    set('charges_amount', facts.charges?.toInt().toString());
    set('parking', facts.hasParking);
    set('cave', facts.hasCellar);
    set('secure_door_ok', facts.secureDoor);
    set('fibre_immeuble', facts.fiber);
    set('kitchen_open_closed', facts.kitchenType?.name);
    if (facts.hasBalcony == true || facts.hasTerrace == true) {
      json['balcon_ou_terrasse'] ??= true;
    }

    return VisitAnswers.fromJson(json);
  }

  /// Propage les champs de [existing] (VisitAnswers) vers [facts] (ListingFacts).
  /// Les champs déjà non-null dans [facts] ne sont pas modifiés.
  static ListingFacts syncAnswersToFacts(
    VisitAnswers existing,
    ListingFacts facts,
  ) {
    final json = Map<String, dynamic>.from(facts.toJson());

    void set(String key, Object? value) {
      if (value != null) json[key] ??= value;
    }

    set('dpe', existing.dpeNiveau);
    set('charges', existing.chargesAmount != null
        ? double.tryParse(existing.chargesAmount!)
        : null);
    set('has_parking', existing.parking);
    set('has_cellar', existing.cave);
    set('secure_door', existing.secureDoorOk);
    set('fiber', existing.fibreImmeuble);
    if (existing.balconOuTerrasse == true) {
      json['has_balcony'] ??= true;
    }

    return ListingFacts.fromJson(json);
  }
}
