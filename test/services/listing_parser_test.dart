import 'package:flutter_test/flutter_test.dart';
import 'package:doutang/models/listing_facts.dart';
import 'package:doutang/models/enums.dart';
import 'package:doutang/models/visit.dart';
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

    // ── Nouvelles détections sémantiques ────────────────────────────────────

    group('passe sémantique — chambres', () {
      test('extrait "2 chambres"', () {
        final r = ListingParserService.parseHtml(
          '<html><body>Appartement avec 2 chambres et salon.</body></html>',
        );
        expect(r.bedrooms, equals(2));
      });

      test('extrait "1 chambre"', () {
        final r = ListingParserService.parseHtml(
          '<html><body>Studio avec 1 chambre séparée.</body></html>',
        );
        expect(r.bedrooms, equals(1));
      });
    });

    group('passe sémantique — ascenseur & digicode', () {
      test('détecte ascenseur', () {
        final r = ListingParserService.parseHtml(
          '<html><body>Immeuble avec ascenseur, 4ème étage.</body></html>',
        );
        expect(r.hasElevator, isTrue);
      });

      test('détecte digicode', () {
        final r = ListingParserService.parseHtml(
          '<html><body>Accès sécurisé avec digicode et interphone.</body></html>',
        );
        expect(r.hasIntercom, isTrue);
      });

      test('détecte interphone', () {
        final r = ListingParserService.parseHtml(
          '<html><body>Immeuble avec interphone vidéo.</body></html>',
        );
        expect(r.hasIntercom, isTrue);
      });

      test('retourne null si absent', () {
        final r = ListingParserService.parseHtml(
          '<html><body>Petit immeuble sans gardien.</body></html>',
        );
        expect(r.hasElevator, isNull);
        expect(r.hasIntercom, isNull);
      });
    });

    group('passe sémantique — local vélos', () {
      test('détecte local vélos', () {
        final r = ListingParserService.parseHtml(
          '<html><body>Local vélos et cave en sous-sol.</body></html>',
        );
        expect(r.hasBikeStorage, isTrue);
      });
    });

    group('passe sémantique — chauffage collectif', () {
      test('détecte chauffage collectif', () {
        final r = ListingParserService.parseHtml(
          '<html><body>Chauffage collectif au gaz, eau chaude collective incluse.</body></html>',
        );
        expect(r.heatingCollective, isTrue);
        expect(r.hotWaterCollective, isTrue);
      });

      test('détecte chauffage individuel', () {
        final r = ListingParserService.parseHtml(
          '<html><body>Chauffage individuel électrique.</body></html>',
        );
        expect(r.heatingCollective, isFalse);
      });
    });

    group('passe sémantique — cheminée, poutres, moulures', () {
      test('détecte cheminée', () {
        final r = ListingParserService.parseHtml(
          '<html><body>Beau séjour avec cheminée en marbre.</body></html>',
        );
        expect(r.hasFireplace, isTrue);
      });

      test('détecte poutres apparentes', () {
        final r = ListingParserService.parseHtml(
          '<html><body>Appartement avec poutres apparentes au plafond.</body></html>',
        );
        expect(r.hasBeams, isTrue);
      });

      test('détecte moulures', () {
        final r = ListingParserService.parseHtml(
          '<html><body>Bel haussmannien avec moulures et parquet.</body></html>',
        );
        expect(r.hasMouldings, isTrue);
      });
    });

    group('passe sémantique — type de cuisine', () {
      test('détecte cuisine américaine', () {
        final r = ListingParserService.parseHtml(
          '<html><body>Séjour avec cuisine américaine équipée.</body></html>',
        );
        expect(r.kitchenType, equals('americaine'));
      });

      test('détecte cuisine ouverte', () {
        final r = ListingParserService.parseHtml(
          '<html><body>Grand séjour avec cuisine ouverte.</body></html>',
        );
        expect(r.kitchenType, equals('ouverte'));
      });

      test('détecte cuisine fermée', () {
        final r = ListingParserService.parseHtml(
          '<html><body>Appartement avec cuisine fermée indépendante.</body></html>',
        );
        expect(r.kitchenType, equals('fermee'));
      });
    });

    group('passe sémantique — surfaces extérieures', () {
      test('extrait surface balcon', () {
        final r = ListingParserService.parseHtml(
          '<html><body>Bel appartement avec balcon de 8 m².</body></html>',
        );
        expect(r.balconySurface, equals(8.0));
      });

      test('extrait surface terrasse', () {
        final r = ListingParserService.parseHtml(
          '<html><body>Grande terrasse de 20 m² plein sud.</body></html>',
        );
        expect(r.terraceSurface, equals(20.0));
      });

      test('extrait surface jardin', () {
        final r = ListingParserService.parseHtml(
          '<html><body>Maison avec jardin de 150 m².</body></html>',
        );
        expect(r.gardenSurface, equals(150.0));
      });
    });

    group('passe sémantique — GES', () {
      test('extrait la classe GES', () {
        final r = ListingParserService.parseHtml(
          '<html><body>DPE : C. GES : B. Logement économe.</body></html>',
        );
        expect(r.gesClass, equals('B'));
      });
    });

    group('passe sémantique — année de construction', () {
      test('extrait "construit en 1975"', () {
        final r = ListingParserService.parseHtml(
          '<html><body>Immeuble construit en 1975, bien entretenu.</body></html>',
        );
        expect(r.constructionYear, equals(1975));
      });
    });

    group('passe sémantique — agence / particulier', () {
      test('détecte annonce via agence', () {
        final r = ListingParserService.parseHtml(
          '<html><body>Offre proposée par une agence immobilière.</body></html>',
        );
        expect(r.isAgency, isTrue);
      });

      test('détecte annonce de particulier', () {
        final r = ListingParserService.parseHtml(
          '<html><body>Vente entre particuliers, pas de frais d\'agence.</body></html>',
        );
        expect(r.isAgency, isFalse);
      });
    });

    group('passe sémantique — chauffage bois', () {
      test('détecte poêle à bois', () {
        final r = ListingParserService.parseHtml(
          '<html><body>Maison avec poêle à bois dans le séjour.</body></html>',
        );
        expect(r.heatingType, equals('bois'));
      });
    });

    // ── JSON-LD ──────────────────────────────────────────────────────────────

    group('JSON-LD schema.org', () {
      test('extrait le prix depuis offers.price', () {
        const html = '''
<html><head>
<script type="application/ld+json">
{"@context":"https://schema.org","@type":"Apartment","name":"Bel appartement","offers":{"@type":"Offer","price":1250,"priceCurrency":"EUR"}}
</script>
</head><body></body></html>''';
        final r = ListingParserService.parseHtml(html);
        expect(r.price, equals(1250.0));
      });

      test('extrait la surface depuis floorSize.value', () {
        const html = '''
<html><head>
<script type="application/ld+json">
{"@type":"Apartment","name":"T3 Lyon","floorSize":{"@type":"QuantitativeValue","value":68,"unitCode":"MTK"}}
</script>
</head><body></body></html>''';
        final r = ListingParserService.parseHtml(html);
        expect(r.surface, equals(68.0));
      });

      test('extrait numberOfRooms et numberOfBedrooms', () {
        const html = '''
<html><head>
<script type="application/ld+json">
{"@type":"Apartment","numberOfRooms":3,"numberOfBedrooms":2}
</script>
</head><body></body></html>''';
        final r = ListingParserService.parseHtml(html);
        expect(r.rooms, equals(3));
        expect(r.bedrooms, equals(2));
      });

      test('extrait l\'adresse depuis address.addressLocality', () {
        const html = '''
<html><head>
<script type="application/ld+json">
{"@type":"Apartment","address":{"@type":"PostalAddress","addressLocality":"Lyon"}}
</script>
</head><body></body></html>''';
        final r = ListingParserService.parseHtml(html);
        expect(r.address, equals('Lyon'));
      });

      test('og: prime sur JSON-LD pour le prix', () {
        const html = '''
<html><head>
<meta property="og:description" content="Loyer : 900 €/mois." />
<script type="application/ld+json">
{"@type":"Apartment","offers":{"price":1500}}
</script>
</head><body></body></html>''';
        final r = ListingParserService.parseHtml(html);
        // og: est prioritaire : le prix doit être 900, pas 1500
        expect(r.price, equals(900.0));
      });
    });

    // ── ListingFacts.fromParsed ───────────────────────────────────────────────

    group('ListingFacts.fromParsed', () {
      test('mappe surface, rooms, bedrooms, floor', () {
        const p = ParsedListing(
          surface: 65.0,
          rooms: 3,
          bedrooms: 2,
          floor: 4,
        );
        final f = ListingFacts.fromParsed(p);
        expect(f.surfaceTotal, equals(65.0));
        expect(f.rooms, equals(3));
        expect(f.bedrooms, equals(2));
        expect(f.floor, equals(4));
      });

      test('convertit heatingType string → enum', () {
        const p = ParsedListing(heatingType: 'gaz');
        final f = ListingFacts.fromParsed(p);
        expect(f.heatingType, equals(HeatingType.gaz));
      });

      test('heatingCollective=true → HeatingControl.collectif', () {
        const p = ParsedListing(heatingCollective: true);
        final f = ListingFacts.fromParsed(p);
        expect(f.heatingControl, equals(HeatingControl.collectif));
      });

      test('heatingCollective=false → HeatingControl.individuel', () {
        const p = ParsedListing(heatingCollective: false);
        final f = ListingFacts.fromParsed(p);
        expect(f.heatingControl, equals(HeatingControl.individuel));
      });

      test('convertit kitchenType string → enum', () {
        const p = ParsedListing(kitchenType: 'ouverte');
        final f = ListingFacts.fromParsed(p);
        expect(f.kitchenType, equals(KitchenType.ouverte));
      });

      test('mappe extérieurs avec surfaces', () {
        const p = ParsedListing(
          hasBalcony: true,
          balconySurface: 8.0,
          hasTerrace: true,
          terraceSurface: 15.0,
        );
        final f = ListingFacts.fromParsed(p);
        expect(f.hasBalcony, isTrue);
        expect(f.balconySurface, equals(8.0));
        expect(f.hasTerrace, isTrue);
        expect(f.terraceSurface, equals(15.0));
      });

      test('mappe hasFireplace, hasBeams, hasMouldings', () {
        const p = ParsedListing(
          hasFireplace: true,
          hasBeams: true,
          hasMouldings: true,
        );
        final f = ListingFacts.fromParsed(p);
        expect(f.hasFireplace, isTrue);
        expect(f.hasBeams, isTrue);
        expect(f.hasMouldings, isTrue);
      });

      test('heatingType inconnu → HeatingType.autre', () {
        const p = ParsedListing(heatingType: 'plancherChauffant');
        final f = ListingFacts.fromParsed(p);
        expect(f.heatingType, equals(HeatingType.autre));
      });
    });

    // ── VisitAnswers.fromParsed ───────────────────────────────────────────────

    group('VisitAnswers.fromParsed', () {
      test('cave, ascenseur, digicode mappés', () {
        const p = ParsedListing(
          hasCellar: true,
          hasElevator: true,
          hasIntercom: true,
        );
        final a = VisitAnswers.fromParsed(p);
        expect(a.cave, isTrue);
        expect(a.ascenseur, isTrue);
        expect(a.digicode, isTrue);
      });

      test('balconOuTerrasse = true si balcon ou terrasse présent', () {
        const p = ParsedListing(hasBalcony: true);
        final a = VisitAnswers.fromParsed(p);
        expect(a.balconOuTerrasse, isTrue);
      });

      test('chargesAmount converti en chaîne', () {
        const p = ParsedListing(charges: 120.0);
        final a = VisitAnswers.fromParsed(p);
        expect(a.chargesAmount, equals('120'));
      });

      test('dpeNiveau et dateConstruction mappés', () {
        const p = ParsedListing(dpe: 'C', constructionYear: 1990);
        final a = VisitAnswers.fromParsed(p);
        expect(a.dpeNiveau, equals('C'));
        expect(a.dateConstruction, equals('1990'));
      });
    });

    // ── extractedCount ────────────────────────────────────────────────────────

    group('extractedCount', () {
      test('0 pour un ParsedListing vide', () {
        expect(const ParsedListing().extractedCount, equals(0));
      });

      test('compte correctement les champs non-null', () {
        const p = ParsedListing(
          title: 'Appart',
          price: 900.0,
          surface: 48.0,
          dpe: 'C',
          hasBalcony: true,
        );
        expect(p.extractedCount, equals(5));
      });
    });

  // ── ListingStorageService (via import séparé dans un autre fichier) ────────
  // Les tests de stockage sont dans test/services/listing_storage_test.dart
}
