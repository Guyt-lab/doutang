import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/listing.dart';

/// Persiste la liste des [Listing] dans un fichier JSON sur l'appareil.
///
/// Le paramètre [basePath] est réservé aux tests : il permet d'injecter
/// un répertoire temporaire sans dépendance à la plateforme.
class ListingStorageService {
  ListingStorageService._();

  static const _filename = 'listings.json';

  static Future<File> _file({String? basePath}) async {
    final dir = basePath != null
        ? Directory(basePath)
        : await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_filename');
  }

  /// Écrase le fichier avec la liste fournie.
  static Future<void> save(
    List<Listing> listings, {
    String? basePath,
  }) async {
    final file = await _file(basePath: basePath);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ')
          .convert(listings.map((l) => l.toJson()).toList()),
    );
  }

  /// Charge la liste depuis le fichier. Retourne une liste vide si absent.
  static Future<List<Listing>> load({String? basePath}) async {
    final file = await _file(basePath: basePath);
    if (!file.existsSync()) return [];
    final content = await file.readAsString();
    final raw = jsonDecode(content) as List<dynamic>;
    return raw
        .map((e) => Listing.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Charge la liste, ajoute [listing] à la fin, puis sauvegarde.
  static Future<void> add(Listing listing, {String? basePath}) async {
    final listings = await load(basePath: basePath);
    listings.add(listing);
    await save(listings, basePath: basePath);
  }

  /// Supprime l'annonce dont l'[id] correspond.
  static Future<void> deleteById(String id, {String? basePath}) async {
    final listings = await load(basePath: basePath);
    listings.removeWhere((l) => l.id == id);
    await save(listings, basePath: basePath);
  }

  /// Remplace l'annonce dont l'[id] correspond (last-write-wins).
  static Future<void> update(Listing listing, {String? basePath}) async {
    final listings = await load(basePath: basePath);
    final idx = listings.indexWhere((l) => l.id == listing.id);
    if (idx >= 0) {
      listings[idx] = listing;
      await save(listings, basePath: basePath);
    }
  }

  /// Supprime le fichier de stockage entier (réservé aux tests).
  static Future<void> deleteFile({String? basePath}) async {
    final file = await _file(basePath: basePath);
    if (file.existsSync()) await file.delete();
  }
}
