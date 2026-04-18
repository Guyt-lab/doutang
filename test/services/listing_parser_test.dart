import 'package:flutter_test/flutter_test.dart';
import 'package:doutang/services/listing_parser_service.dart';

// ── HTML mock complet (style Jinka avec og: tags) ─────────────────────────────

const _htmlFullOg = '''
<html>
<head>
  <meta property="og:title" content="Appartement 2 pièces, 48 m² - Paris 11ème" />
  <meta property="og:description" content="Louer appartement à Paris 11ème, 48 m², 2 pièces, 1 350 €/mois. Bel appartement lumineux." />
  <meta property="og:url" content="https://jinka.fr/annonce/123456" />
  <title>Appartement 2 pièces, 48 m² - Paris 11ème | Jinka</title>
</head>
<body>
  <h1 class="listing-title">Appartement 2 pièces Paris 11</h1>
  <span class="price">1 350 €/mois</span>
  <div class="location">Paris 11ème</div>
</body>
</html>
''';

// og:title avec attributs dans l'ordre inversé (content avant property)
const _htmlReversedMetaOrder = '''
<html>
<head>
  <meta content="Studio T1, 22 m² - Montrouge" property="og:title" />
  <meta content="Studio 22 m², 750 €/mois, Montrouge (92120)" property="og:description" />
</head>
<body></body>
</html>
''';

// Pas de og: tags — uniquement CSS classes (style site générique)
const _htmlCssOnly = '''
<html>
<head>
  <title>3 pièces, 65 m² - Vincennes | SeLoger</title>
</head>
<body>
  <h1>Appartement 3 pièces, 65 m²</h1>
  <span class="prix-annonce">1 800 €/mois</span>
  <div class="surface">65 m²</div>
  <span class="adresse">Vincennes (94300)</span>
</body>
</html>
''';

// Prix en format achat (sans /mois)
const _htmlAchat = '''
<html>
<head>
  <meta property="og:title" content="Appartement F3, 72 m² - Lyon 6ème" />
  <meta property="og:description" content="Appartement 72 m², 3 pièces, 280 000 € — Lyon 6ème." />
</head>
<body></body>
</html>
''';

// HTML vide / aucune information utile
const _htmlEmpty = '<html><head></head><body></body></html>';

// Prix avec espace insécable Unicode (\u00a0)
const _htmlNbsp = '''
<html>
<head>
  <meta property="og:title" content="Appartement 2P, 50 m² - Paris 12ème" />
  <meta property="og:description" content="Loyer\u00a0:\u00a01\u00a0450\u00a0€/mois." />
</head>
<body></body>
</html>
''';

// Titre avec em-dash (–) au lieu de tiret (-)
const _htmlEmDash = '''
<html>
<head>
  <meta property="og:title" content="Maison 4 pièces, 100 m² – Nantes" />
  <meta property="og:description" content="Belle maison, 100 m², 4 pièces, 1 600 €/mois." />
</head>
<body></body>
</html>
''';

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('ListingParserService.parseHtml', () {
    // ── og: meta tags ──────────────────────────────────────────────────────

    group('og: meta tags', () {
      test('extrait le titre nettoyé depuis og:title', () {
        final result = ListingParserService.parseHtml(_htmlFullOg);
        // Le titre ne doit pas contenir la ville ni le suffixe "| Jinka"
        expect(result.title, equals('Appartement 2 pièces, 48 m²'));
      });

      test('extrait le prix depuis og:description', () {
        final result = ListingParserService.parseHtml(_htmlFullOg);
        expect(result.price, equals(1350.0));
      });

      test('extrait la surface depuis og:title', () {
        final result = ListingParserService.parseHtml(_htmlFullOg);
        expect(result.surface, equals(48.0));
      });

      test('extrait le nombre de pièces depuis og:title', () {
        final result = ListingParserService.parseHtml(_htmlFullOg);
        expect(result.rooms, equals(2));
      });

      test('extrait l\'adresse depuis og:title (partie après " - ")', () {
        final result = ListingParserService.parseHtml(_htmlFullOg);
        expect(result.address, equals('Paris 11ème'));
      });

      test('hasAnyData est vrai quand au moins un champ extrait', () {
        final result = ListingParserService.parseHtml(_htmlFullOg);
        expect(result.hasAnyData, isTrue);
      });
    });

    // ── Ordre inversé des attributs meta ──────────────────────────────────

    group('meta avec content avant property', () {
      test('extrait og:title même avec attributs inversés', () {
        final result = ListingParserService.parseHtml(_htmlReversedMetaOrder);
        expect(result.title, isNotNull);
        expect(result.title, contains('Studio'));
      });

      test('extrait le prix depuis og:description avec attributs inversés', () {
        final result = ListingParserService.parseHtml(_htmlReversedMetaOrder);
        expect(result.price, equals(750.0));
      });

      test('extrait la surface depuis og:description', () {
        final result = ListingParserService.parseHtml(_htmlReversedMetaOrder);
        expect(result.surface, equals(22.0));
      });
    });

    // ── Fallback CSS classes ───────────────────────────────────────────────

    group('fallback CSS selectors (sans og: tags)', () {
      test('extrait le titre depuis <h1>', () {
        final result = ListingParserService.parseHtml(_htmlCssOnly);
        expect(result.title, equals('Appartement 3 pièces, 65 m²'));
      });

      test('extrait le prix depuis class contenant "prix"', () {
        final result = ListingParserService.parseHtml(_htmlCssOnly);
        expect(result.price, equals(1800.0));
      });

      test('extrait la surface depuis class "surface"', () {
        final result = ListingParserService.parseHtml(_htmlCssOnly);
        expect(result.surface, equals(65.0));
      });
    });

    // ── Format achat (prix sans /mois) ────────────────────────────────────

    group('prix achat', () {
      test('extrait un prix d\'achat en milliers', () {
        final result = ListingParserService.parseHtml(_htmlAchat);
        expect(result.price, equals(280000.0));
      });

      test('extrait T3 / F3 via notation pièces', () {
        final result = ListingParserService.parseHtml(_htmlAchat);
        expect(result.rooms, equals(3));
      });
    });

    // ── Espace insécable (format HTML français) ───────────────────────────

    test('gère l\'espace insécable \\u00a0 dans le prix', () {
      final result = ListingParserService.parseHtml(_htmlNbsp);
      expect(result.price, equals(1450.0));
    });

    // ── Em-dash dans le titre ─────────────────────────────────────────────

    test('extrait l\'adresse séparée par un em-dash (–)', () {
      final result = ListingParserService.parseHtml(_htmlEmDash);
      expect(result.address, equals('Nantes'));
      expect(result.title, contains('Maison'));
    });

    // ── HTML sans données utiles ──────────────────────────────────────────

    test('retourne tous les champs null pour HTML vide', () {
      final result = ListingParserService.parseHtml(_htmlEmpty);
      expect(result.title, isNull);
      expect(result.price, isNull);
      expect(result.surface, isNull);
      expect(result.rooms, isNull);
      expect(result.address, isNull);
    });

    test('hasAnyData est faux pour HTML vide', () {
      final result = ListingParserService.parseHtml(_htmlEmpty);
      expect(result.hasAnyData, isFalse);
    });

    // ── Formats de surface ────────────────────────────────────────────────

    group('formats de surface', () {
      test('48 m²', () {
        final r = ListingParserService.parseHtml(
          '<meta property="og:title" content="Appart - Paris" />'
          '<meta property="og:description" content="48 m²" />',
        );
        expect(r.surface, equals(48.0));
      });

      test('48.5 m² (décimal point)', () {
        final r = ListingParserService.parseHtml(
          '<meta property="og:description" content="Surface : 48.5 m²" />',
        );
        expect(r.surface, equals(48.5));
      });

      test('48,5 m² (décimal virgule)', () {
        final r = ListingParserService.parseHtml(
          '<meta property="og:description" content="Surface : 48,5 m²" />',
        );
        expect(r.surface, equals(48.5));
      });

      test('48 m2 (sans symbole unicode)', () {
        final r = ListingParserService.parseHtml(
          '<meta property="og:description" content="48 m2 disponible" />',
        );
        expect(r.surface, equals(48.0));
      });
    });

    // ── Formats de pièces ─────────────────────────────────────────────────

    group('extraction du nombre de pièces', () {
      test('"3 pièces" extrait 3', () {
        final r = ListingParserService.parseHtml(
          '<meta property="og:title" content="Appart 3 pièces - Lyon" />',
        );
        expect(r.rooms, equals(3));
      });

      test('"T2" extrait 2', () {
        final r = ListingParserService.parseHtml(
          '<meta property="og:title" content="T2 40 m² - Bordeaux" />',
        );
        expect(r.rooms, equals(2));
      });

      test('"F4" extrait 4', () {
        final r = ListingParserService.parseHtml(
          '<meta property="og:title" content="F4 90 m² - Marseille" />',
        );
        expect(r.rooms, equals(4));
      });
    });

    // ── Passe sémantique ──────────────────────────────────────────────────────

    group('passe sémantique — type de transaction', () {
      test('détecte "location" depuis le corps', () {
        final r = ListingParserService.parseHtml(
          '<html><body>À louer : appartement 2 pièces. Loyer 900 €/mois.</body></html>',
        );
        expect(r.transactionType, equals('location'));
      });

      test('détecte "achat" depuis le corps', () {
        final r = ListingParserService.parseHtml(
          '<html><body>À vendre : maison 5 pièces. Prix 320 000 €.</body></html>',
        );
        expect(r.transactionType, equals('achat'));
      });

      test('retourne null si aucun indicateur', () {
        final r = ListingParserService.parseHtml(_htmlEmpty);
        expect(r.transactionType, isNull);
      });
    });

    group('passe sémantique — type de bien', () {
      test('détecte "appartement"', () {
        final r = ListingParserService.parseHtml(
          '<html><body>Bel appartement au 3ème étage.</body></html>',
        );
        expect(r.propertyType, equals('appartement'));
      });

      test('détecte "maison"', () {
        final r = ListingParserService.parseHtml(
          '<html><body>Maison avec jardin et garage.</body></html>',
        );
        expect(r.propertyType, equals('maison'));
      });

      test('détecte "studio" comme appartement', () {
        final r = ListingParserService.parseHtml(
          '<html><body>Studio meublé, 20 m², 650 €/mois.</body></html>',
        );
        expect(r.propertyType, equals('appartement'));
      });
    });

    group('passe sémantique — étage', () {
      test('extrait "3ème étage"', () {
        final r = ListingParserService.parseHtml(
          '<html><body>Appartement au 3ème étage sans ascenseur.</body></html>',
        );
        expect(r.floor, equals(3));
      });

      test('extrait "rez-de-chaussée" comme étage 0', () {
        final r = ListingParserService.parseHtml(
          '<html><body>Appartement en rez-de-chaussée avec jardin.</body></html>',
        );
        expect(r.floor, equals(0));
      });
    });

    group('passe sémantique — équipements booléens', () {
      test('détecte balcon', () {
        final r = ListingParserService.parseHtml(
          '<html><body>Appartement avec balcon vue dégagée.</body></html>',
        );
        expect(r.hasBalcony, isTrue);
      });

      test('détecte terrasse', () {
        final r = ListingParserService.parseHtml(
          '<html><body>Grand appartement avec terrasse.</body></html>',
        );
        expect(r.hasTerrace, isTrue);
      });

      test('détecte parking', () {
        final r = ListingParserService.parseHtml(
          '<html><body>Inclus : parking en sous-sol.</body></html>',
        );
        expect(r.hasParking, isTrue);
      });

      test('détecte cave', () {
        final r = ListingParserService.parseHtml(
          '<html><body>Cave et parking inclus dans le loyer.</body></html>',
        );
        expect(r.hasCellar, isTrue);
      });

      test('retourne null quand non mentionné', () {
        final r = ListingParserService.parseHtml(_htmlEmpty);
        expect(r.hasBalcony, isNull);
        expect(r.hasParking, isNull);
      });
    });

    group('passe sémantique — meublé', () {
      test('détecte meublé = true', () {
        final r = ListingParserService.parseHtml(
          '<html><body>Appartement meublé, toutes charges comprises.</body></html>',
        );
        expect(r.isFurnished, isTrue);
      });

      test('détecte non meublé = false', () {
        final r = ListingParserService.parseHtml(
          '<html><body>Appartement non meublé, 2 pièces.</body></html>',
        );
        expect(r.isFurnished, isFalse);
      });
    });

    group('passe sémantique — charges', () {
      test('extrait les charges mensuelles', () {
        final r = ListingParserService.parseHtml(
          '<html><body>Loyer 800 € + charges : 80 € par mois.</body></html>',
        );
        expect(r.charges, equals(80.0));
      });
    });

    group('passe sémantique — DPE', () {
      test('extrait la classe DPE', () {
        final r = ListingParserService.parseHtml(
          '<html><body>DPE : C. Logement économe en énergie.</body></html>',
        );
        expect(r.dpe, equals('C'));
      });
    });
  });

  // ── ListingStorageService (via import séparé dans un autre fichier) ────────
  // Les tests de stockage sont dans test/services/listing_storage_test.dart
}
