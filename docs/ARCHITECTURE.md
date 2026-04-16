# Architecture Doutang

## Principe fondamental : Local-First

Toutes les données résident sur l'appareil de l'utilisateur. Aucun serveur, aucune authentification, aucune dépendance réseau pour les fonctionnalités core.

## Format d'échange : fichier `.doutang`

Le fichier `.doutang` est un JSON structuré qui représente l'état complet d'un projet de recherche. Il est partagé entre partenaires via les canaux existants (WhatsApp, AirDrop, email...).

### Schéma complet v1.0

```json
{
  "version": "1.0",
  "app": "doutang",
  "project": {
    "id": "uuid-v4",
    "name": "Appart Paris 2026",
    "type": "location",
    "created_at": "2026-04-16T10:00:00Z",
    "updated_at": "2026-04-16T10:00:00Z"
  },
  "profiles": [
    {
      "id": "uuid-v4",
      "owner": "Moi",
      "criteria": {
        "budget_max": 1500,
        "surface_min": 40,
        "rooms_min": 2,
        "zones": ["Paris 11", "Paris 12", "Montreuil"],
        "tags": ["calme", "lumineux", "balcon"]
      },
      "weights": {
        "budget": 5,
        "surface": 4,
        "transports": 3,
        "luminosite": 5,
        "calme": 4,
        "etat": 3,
        "quartier": 4
      },
      "updated_at": "2026-04-16T10:00:00Z"
    }
  ],
  "listings": [
    {
      "id": "uuid-v4",
      "url": "https://jinka.fr/...",
      "title": "Bel appart 2P Paris 11",
      "price": 1350,
      "surface": 48,
      "rooms": 2,
      "address": "Paris 11ème",
      "status": "a_visiter",
      "notes": "",
      "added_by": "Moi",
      "added_at": "2026-04-16T10:00:00Z"
    }
  ],
  "visits": [
    {
      "id": "uuid-v4",
      "listing_id": "uuid-v4",
      "owner": "Moi",
      "visited_at": "2026-04-16T14:00:00Z",
      "answers": {
        "luminosite": 4,
        "calme": 3,
        "etat_general": 4,
        "cuisine": 3,
        "salle_de_bain": 4,
        "rangements": 2,
        "chauffage": 3,
        "double_vitrage": true,
        "gardien": false,
        "cave": true,
        "coup_de_coeur": "La luminosité du salon",
        "point_redhibitoire": "Pas de rangements"
      },
      "feeling": 4,
      "score": 3.6,
      "photos": [],
      "updated_at": "2026-04-16T15:00:00Z"
    }
  ]
}
```

## Logique de merge

Quand un partenaire importe un fichier `.doutang`, la règle est :

| Entité | Stratégie |
|--------|-----------|
| `project` | Champs non-conflictuels fusionnés, `updated_at` le plus récent gagne |
| `profiles` | Union par `owner` — chaque profil appartient à son owner, pas de conflit |
| `listings` | Union par `id` — `updated_at` le plus récent gagne par listing |
| `visits` | Union par `(listing_id, owner)` — chaque visite appartient à son owner |

## Calcul du score

### Score individuel par visite

```
score_individuel = Σ(réponse_i × poids_i) / Σ(poids_i)
```

où `réponse_i` est normalisée sur 5.

### Score couple

```
score_couple = moyenne(score_partenaire_1, score_partenaire_2)
```

Si un seul partenaire a visité, le score couple = score individuel (pas de pénalité).

### Score de matching annonce

Calculé avant visite, à partir des critères du profil vs les données de l'annonce :

```
score_matching = Σ(critère_couvert_i × poids_i) / Σ(poids_i)
```

## Dépendances Flutter

```yaml
dependencies:
  flutter:
    sdk: flutter
  uuid: ^4.0.0
  share_plus: ^7.0.0
  file_picker: ^6.0.0
  path_provider: ^2.0.0
  fl_chart: ^0.66.0
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```
