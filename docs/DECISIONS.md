# Décisions techniques (ADR)

Architecture Decision Records — historique des choix techniques et leurs justifications.

---

## ADR-001 · Local-first, zéro backend

**Date :** 2026-04-16
**Statut :** Accepté

**Contexte :** L'app est un projet personnel/couple, pas un SaaS. Maintenir un backend implique coûts, maintenance, RGPD, disponibilité.

**Décision :** Toutes les données sur l'appareil. Partage par fichier `.doutang`.

**Conséquences :**
- ✅ Zéro coût d'infrastructure
- ✅ Zéro gestion RGPD
- ✅ Fonctionne hors-ligne (visites en cave)
- ✅ Distribution simple (APK / App Store)
- ⚠️ Synchronisation manuelle entre partenaires
- ⚠️ Pas de notifications push temps réel

---

## ADR-002 · Format d'échange JSON avec extension `.doutang`

**Date :** 2026-04-16
**Statut :** Accepté

**Contexte :** Besoin d'un format lisible, versionnable, et partageable via les canaux existants.

**Décision :** JSON avec champ `version` pour la compatibilité future. Extension `.doutang` pour l'identité produit.

**Conséquences :**
- ✅ Lisible et debuggable
- ✅ Versionnable (champ `version`)
- ✅ Compatible avec tous les canaux de partage
- ⚠️ Taille fichier plus grande que binaire (acceptable < 1MB)

---

## ADR-003 · FlutterFlow pour l'UI, Dart pur pour la logique métier

**Date :** 2026-04-16
**Statut :** Accepté

**Contexte :** FlutterFlow accélère la construction des écrans mais a des limites pour la logique complexe.

**Décision :** FlutterFlow pour navigation, écrans, formulaires. Dart pur pour scoring, merge, sérialisation.

**Conséquences :**
- ✅ Développement UI rapide
- ✅ Logique métier testable unitairement
- ✅ Code exportable et maintenable
- ⚠️ Deux "modes" de travail à jongler

---

## ADR-004 · Stratégie de merge par propriétaire (owner-based)

**Date :** 2026-04-16
**Statut :** Accepté

**Contexte :** Deux personnes peuvent modifier le fichier simultanément. Besoin d'une règle simple et prévisible.

**Décision :** Chaque entité appartient à son `owner`. Pas de conflit possible sur les visites (séparées par owner). Pour les listings : `updated_at` le plus récent gagne.

**Conséquences :**
- ✅ Règle simple, compréhensible par l'utilisateur
- ✅ Zéro conflit sur les visites
- ⚠️ Écrasement possible si deux personnes modifient le même listing simultanément (acceptable en pratique)

---

## ADR-005 · Stack Kotlin uniquement pour les plugins natifs Android

**Date :** 2026-04-16
**Statut :** Accepté

**Contexte :** Flutter couvre 95% des besoins. Kotlin nécessaire uniquement pour les plugins natifs spécifiques.

**Décision :** Kotlin limité aux cas où Flutter ne suffit pas : accès fichier système avancé, intégration OS spécifique.

**Conséquences :**
- ✅ Codebase principalement en Dart
- ✅ Cohérence avec l'expérience existante (Quickcount)
- ⚠️ Quelques fichiers Kotlin à maintenir
