# Tickets Doutang

## Sprint 1 — Fondations

### #001 · Architecture & modèles Dart ✅
**Statut :** Terminé
**Labels :** `architecture`, `data`, `sprint-1`

**Description :** Définir la structure de données complète et générer les modèles Dart avec sérialisation JSON.

**Critères d'acceptation :**
- [x] Modèle `DoutangProject` avec sérialisation JSON
- [x] Modèle `UserProfile` avec critères et pondérations
- [x] Modèle `Listing` avec statuts et métadonnées
- [x] Modèle `Visit` avec réponses et score
- [x] `MergeService` avec stratégie owner-based
- [x] `ScoreService` avec calcul individuel et couple
- [x] Tests unitaires passants
- [x] Documentation ARCHITECTURE.md à jour

---

### #002 · Navigation & structure app Flutter
**Statut :** Backlog
**Labels :** `ui`, `sprint-1`

**Description :** Mettre en place la navigation principale de l'app (bottom nav, routes, écrans vides).

**Critères d'acceptation :**
- [ ] Bottom navigation bar : Annonces / Visites / Comparer / Profil
- [ ] Routes nommées pour chaque écran
- [ ] Écrans vides avec placeholder
- [ ] Thème Doutang (couleurs, typographie)
- [ ] Compatible FlutterFlow export

---

### #003 · Écran désidératas — profil & pondérations
**Statut :** Backlog
**Labels :** `ui`, `feat`, `sprint-1`

**Description :** Formulaire de saisie des désidératas avec sliders de pondération.

**Critères d'acceptation :**
- [ ] Saisie : budget max, surface min, nb pièces, type (achat/location)
- [ ] Sélection de zones géographiques (tags)
- [ ] Sliders de pondération 1-5 pour chaque critère lifestyle
- [ ] Sauvegarde locale du profil
- [ ] Aperçu du profil rempli

---

### #004 · Import annonce Jinka par URL
**Statut :** Backlog
**Labels :** `feat`, `sprint-1`

**Description :** Permettre l'ajout d'une annonce via copier-coller d'une URL Jinka avec parsing des métadonnées.

**Critères d'acceptation :**
- [ ] Champ de saisie URL
- [ ] Parser : extraction titre, prix, surface, adresse depuis la page
- [ ] Fallback : saisie manuelle si parsing échoue
- [ ] Ajout de l'annonce à la liste avec statut "à contacter"
- [ ] Score de matching affiché immédiatement

---

## Sprint 2 — Visite

### #005 · Questionnaire de visite — swipe cards
**Statut :** Backlog
**Labels :** `ui`, `feat`, `sprint-2`

### #006 · Bilan de visite automatique
**Statut :** Backlog
**Labels :** `feat`, `data`, `sprint-2`

### #007 · Photos par section de visite
**Statut :** Backlog
**Labels :** `feat`, `sprint-2`

---

## Sprint 3 — Comparaison

### #008 · Tableau comparatif multi-biens
**Statut :** Backlog
**Labels :** `ui`, `feat`, `sprint-3`

### #009 · Radar chart par bien
**Statut :** Backlog
**Labels :** `ui`, `sprint-3`

### #010 · Export & import fichier .doutang
**Statut :** Backlog
**Labels :** `feat`, `sprint-3`

---

## Sprint 4 — Polish & Deploy

### #011 · UX polish & animations
**Statut :** Backlog
**Labels :** `ui`, `sprint-4`

### #012 · Tests d'intégration
**Statut :** Backlog
**Labels :** `test`, `sprint-4`

### #013 · Déploiement APK & App Store
**Statut :** Backlog
**Labels :** `devops`, `sprint-4`
