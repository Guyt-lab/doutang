import 'package:uuid/uuid.dart';

import 'enums.dart';
import 'listing_contact.dart';
import 'listing_facts.dart';

const _uuid = Uuid();

class Listing {
  final String id;
  final String? url;
  final String title;
  final double? price;
  final double? surface;
  final int? rooms;
  final String? address;
  final ListingStatus status;
  final String notes;
  final String addedBy;
  final DateTime addedAt;
  final DateTime updatedAt;

  /// Caractéristiques factuelles du bien (owner-agnostic, remplies progressivement).
  final ListingFacts facts;

  /// Contact agence ou particulier (optionnel).
  final ListingContact? contact;

  /// Type de bien : appartement ou maison.
  final ListingPropertyKind? propertyKind;

  /// Type de transaction : achat ou location.
  final ListingTransactionKind? transactionKind;

  Listing({
    String? id,
    this.url,
    required this.title,
    this.price,
    this.surface,
    this.rooms,
    this.address,
    ListingStatus? status,
    String? notes,
    required this.addedBy,
    DateTime? addedAt,
    DateTime? updatedAt,
    ListingFacts? facts,
    this.contact,
    this.propertyKind,
    this.transactionKind,
  })  : id = id ?? _uuid.v4(),
        status = status ?? ListingStatus.aContacter,
        notes = notes ?? '',
        addedAt = addedAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        facts = facts ?? const ListingFacts();

  Listing copyWith({
    String? url,
    String? title,
    double? price,
    double? surface,
    int? rooms,
    String? address,
    ListingStatus? status,
    String? notes,
    ListingFacts? facts,
    ListingContact? contact,
    bool clearContact = false,
    ListingPropertyKind? propertyKind,
    bool clearPropertyKind = false,
    ListingTransactionKind? transactionKind,
    bool clearTransactionKind = false,
  }) {
    return Listing(
      id: id,
      url: url ?? this.url,
      title: title ?? this.title,
      price: price ?? this.price,
      surface: surface ?? this.surface,
      rooms: rooms ?? this.rooms,
      address: address ?? this.address,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      addedBy: addedBy,
      addedAt: addedAt,
      updatedAt: DateTime.now(),
      facts: facts ?? this.facts,
      contact: clearContact ? null : (contact ?? this.contact),
      propertyKind: clearPropertyKind ? null : (propertyKind ?? this.propertyKind),
      transactionKind: clearTransactionKind ? null : (transactionKind ?? this.transactionKind),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'title': title,
        'price': price,
        'surface': surface,
        'rooms': rooms,
        'address': address,
        'status': status.name,
        'notes': notes,
        'added_by': addedBy,
        'added_at': addedAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'facts': facts.toJson(),
        'contact': contact?.toJson(),
        'property_kind': propertyKind?.name,
        'transaction_kind': transactionKind?.name,
      };

  factory Listing.fromJson(Map<String, dynamic> json) => Listing(
        id: json['id'] as String,
        url: json['url'] as String?,
        title: json['title'] as String,
        price: (json['price'] as num?)?.toDouble(),
        surface: (json['surface'] as num?)?.toDouble(),
        rooms: (json['rooms'] as num?)?.toInt(),
        address: json['address'] as String?,
        status: ListingStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => ListingStatus.aContacter,
        ),
        notes: json['notes'] as String? ?? '',
        addedBy: json['added_by'] as String,
        addedAt: DateTime.parse(json['added_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        facts: json['facts'] != null
            ? ListingFacts.fromJson(json['facts'] as Map<String, dynamic>)
            : const ListingFacts(),
        contact: json['contact'] != null
            ? ListingContact.fromJson(json['contact'] as Map<String, dynamic>)
            : null,
        propertyKind: enumFromJson(
            ListingPropertyKind.values, json['property_kind'] as String?),
        transactionKind: enumFromJson(
            ListingTransactionKind.values, json['transaction_kind'] as String?),
      );
}

enum ListingStatus {
  aContacter,
  visiteePlanifiee,
  visitee,
  eliminee,
  favorite,
}

extension ListingStatusLabel on ListingStatus {
  String get label => switch (this) {
        ListingStatus.aContacter => 'À contacter',
        ListingStatus.visiteePlanifiee => 'Visite planifiée',
        ListingStatus.visitee => 'Visitée',
        ListingStatus.eliminee => 'Éliminée',
        ListingStatus.favorite => 'Favorite',
      };
}
