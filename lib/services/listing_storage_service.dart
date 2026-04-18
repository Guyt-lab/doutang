import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/listing.dart';

class ListingStorageService {
  ListingStorageService._();

  static const _defaultFilename = 'listings.json';

  static String _filename(String projectId) =>
      projectId.isEmpty ? _defaultFilename : '${projectId}_listings.json';

  static Future<File> _file({String? basePath, String projectId = ''}) async {
    final dir = basePath != null
        ? Directory(basePath)
        : await getApplicationDocumentsDirectory();
    return File('${dir.path}/${_filename(projectId)}');
  }

  static Future<void> save(
    List<Listing> listings, {
    String? basePath,
    String projectId = '',
  }) async {
    final file = await _file(basePath: basePath, projectId: projectId);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ')
          .convert(listings.map((l) => l.toJson()).toList()),
    );
  }

  static Future<List<Listing>> load({
    String? basePath,
    String projectId = '',
  }) async {
    final file = await _file(basePath: basePath, projectId: projectId);
    if (!file.existsSync()) return [];
    final content = await file.readAsString();
    final raw = jsonDecode(content) as List<dynamic>;
    return raw
        .map((e) => Listing.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> add(
    Listing listing, {
    String? basePath,
    String projectId = '',
  }) async {
    final listings = await load(basePath: basePath, projectId: projectId);
    listings.add(listing);
    await save(listings, basePath: basePath, projectId: projectId);
  }

  static Future<void> deleteById(
    String id, {
    String? basePath,
    String projectId = '',
  }) async {
    final listings = await load(basePath: basePath, projectId: projectId);
    listings.removeWhere((l) => l.id == id);
    await save(listings, basePath: basePath, projectId: projectId);
  }

  static Future<void> update(
    Listing listing, {
    String? basePath,
    String projectId = '',
  }) async {
    final listings = await load(basePath: basePath, projectId: projectId);
    final idx = listings.indexWhere((l) => l.id == listing.id);
    if (idx >= 0) {
      listings[idx] = listing;
      await save(listings, basePath: basePath, projectId: projectId);
    }
  }

  /// Supprime le fichier de stockage entier (réservé aux tests).
  static Future<void> deleteFile({
    String? basePath,
    String projectId = '',
  }) async {
    final file = await _file(basePath: basePath, projectId: projectId);
    if (file.existsSync()) await file.delete();
  }
}
