import 'dart:convert';

import 'package:http/http.dart' as http;

/// Résultat du parsing d'une page d'annonce.
/// Tous les champs sont nullable : le parsing peut n'en trouver qu'une partie.
class ParsedListing {
  final String? title;
  final double? price;
  final double? surface;
  final int? rooms;
  final String? address;

  // ── Champs sémantiques (passe 4) ──────────────────────────────────────────
  /// 'location' ou 'achat'
  final String? transactionType;

  /// 'appartement' ou 'maison'
  final String? propertyType;

  final int? floor;

  /// Classe DPE : 'A' à 'G'
  final String? dpe;

  /// Classe GES : 'A' à 'G'
  final String? gesClass;

  final double? charges;
  final bool? hasBalcony;
  final bool? hasTerrace;
  final bool? hasGarden;
  final bool? hasParking;
  final bool? hasCellar;
  final bool? isFurnished;

  /// Valeur brute normalisée : 'gaz', 'electrique', 'pompeAChaleur', etc.
  final String? heatingType;

  // ── Champs enrichis (passes 2-4) ─────────────────────────────────────────
  final int? bedrooms;
  final int? floorsTotal;
  final bool? hasElevator;
  final bool? hasIntercom;
  final bool? hasBikeStorage;
  final double? balconySurface;
  final double? terraceSurface;
  final double? gardenSurface;

  /// true = collectif, false = individuel
  final bool? heatingCollective;
  final bool? hotWaterCollective;
  final bool? hasFireplace;
  final bool? hasBeams;
  final bool? hasMouldings;

  /// 'ouverte', 'fermee', 'semiOuverte', 'americaine'
  final String? kitchenType;

  final int? constructionYear;
  final double? energyConsumption;
  final double? agencyFees;

  /// true = via agence, false = particulier
  final bool? isAgency;

  /// true = réseau fibre disponible dans l'immeuble
  final bool? fiber;

  final String? description;

  const ParsedListing({
    this.title,
    this.price,
    this.surface,
    this.rooms,
    this.address,
    this.transactionType,
    this.propertyType,
    this.floor,
    this.dpe,
    this.gesClass,
    this.charges,
    this.hasBalcony,
    this.hasTerrace,
    this.hasGarden,
    this.hasParking,
    this.hasCellar,
    this.isFurnished,
    this.heatingType,
    this.bedrooms,
    this.floorsTotal,
    this.hasElevator,
    this.hasIntercom,
    this.hasBikeStorage,
    this.balconySurface,
    this.terraceSurface,
    this.gardenSurface,
    this.heatingCollective,
    this.hotWaterCollective,
    this.hasFireplace,
    this.hasBeams,
    this.hasMouldings,
    this.kitchenType,
    this.constructionYear,
    this.energyConsumption,
    this.agencyFees,
    this.isAgency,
    this.fiber,
    this.description,
  });

  /// Vrai si au moins un champ a été extrait.
  bool get hasAnyData =>
      title != null || price != null || surface != null || address != null;

  /// Nombre total de champs non-null extraits.
  int get extractedCount {
    int n = 0;
    if (title != null) n++;
    if (price != null) n++;
    if (surface != null) n++;
    if (rooms != null) n++;
    if (address != null) n++;
    if (transactionType != null) n++;
    if (propertyType != null) n++;
    if (floor != null) n++;
    if (dpe != null) n++;
    if (gesClass != null) n++;
    if (charges != null) n++;
    if (hasBalcony != null) n++;
    if (hasTerrace != null) n++;
    if (hasGarden != null) n++;
    if (hasParking != null) n++;
    if (hasCellar != null) n++;
    if (isFurnished != null) n++;
    if (heatingType != null) n++;
    if (bedrooms != null) n++;
    if (floorsTotal != null) n++;
    if (hasElevator != null) n++;
    if (hasIntercom != null) n++;
    if (hasBikeStorage != null) n++;
    if (balconySurface != null) n++;
    if (terraceSurface != null) n++;
    if (gardenSurface != null) n++;
    if (heatingCollective != null) n++;
    if (hotWaterCollective != null) n++;
    if (hasFireplace != null) n++;
    if (hasBeams != null) n++;
    if (hasMouldings != null) n++;
    if (kitchenType != null) n++;
    if (constructionYear != null) n++;
    if (energyConsumption != null) n++;
    if (agencyFees != null) n++;
    if (isAgency != null) n++;
    if (fiber != null) n++;
    if (description != null) n++;
    return n;
  }
}

/// Parse une page d'annonce immobilière (Jinka en priorité) pour en extraire
/// les données structurées sans dépendance à un backend.
///
/// Stratégie (ordre de priorité décroissant) :
///   1. Balises `<meta property="og:*">` — présentes sur la quasi-totalité des sites
///   2. Blocs `<script type="application/ld+json">` — données structurées schema.org
///   3. Sélecteurs CSS courants (class contenant "price", "surface", etc.)
///   4. Détection sémantique par regex sur le texte brut
///
/// [parseUrl] fait le fetch réseau ; [parseHtml] est une fonction pure testable.
class ListingParserService {
  ListingParserService._();

  static const _kTimeout = Duration(seconds: 10);
  static const _kUserAgent = 'Mozilla/5.0 (compatible; Doutang/1.0)';

  // ── API publique ──────────────────────────────────────────────────────────

  /// Télécharge la page à [url] et retourne les données extraites.
  /// Ne lève jamais d'exception : retourne un [ParsedListing] vide en cas d'erreur.
  static Future<ParsedListing> parseUrl(
    String url, {
    http.Client? client,
  }) async {
    final owned = client == null;
    final c = client ?? http.Client();
    try {
      final response = await c.get(
        Uri.parse(url),
        headers: {'User-Agent': _kUserAgent},
      ).timeout(_kTimeout);

      if (response.statusCode == 200) {
        return parseHtml(response.body);
      }
      return const ParsedListing();
    } catch (_) {
      return const ParsedListing();
    } finally {
      if (owned) c.close();
    }
  }

  /// Extrait les données depuis du HTML brut.
  /// Fonction pure : pas d'I/O, entièrement testable.
  static ParsedListing parseHtml(String html) {
    // ── Passe 1 : balises og: ─────────────────────────────────────────────
    final ogTitle = _ogTag(html, 'title');
    final ogDesc = _ogTag(html, 'description');

    double? surface = ogTitle != null ? _surface(ogTitle) : null;
    int? rooms = ogTitle != null ? _rooms(ogTitle) : null;
    String? address = ogTitle != null ? _addressFromTitle(ogTitle) : null;
    double? price = ogDesc != null ? _price(ogDesc) : null;
    surface ??= ogDesc != null ? _surface(ogDesc) : null;
    rooms ??= ogDesc != null ? _rooms(ogDesc) : null;
    String? title = ogTitle != null ? _cleanTitle(ogTitle) : null;

    final afterOg = ParsedListing(
      title: title?.isNotEmpty == true ? title : null,
      price: price,
      surface: surface,
      rooms: rooms,
      address: address?.isNotEmpty == true ? address : null,
    );

    // ── Passe 2 : JSON-LD ─────────────────────────────────────────────────
    final afterJsonLd = _jsonLdPass(html, afterOg);

    // ── Passe 3 : sélecteurs CSS ──────────────────────────────────────────
    final afterCss = ParsedListing(
      title: afterJsonLd.title ?? _titleFromHtml(html),
      price: afterJsonLd.price ?? _priceFromHtml(html),
      surface: afterJsonLd.surface ?? _surfaceFromHtml(html),
      rooms: afterJsonLd.rooms,
      address: afterJsonLd.address ?? _addressFromHtml(html),
      bedrooms: afterJsonLd.bedrooms,
      floorsTotal: afterJsonLd.floorsTotal,
      floor: afterJsonLd.floor,
      description: afterJsonLd.description,
    );

    // ── Passe 4 : détection sémantique sur texte brut ─────────────────────
    return _semanticPass(html, afterCss);
  }

  // ── Passe JSON-LD ─────────────────────────────────────────────────────────

  static ParsedListing _jsonLdPass(String html, ParsedListing current) {
    final scriptRe = RegExp(
      r'<script\b[^>]*application/ld\+json[^>]*>([\s\S]*?)</script>',
      caseSensitive: false,
    );

    String? title = current.title;
    double? price = current.price;
    double? surface = current.surface;
    int? rooms = current.rooms;
    String? address = current.address;
    int? bedrooms;
    int? floorsTotal;
    int? floor = current.floor;
    String? description;

    for (final match in scriptRe.allMatches(html)) {
      final content = match.group(1)?.trim();
      if (content == null || content.isEmpty) continue;

      try {
        final dynamic raw = jsonDecode(content);
        final items = raw is List ? raw.cast<dynamic>() : [raw];
        for (final dynamic item in items) {
          if (item is! Map<String, dynamic>) continue;

          // titre
          title ??=
              (item['name'] as String?) ?? (item['headline'] as String?);

          // description
          description ??= item['description'] as String?;

          // prix
          if (price == null) {
            final offers = item['offers'];
            if (offers is Map<String, dynamic>) {
              price = (offers['price'] as num?)?.toDouble();
            } else if (offers is List && offers.isNotEmpty) {
              final first = offers.first;
              if (first is Map<String, dynamic>) {
                price = (first['price'] as num?)?.toDouble();
              }
            }
            price ??= (item['price'] as num?)?.toDouble();
          }

          // surface (floorSize schema.org)
          if (surface == null) {
            final fs = item['floorSize'];
            if (fs is Map<String, dynamic>) {
              surface = (fs['value'] as num?)?.toDouble();
            }
          }

          // pièces
          rooms ??= (item['numberOfRooms'] as num?)?.toInt();

          // chambres
          bedrooms ??= (item['numberOfBedrooms'] as num?)?.toInt();

          // étages immeuble
          floorsTotal ??= (item['numberOfFloors'] as num?)?.toInt();

          // étage du logement
          floor ??= (item['floorLevel'] as num?)?.toInt();

          // adresse
          if (address == null) {
            final addr = item['address'];
            if (addr is Map<String, dynamic>) {
              address = (addr['addressLocality'] as String?) ??
                  (addr['addressRegion'] as String?);
            } else if (addr is String) {
              address = addr;
            }
          }
        }
      } catch (_) {
        // Bloc JSON-LD malformé — on passe
      }
    }

    return ParsedListing(
      title: title,
      price: price,
      surface: surface,
      rooms: rooms,
      address: address,
      floor: floor,
      bedrooms: bedrooms,
      floorsTotal: floorsTotal,
      description: description,
    );
  }

  // ── Passe sémantique ──────────────────────────────────────────────────────

  static ParsedListing _semanticPass(String html, ParsedListing current) {
    final text = html
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .toLowerCase();

    // Transaction
    String? transactionType = current.transactionType;
    if (transactionType == null) {
      if (RegExp(r'\b(louer|location|loyer|à louer)\b').hasMatch(text) ||
          RegExp(r'€\s*/\s*mois').hasMatch(text)) {
        transactionType = 'location';
      } else if (RegExp(r'\b(acheter|achat|vente|vendre|à vendre)\b')
          .hasMatch(text)) {
        transactionType = 'achat';
      }
    }

    // Type de bien
    String? propertyType = current.propertyType;
    if (propertyType == null) {
      if (RegExp(r'\b(appartement|appart\b|studio|duplex|triplex|loft)\b')
          .hasMatch(text)) {
        propertyType = 'appartement';
      } else if (RegExp(r'\b(maison|villa|pavillon|chalet)\b').hasMatch(text)) {
        propertyType = 'maison';
      }
    }

    // Étage
    int? floor = current.floor;
    if (floor == null) {
      final floorRe = RegExp(
        r'(\d+)(?:e|er|ème|eme)\s*étage|étage\s*(\d+)|au\s+(\d+)(?:e|er|ème|eme)',
      );
      final floorM = floorRe.firstMatch(text);
      if (floorM != null) {
        floor = int.tryParse(
            floorM.group(1) ?? floorM.group(2) ?? floorM.group(3) ?? '');
      }
      if (floor == null && RegExp(r'rez[\s-]de[\s-]chauss').hasMatch(text)) {
        floor = 0;
      }
    }

    // DPE
    String? dpe = current.dpe;
    if (dpe == null) {
      final dpeRe = RegExp(
        r'\bdpe\s*:?\s*([a-g])\b|classe\s+([a-g])\b|lettre\s+([a-g])\b',
        caseSensitive: false,
      );
      final dpeM = dpeRe.firstMatch(text);
      if (dpeM != null) {
        dpe = (dpeM.group(1) ?? dpeM.group(2) ?? dpeM.group(3))?.toUpperCase();
      }
    }

    // GES
    String? gesClass = current.gesClass;
    if (gesClass == null) {
      final gesRe = RegExp(
        r'\bges\s*:?\s*([a-g])\b|émissions?\s+ges\s*:?\s*([a-g])\b',
        caseSensitive: false,
      );
      final gesM = gesRe.firstMatch(text);
      if (gesM != null) {
        gesClass = (gesM.group(1) ?? gesM.group(2))?.toUpperCase();
      }
    }

    // Charges
    double? charges;
    final chargesRe = RegExp(
      r'charges?\s*:?\s*(\d[\d\s\u00a0]*)\s*€'
      r'|(\d[\d\s\u00a0]*)\s*€\s*de\s+charges?',
    );
    final chargesM = chargesRe.firstMatch(text);
    if (chargesM != null) {
      final raw = (chargesM.group(1) ?? chargesM.group(2))
          ?.replaceAll(RegExp(r'[\s\u00a0]'), '');
      charges = double.tryParse(raw ?? '');
    }

    // Équipements booléens (contexte négatif détecté avant positif)
    final hasBalcony =
        current.hasBalcony ?? (text.contains('balcon') ? true : null);
    final hasTerrace =
        current.hasTerrace ?? (text.contains('terrasse') ? true : null);
    bool? gardenDetected;
    if (RegExp(r'(?:sans|pas\s+de|aucun(?:e)?)\s+jardin\b').hasMatch(text)) {
      gardenDetected = false;
    } else if (text.contains('jardin')) {
      gardenDetected = true;
    }
    final hasGarden = current.hasGarden ?? gardenDetected;
    bool? parkingDetected;
    if (RegExp(r'(?:sans|pas\s+de|aucun(?:e)?|ni)\s+(?:parking|garage|stationnement)\b')
        .hasMatch(text)) {
      parkingDetected = false;
    } else if (RegExp(r'\b(parking|garage|stationnement)\b').hasMatch(text)) {
      parkingDetected = true;
    }
    final hasParking = current.hasParking ?? parkingDetected;
    bool? cellarDetected;
    if (RegExp(r'(?:sans|pas\s+de|aucun(?:e)?)\s+cave\b').hasMatch(text)) {
      cellarDetected = false;
    } else if (text.contains('cave')) {
      cellarDetected = true;
    }
    final hasCellar = current.hasCellar ?? cellarDetected;

    // Ascenseur
    final hasElevator =
        RegExp(r'\bascenseur\b').hasMatch(text) ? true : null;

    // Digicode / interphone
    final hasIntercom =
        RegExp(r'\b(digicode|interphone|visiophone|intercom)\b').hasMatch(text)
            ? true
            : null;

    // Local vélos
    final hasBikeStorage =
        RegExp(r'local\s+v[eé]los?|box\s+v[eé]los?|abri\s+v[eé]los?')
                .hasMatch(text)
            ? true
            : null;

    // Cheminée
    final hasFireplace =
        RegExp(r'\bchemin[eé]e\b').hasMatch(text) ? true : null;

    // Poutres apparentes
    final hasBeams =
        RegExp(r'poutres?\s+apparentes?|poutres?\s+en\s+bois').hasMatch(text)
            ? true
            : null;

    // Moulures
    final hasMouldings =
        RegExp(r'\bmoulures?\b').hasMatch(text) ? true : null;

    // Fibre
    final fiber =
        RegExp(r'fibr[eé]|ftth|\bthd\b').hasMatch(text) ? true : null;

    // Chambres
    int? bedrooms = current.bedrooms;
    if (bedrooms == null) {
      final bedroomRe = RegExp(r'(\d+)\s*chambre[s]?');
      final bedroomM = bedroomRe.firstMatch(text);
      if (bedroomM != null) {
        bedrooms = int.tryParse(bedroomM.group(1) ?? '');
      }
    }

    // Nombre d'étages de l'immeuble
    int? floorsTotal = current.floorsTotal;
    if (floorsTotal == null) {
      final floorsTotalRe = RegExp(
        r'immeuble\s+de\s+(\d+)\s+[eé]tages?'
        r'|(\d+)\s+[eé]tages?\s+(?:au\s+total|en\s+tout)',
      );
      final ftM = floorsTotalRe.firstMatch(text);
      if (ftM != null) {
        floorsTotal = int.tryParse(ftM.group(1) ?? ftM.group(2) ?? '');
      }
    }

    // Meublé
    bool? isFurnished = current.isFurnished;
    if (isFurnished == null) {
      if (RegExp(r'\bnon[\s-]meublé').hasMatch(text)) {
        isFurnished = false;
      } else if (RegExp(r'\bmeublé').hasMatch(text)) {
        isFurnished = true;
      }
    }

    // Chauffage — type
    String? heatingType = current.heatingType;
    if (heatingType == null) {
      if (RegExp(r'chauffage\s+(?:au\s+)?gaz|gaz\s+(?:individuel|collectif)')
          .hasMatch(text)) {
        heatingType = 'gaz';
      } else if (RegExp(r'chauffage\s+électrique|électrique').hasMatch(text)) {
        heatingType = 'electrique';
      } else if (RegExp(r'pompe\s+[aà]\s+chaleur|\bpac\b').hasMatch(text)) {
        heatingType = 'pompeAChaleur';
      } else if (RegExp(r'plancher\s+chauffant').hasMatch(text)) {
        heatingType = 'plancherChauffant';
      } else if (RegExp(r'chauffage\s+(?:au\s+)?fioul').hasMatch(text)) {
        heatingType = 'fioul';
      } else if (RegExp(r'chauffage\s+(?:au\s+)?bois|po[eê]le\s+[àa]\s+bois')
          .hasMatch(text)) {
        heatingType = 'bois';
      } else if (RegExp(r'clim(?:atisation)?\s+réversible|clim\s+réversible')
          .hasMatch(text)) {
        heatingType = 'climReversible';
      }
    }

    // Chauffage — mode (collectif/individuel)
    bool? heatingCollective;
    if (RegExp(r'chauffage\s+collectif').hasMatch(text)) {
      heatingCollective = true;
    } else if (RegExp(r'chauffage\s+individuel').hasMatch(text)) {
      heatingCollective = false;
    }

    // Eau chaude collective
    bool? hotWaterCollective;
    if (RegExp(r'eau\s+chaude\s+collective').hasMatch(text)) {
      hotWaterCollective = true;
    } else if (RegExp(r'eau\s+chaude\s+individuelle').hasMatch(text)) {
      hotWaterCollective = false;
    }

    // Cuisine — type
    String? kitchenType;
    if (RegExp(r'cuisine\s+américaine|coin\s+cuisine').hasMatch(text)) {
      kitchenType = 'americaine';
    } else if (RegExp(r'cuisine\s+semi[\s-]ouverte').hasMatch(text)) {
      kitchenType = 'semiOuverte';
    } else if (RegExp(r'cuisine\s+ouverte').hasMatch(text)) {
      kitchenType = 'ouverte';
    } else if (RegExp(
            r'cuisine\s+(?:fermée|séparée|indépendante|équipée\s+fermée)')
        .hasMatch(text)) {
      kitchenType = 'fermee';
    }

    // Surfaces extérieures
    double? balconySurface;
    final balconySurfRe = RegExp(
      r'balcon\s+(?:de\s+)?(\d+(?:[.,]\d+)?)\s*m|(\d+(?:[.,]\d+)?)\s*m[²2]\s+de\s+balcon',
    );
    final bsM = balconySurfRe.firstMatch(text);
    if (bsM != null) {
      balconySurface = double.tryParse(
          (bsM.group(1) ?? bsM.group(2) ?? '').replaceAll(',', '.'));
    }

    double? terraceSurface;
    final terraceSurfRe = RegExp(
      r'terrasse\s+(?:de\s+)?(\d+(?:[.,]\d+)?)\s*m|(\d+(?:[.,]\d+)?)\s*m[²2]\s+de\s+terrasse',
    );
    final tsM = terraceSurfRe.firstMatch(text);
    if (tsM != null) {
      terraceSurface = double.tryParse(
          (tsM.group(1) ?? tsM.group(2) ?? '').replaceAll(',', '.'));
    }

    double? gardenSurface;
    final gardenSurfRe = RegExp(
      r'jardin\s+(?:de\s+)?(\d+(?:[.,]\d+)?)\s*m|(\d+(?:[.,]\d+)?)\s*m[²2]\s+de\s+jardin',
    );
    final gsM = gardenSurfRe.firstMatch(text);
    if (gsM != null) {
      gardenSurface = double.tryParse(
          (gsM.group(1) ?? gsM.group(2) ?? '').replaceAll(',', '.'));
    }

    // Année de construction
    int? constructionYear;
    final yearRe = RegExp(
      r'(?:construit|construction|bâti|réalisé|immeuble)\s+(?:en\s+)?((?:19|20)\d{2})'
      r'|(?:de\s+)?((?:19|20)\d{2})\s*(?:—|-)?(?:\s*rénovation)?',
    );
    final yearM = yearRe.firstMatch(text);
    if (yearM != null) {
      constructionYear =
          int.tryParse(yearM.group(1) ?? yearM.group(2) ?? '');
    }

    // Consommation énergétique (kWh/m²/an)
    double? energyConsumption;
    final energyRe = RegExp(
      r'(\d+(?:[.,]\d+)?)\s*kwh?(?:/m[²2])?(?:/an)?',
      caseSensitive: false,
    );
    final energyM = energyRe.firstMatch(text);
    if (energyM != null) {
      energyConsumption = double.tryParse(
          energyM.group(1)!.replaceAll(',', '.'));
    }

    // Honoraires d'agence
    double? agencyFees;
    final feesRe = RegExp(
      r"honoraires?\s*:?\s*(\d[\d\s\u00a0]*)\s*€|frais\s+d'agence\s*:?\s*(\d[\d\s\u00a0]*)\s*€",
    );
    final feesM = feesRe.firstMatch(text);
    if (feesM != null) {
      final raw = (feesM.group(1) ?? feesM.group(2))
          ?.replaceAll(RegExp(r'[\s\u00a0]'), '');
      agencyFees = double.tryParse(raw ?? '');
    }

    // Via agence ou particulier (particulier vérifié en premier car peut coexister)
    bool? isAgency;
    if (RegExp(r'\bparticulier\b|entre\s+particuliers?').hasMatch(text)) {
      isAgency = false;
    } else if (RegExp(r'\bagence\s+immobili[eè]re\b|\bcabinet\s+immobilier\b|\bagence\b')
        .hasMatch(text)) {
      isAgency = true;
    }

    return ParsedListing(
      title: current.title,
      price: current.price,
      surface: current.surface,
      rooms: current.rooms,
      address: current.address,
      transactionType: transactionType,
      propertyType: propertyType,
      floor: floor,
      dpe: dpe,
      gesClass: gesClass,
      charges: charges,
      hasBalcony: hasBalcony,
      hasTerrace: hasTerrace,
      hasGarden: hasGarden,
      hasParking: hasParking,
      hasCellar: hasCellar,
      isFurnished: isFurnished,
      heatingType: heatingType,
      bedrooms: bedrooms,
      floorsTotal: floorsTotal,
      hasElevator: hasElevator,
      hasIntercom: hasIntercom,
      hasBikeStorage: hasBikeStorage,
      balconySurface: balconySurface,
      terraceSurface: terraceSurface,
      gardenSurface: gardenSurface,
      heatingCollective: heatingCollective,
      hotWaterCollective: hotWaterCollective,
      hasFireplace: hasFireplace,
      hasBeams: hasBeams,
      hasMouldings: hasMouldings,
      kitchenType: kitchenType,
      constructionYear: constructionYear,
      energyConsumption: energyConsumption,
      agencyFees: agencyFees,
      isAgency: isAgency,
      fiber: fiber,
      description: current.description,
    );
  }

  // ── Helpers : og: meta tags ───────────────────────────────────────────────

  static String? _ogTag(String html, String property) {
    final tagPattern =
        '<meta\\b[^>]+property="og:${RegExp.escape(property)}"[^>]*>';
    final tagRe = RegExp(tagPattern, caseSensitive: false);
    final tagMatch = tagRe.firstMatch(html);
    if (tagMatch == null) return null;

    final contentRe = RegExp(r'content="([^"]*)"', caseSensitive: false);
    return contentRe.firstMatch(tagMatch.group(0)!)?.group(1);
  }

  // ── Helpers : extraction de valeurs depuis une chaîne ────────────────────

  static double? _price(String text) {
    final re = RegExp(r'(\d[\d\u00a0\s]*\d|\d{1,7})\s*€', caseSensitive: false);
    final m = re.firstMatch(text);
    if (m == null) return null;
    final digits = m.group(1)!.replaceAll(RegExp(r'[\s\u00a0]'), '');
    return double.tryParse(digits);
  }

  static double? _surface(String text) {
    final re = RegExp(r'(\d+(?:[.,]\d+)?)\s*m[²2]', caseSensitive: false);
    final m = re.firstMatch(text);
    if (m == null) return null;
    return double.tryParse(m.group(1)!.replaceAll(',', '.'));
  }

  static int? _rooms(String text) {
    final pieceRe = RegExp(r'(\d+)\s*pi[eè]ces?', caseSensitive: false);
    final pieceMatch = pieceRe.firstMatch(text);
    if (pieceMatch != null) return int.tryParse(pieceMatch.group(1)!);

    final typeRe = RegExp(r'\b[TF](\d)\b|\b(\d)P\b', caseSensitive: false);
    final typeMatch = typeRe.firstMatch(text);
    if (typeMatch != null) {
      return int.tryParse(typeMatch.group(1) ?? typeMatch.group(2) ?? '');
    }
    return null;
  }

  static String? _addressFromTitle(String title) {
    var t = title;
    final pipeIdx = t.indexOf(' | ');
    if (pipeIdx != -1) t = t.substring(0, pipeIdx);

    for (final sep in [' - ', ' – ']) {
      final idx = t.lastIndexOf(sep);
      if (idx != -1) return t.substring(idx + sep.length).trim();
    }
    return null;
  }

  static String _cleanTitle(String title) {
    var t = title;
    final pipeIdx = t.indexOf(' | ');
    if (pipeIdx != -1) t = t.substring(0, pipeIdx);
    for (final sep in [' - ', ' – ']) {
      final idx = t.lastIndexOf(sep);
      if (idx != -1) {
        t = t.substring(0, idx);
        break;
      }
    }
    return t.trim();
  }

  // ── Helpers : sélecteurs CSS dans le HTML brut ───────────────────────────

  static double? _priceFromHtml(String html) {
    final classRe = RegExp(
      r'class="[^"]*(?:price|prix|loyer|tarif|rent|cost)[^"]*"[^>]*>\s*([^<]+)',
      caseSensitive: false,
    );
    final m = classRe.firstMatch(html);
    if (m != null) {
      final content = m.group(1)!.trim();
      final withEuro = _price(content);
      if (withEuro != null) return withEuro;
      final numOnly = RegExp(r'^[\s\u00a0]*(\d[\d\s\u00a0]*\d|\d+)[\s\u00a0]*$')
          .firstMatch(content);
      if (numOnly != null) {
        return double.tryParse(
          numOnly.group(1)!.replaceAll(RegExp(r'[\s\u00a0]'), ''),
        );
      }
    }
    final perMoisRe = RegExp(
      r'(\d[\d\s\u00a0]*\d|\d)\s*€\s*/\s*mois',
      caseSensitive: false,
    );
    final m2 = perMoisRe.firstMatch(html);
    if (m2 != null) {
      return double.tryParse(
        m2.group(1)!.replaceAll(RegExp(r'[\s\u00a0]'), ''),
      );
    }
    return null;
  }

  static double? _surfaceFromHtml(String html) {
    final classRe = RegExp(
      r'class="[^"]*(?:surface|superficie|area)[^"]*"[^>]*>\s*([^<]+)',
      caseSensitive: false,
    );
    final m = classRe.firstMatch(html);
    if (m != null) return _surface(m.group(1)!);
    return null;
  }

  static String? _titleFromHtml(String html) {
    final h1Re = RegExp(r'<h1[^>]*>\s*([^<]+)\s*</h1>', caseSensitive: false);
    final h1 = h1Re.firstMatch(html);
    if (h1 != null) return h1.group(1)!.trim();

    final titleRe =
        RegExp(r'<title[^>]*>([^<]+)</title>', caseSensitive: false);
    final titleM = titleRe.firstMatch(html);
    if (titleM != null) return _cleanTitle(titleM.group(1)!.trim());
    return null;
  }

  static String? _addressFromHtml(String html) {
    final classRe = RegExp(
      r'class="[^"]*(?:location|address|adresse|localisation|ville|city)[^"]*"[^>]*>\s*([^<]+)',
      caseSensitive: false,
    );
    return classRe.firstMatch(html)?.group(1)?.trim();
  }
}
