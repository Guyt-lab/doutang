# Doutang 🏠

> Trouve ton chez-toi, seul ou à deux.

Application mobile de recherche immobilière collaborative — locale, sans backend, sans compte.

---

## Vision

Doutang accompagne tout le processus de recherche d'appartement : définition des désidératas, suivi des annonces, questionnaire de visite fun, bilan automatique et comparaison multi-biens. Conçu pour fonctionner seul ou en couple/colocation via un simple échange de fichier `.doutang`.

## Stack technique

| Couche | Technologie |
|--------|-------------|
| UI builder | FlutterFlow |
| Langage | Dart (Flutter) |
| Android natif | Kotlin (plugins uniquement) |
| Stockage local | `drift` (SQLite) ou JSON selon module |
| Échange fichier | `share_plus` |
| Charts | `fl_chart` |
| Tests | `flutter_test` |

## Architecture

**Local-first, zéro backend.** Toutes les données vivent sur l'appareil. Le partage entre partenaires se fait par export/import d'un fichier `.doutang` (JSON) via WhatsApp, iMessage, AirDrop, etc.

```
lib/
├── models/          # Modèles de données Dart
│   ├── project.dart
│   ├── profile.dart
│   ├── listing.dart
│   └── visit.dart
├── services/        # Logique métier
│   ├── merge_service.dart
│   └── score_service.dart
└── utils/
    └── file_utils.dart
```

## Démarrage rapide

```bash
flutter pub get
flutter test
flutter run
```

## Modules

| # | Module | Sprint | Statut |
|---|--------|--------|--------|
| 1 | Profil & désidératas | 1 | 🔄 En cours |
| 2 | Annonces & import Jinka | 1 | ⏳ Backlog |
| 3 | Questionnaire de visite | 2 | ⏳ Backlog |
| 4 | Bilan de visite | 2 | ⏳ Backlog |
| 5 | Comparaison & décision | 3 | ⏳ Backlog |
| 6 | Collaboration & partage | 4 | ⏳ Backlog |

## Liens

- [Architecture détaillée](docs/ARCHITECTURE.md)
- [Décisions techniques](docs/DECISIONS.md)
- [Changelog](docs/CHANGELOG.md)
- [Tickets](docs/TICKETS.md)

---

*Product Owner : guyt-lab · Tech Lead : Claude (Anthropic)*
