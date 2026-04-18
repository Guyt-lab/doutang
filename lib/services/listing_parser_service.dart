import 'package:http/http.dart' as http;

/// Résultat du parsing d'une page d'annonce.
/// Tous les champs sont nullable : le parsing peut n'en trouver qu'une partie.
class ParsedListing {
  final String? title;
  final double? price;
  final double? surface;
  final int? rooms;
  final String? address;

  // ── Champs sémantiques (passe 3) ──────────────────────────────────────────
  /// 'location' ou 'achat'
  final String? transactionType;

  /// 'appartement' ou 'maison'
  final String? propertyType;

  final int? floor;

  /// Classe DPE : 'A' à 'G'
  final String? dpe;

  final double? charges;
  final bool? hasBalcony;
  final bool? hasTerrace;
  final bool? hasGarden;
  final bool? hasParking;
  final bool? hasCellar;
  final bool? isFurnished;

  /// Valeur brute normalisée : 'gaz', 'electrique', 'pompeAChaleur', etc.
  final String? heatingType;

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
    this.charges,
    this.hasBalcony,
    this.hasTerrace,
    this.hasGarden,
    this.hasParking,
    this.hasCellar,
    this.isFurnished,
    this.heatingType,
  });

  /// Vrai si au moins un champ a été extrait.
  bool get hasAnyData =>
      title != null || price != null || surface != null || address != null;
}

/// Parse une page d'annonce immobilière (Jinka en priorité) pour en extraire
/// les données structurées sans dépendance à un backend.
///
/// Stratégie :
///   1. Balises `<meta property="og:*">` — présentes sur la quasi-totalité des sites
///   2. Sélecteurs CSS courants (class contenant "price", "surface", etc.)
///   3. Détection sémantique par regex sur le texte brut
///
/// [parseUrl] fait le fetch réseau ; [parseHtml] est une fonction pure testable.
class ListingParserService {
  ListingParserService._();

  static const _kTimeout = Duration(seconds: 10);
  static const _kUserAgent = 'Mozilla/5.0 (compatible; Doutang/1.0)';

  // ── API publique ──────────────────────────────────────────────────────────

  /// Télécharge la page à [url] et retourne les données extraites.
  /// Ne lève jamais d'exception : retourne un [ParsedListing] vide en cas d'erreur.
  ///
  /// Injectez [client] pour les tests ou pour partager un client HTTP.
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
    // — Priorité 1 : balises og: —
    final ogTitle = _ogTag(html, 'title');
    final ogDesc = _ogTag(html, 'description');

    // Extraction structurée depuis og:title
    // Format typique Jinka : "Appartement 2 pièces, 48 m² - Paris 11ème"
    double? surface = ogTitle != null ? _surface(ogTitle) : null;
    int? rooms = ogTitle != null ? _rooms(ogTitle) : null;
    String? address = ogTitle != null ? _addressFromTitle(ogTitle) : null;

    // Extraction depuis og:description (souvent le résumé textuel complet)
    double? price = ogDesc != null ? _price(ogDesc) : null;
    surface ??= ogDesc != null ? _surface(ogDesc) : null;
    rooms ??= ogDesc != null ? _rooms(ogDesc) : null;

    // Titre nettoyé pour affichage (sans "- Ville | Site")
    String? title = ogTitle != null ? _cleanTitle(ogTitle) : null;

    // — Priorité 2 : sélecteurs CSS —
    price ??= _priceFromHtml(html);
    surface ??= _surfaceFromHtml(html);
    title ??= _titleFromHtml(html);
    address ??= _addressFromHtml(html);

    final partial = ParsedListing(
      title: title?.isNotEmpty == true ? title : null,
      price: price,
      surface: surface,
      rooms: rooms,
      address: address?.isNotEmpty == true ? address : null,
    );

    // — Priorité 3 : détection sémantique sur texte brut —
    return _semanticPass(html, partial);
  }

  // ── Passe sémantique ──────────────────────────────────────────────────────

  static ParsedListing _semanticPass(String html, ParsedListing current) {
    // Texte brut sans balises HTML, en minuscules pour la détection
    final text = html
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .toLowerCase();

    // Transaction
    String? transactionType;
    if (RegExp(r'\b(louer|location|loyer|à louer)\b').hasMatch(text)) {
      transactionType = 'location';
    } else if (RegExp(r'\b(acheter|achat|vente|vendre|à vendre)\b')
        .hasMatch(text)) {
      transactionType = 'achat';
    }

    // Type de bien
    String? propertyType;
    if (RegExp(r'\b(appartement|appart\b|studio|duplex|triplex|loft)\b')
        .hasMatch(text)) {
      propertyType = 'appartement';
    } else if (RegExp(r'\b(maison|villa|pavillon|chalet)\b').hasMatch(text)) {
      propertyType = 'maison';
    }

    // Étage
    int? floor;
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

    // DPE
    String? dpe;
    final dpeRe = RegExp(
      r'\bdpe\s*:?\s*([a-g])\b|classe\s+([a-g])\b|lettre\s+([a-g])\b',
      caseSensitive: false,
    );
    final dpeM = dpeRe.firstMatch(text);
    if (dpeM != null) {
      dpe = (dpeM.group(1) ?? dpeM.group(2) ?? dpeM.group(3))?.toUpperCase();
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

    // Équipements booléens — présence du mot = true, pas d'absence = null
    final hasBalcony =
        current.hasBalcony ?? (text.contains('balcon') ? true : null);
    final hasTerrace =
        current.hasTerrace ?? (text.contains('terrasse') ? true : null);
    final hasGarden =
        current.hasGarden ?? (text.contains('jardin') ? true : null);
    final hasParking = current.hasParking ??
        (RegExp(r'\b(parking|garage|stationnement)\b').hasMatch(text)
            ? true
            : null);
    final hasCellar =
        current.hasCellar ?? (text.contains('cave') ? true : null);

    // Meublé
    bool? isFurnished = current.isFurnished;
    if (isFurnished == null) {
      if (RegExp(r'\bnon[\s-]meublé').hasMatch(text)) {
        isFurnished = false;
      } else if (RegExp(r'\bmeublé').hasMatch(text)) {
        isFurnished = true;
      }
    }

    // Chauffage
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
      }
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
      charges: charges,
      hasBalcony: hasBalcony,
      hasTerrace: hasTerrace,
      hasGarden: hasGarden,
      hasParking: hasParking,
      hasCellar: hasCellar,
      isFurnished: isFurnished,
      heatingType: heatingType,
    );
  }

  // ── Helpers : og: meta tags ───────────────────────────────────────────────

  /// Extrait `content=` de `<meta property="og:{property}" ...>`.
  /// Gère les deux ordres d'attributs (property avant ou après content).
  /// Le HTML réel utilise quasi-exclusivement des guillemets doubles.
  static String? _ogTag(String html, String property) {
    // Le pattern [^>]+ capture tout entre <meta et property="og:…",
    // ce qui permet de trouver la balise quel que soit l'ordre des attributs.
    final tagPattern =
        '<meta\\b[^>]+property="og:${RegExp.escape(property)}"[^>]*>';
    final tagRe = RegExp(tagPattern, caseSensitive: false);
    final tagMatch = tagRe.firstMatch(html);
    if (tagMatch == null) return null;

    final contentRe = RegExp(r'content="([^"]*)"', caseSensitive: false);
    return contentRe.firstMatch(tagMatch.group(0)!)?.group(1);
  }

  // ── Helpers : extraction de valeurs depuis une chaîne ────────────────────

  /// Extrait un prix en € depuis du texte.
  /// Gère le formatage français : "1 350 €/mois", "250 000 €", "1350€".
  static double? _price(String text) {
    final re = RegExp(r'(\d[\d\u00a0\s]*\d|\d{1,7})\s*€', caseSensitive: false);
    final m = re.firstMatch(text);
    if (m == null) return null;
    final digits = m.group(1)!.replaceAll(RegExp(r'[\s\u00a0]'), '');
    return double.tryParse(digits);
  }

  /// Extrait une surface en m² depuis du texte.
  /// Gère "48 m²", "48.5 m²", "48,5 m2".
  static double? _surface(String text) {
    final re = RegExp(r'(\d+(?:[.,]\d+)?)\s*m[²2]', caseSensitive: false);
    final m = re.firstMatch(text);
    if (m == null) return null;
    return double.tryParse(m.group(1)!.replaceAll(',', '.'));
  }

  /// Extrait le nombre de pièces depuis du texte.
  /// Gère "2 pièces", "T2", "F3", "3P".
  static int? _rooms(String text) {
    // "X pièces" / "X pieces"
    final pieceRe = RegExp(r'(\d+)\s*pi[eè]ces?', caseSensitive: false);
    final pieceMatch = pieceRe.firstMatch(text);
    if (pieceMatch != null) return int.tryParse(pieceMatch.group(1)!);

    // "T2", "F3" ou "3P"
    final typeRe = RegExp(r'\b[TF](\d)\b|\b(\d)P\b', caseSensitive: false);
    final typeMatch = typeRe.firstMatch(text);
    if (typeMatch != null) {
      return int.tryParse(typeMatch.group(1) ?? typeMatch.group(2) ?? '');
    }
    return null;
  }

  /// Extrait la localisation à partir d'un og:title du type "Titre - Ville".
  static String? _addressFromTitle(String title) {
    // Retire d'abord le suffixe " | Site"
    var t = title;
    final pipeIdx = t.indexOf(' | ');
    if (pipeIdx != -1) t = t.substring(0, pipeIdx);

    // Prend la partie après le dernier " - " ou " – "
    for (final sep in [' - ', ' – ']) {
      final idx = t.lastIndexOf(sep);
      if (idx != -1) return t.substring(idx + sep.length).trim();
    }
    return null;
  }

  /// Nettoie un og:title pour l'affichage :
  /// supprime "- Adresse" et "| Site".
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
    // Classe contenant un terme de prix
    final classRe = RegExp(
      r'class="[^"]*(?:price|prix|loyer|tarif|rent|cost)[^"]*"[^>]*>\s*([^<]+)',
      caseSensitive: false,
    );
    final m = classRe.firstMatch(html);
    if (m != null) {
      final content = m.group(1)!.trim();
      final withEuro = _price(content);
      if (withEuro != null) return withEuro;
      // Contenu sans €, juste un nombre (ex : "1 350")
      final numOnly = RegExp(r'^[\s\u00a0]*(\d[\d\s\u00a0]*\d|\d+)[\s\u00a0]*$')
          .firstMatch(content);
      if (numOnly != null) {
        return double.tryParse(
          numOnly.group(1)!.replaceAll(RegExp(r'[\s\u00a0]'), ''),
        );
      }
    }
    // Cherche "X €/mois" dans le HTML brut
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
    // h1 en priorité
    final h1Re = RegExp(r'<h1[^>]*>\s*([^<]+)\s*</h1>', caseSensitive: false);
    final h1 = h1Re.firstMatch(html);
    if (h1 != null) return h1.group(1)!.trim();

    // Puis <title>
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
