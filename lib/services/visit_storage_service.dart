import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/visit.dart';

/// Persiste la liste des [Visit] dans un fichier JSON sur l'appareil.
///
/// Le paramètre [basePath] est réservé aux tests : il permet d'injecter
/// un répertoire temporaire sans dépendance à la plateforme.
class VisitStorageService {
  VisitStorageService._();

  static const _filename = 'visits.json';

  static Future<File> _file({String? basePath}) async {
    final dir = basePath != null
        ? Directory(basePath)
        : await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_filename');
  }

  /// Écrase le fichier avec la liste fournie.
  static Future<void> save(List<Visit> visits, {String? basePath}) async {
    final file = await _file(basePath: basePath);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ')
          .convert(visits.map((v) => v.toJson()).toList()),
    );
  }

  /// Charge la liste depuis le fichier. Retourne une liste vide si absent.
  static Future<List<Visit>> load({String? basePath}) async {
    final file = await _file(basePath: basePath);
    if (!file.existsSync()) return [];
    final content = await file.readAsString();
    final raw = jsonDecode(content) as List<dynamic>;
    return raw
        .map((e) => Visit.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Ajoute ou remplace la visite pour le couple (listingId, owner).
  ///
  /// Si une visite existe déjà pour le même bien et le même owner,
  /// elle est remplacée (last-write-wins).
  static Future<void> add(Visit visit, {String? basePath}) async {
    final visits = await load(basePath: basePath);
    final idx = visits.indexWhere(
      (v) => v.listingId == visit.listingId && v.owner == visit.owner,
    );
    if (idx >= 0) {
      visits[idx] = visit;
    } else {
      visits.add(visit);
    }
    await save(visits, basePath: basePath);
  }

  /// Supprime toutes les visites d'un listing donné.
  static Future<void> deleteForListing(
    String listingId, {
    String? basePath,
  }) async {
    final visits = await load(basePath: basePath);
    visits.removeWhere((v) => v.listingId == listingId);
    await save(visits, basePath: basePath);
  }
}
