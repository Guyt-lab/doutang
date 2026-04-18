import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/listing.dart';
import '../models/visit.dart';
import 'listing_storage_service.dart';

class VisitStorageService {
  VisitStorageService._();

  static const _defaultFilename = 'visits.json';

  static String _filename(String projectId) =>
      projectId.isEmpty ? _defaultFilename : '${projectId}_visits.json';

  static Future<File> _file({String? basePath, String projectId = ''}) async {
    final dir = basePath != null
        ? Directory(basePath)
        : await getApplicationDocumentsDirectory();
    return File('${dir.path}/${_filename(projectId)}');
  }

  static Future<void> save(
    List<Visit> visits, {
    String? basePath,
    String projectId = '',
  }) async {
    final file = await _file(basePath: basePath, projectId: projectId);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ')
          .convert(visits.map((v) => v.toJson()).toList()),
    );
  }

  static Future<List<Visit>> load({
    String? basePath,
    String projectId = '',
  }) async {
    final file = await _file(basePath: basePath, projectId: projectId);
    if (!file.existsSync()) return [];
    final content = await file.readAsString();
    final raw = jsonDecode(content) as List<dynamic>;
    return raw
        .map((e) => Visit.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Ajoute ou remplace la visite pour le couple (listingId, owner).
  static Future<void> add(
    Visit visit, {
    String? basePath,
    String projectId = '',
  }) async {
    final visits = await load(basePath: basePath, projectId: projectId);
    final idx = visits.indexWhere(
      (v) => v.listingId == visit.listingId && v.owner == visit.owner,
    );
    if (idx >= 0) {
      visits[idx] = visit;
    } else {
      visits.add(visit);
    }
    await save(visits, basePath: basePath, projectId: projectId);
    await _markListingAsVisited(
      visit.listingId,
      basePath: basePath,
      projectId: projectId,
    );
  }

  static Future<void> _markListingAsVisited(
    String listingId, {
    String? basePath,
    String projectId = '',
  }) async {
    final listings = await ListingStorageService.load(
      basePath: basePath,
      projectId: projectId,
    );
    final idx = listings.indexWhere((l) => l.id == listingId);
    if (idx >= 0 && listings[idx].status != ListingStatus.visitee) {
      listings[idx] = listings[idx].copyWith(status: ListingStatus.visitee);
      await ListingStorageService.save(
        listings,
        basePath: basePath,
        projectId: projectId,
      );
    }
  }

  static Future<void> delete(
    String id, {
    String? basePath,
    String projectId = '',
  }) async {
    final visits = await load(basePath: basePath, projectId: projectId);
    visits.removeWhere((v) => v.id == id);
    await save(visits, basePath: basePath, projectId: projectId);
  }

  static Future<void> deleteForListing(
    String listingId, {
    String? basePath,
    String projectId = '',
  }) async {
    final visits = await load(basePath: basePath, projectId: projectId);
    visits.removeWhere((v) => v.listingId == listingId);
    await save(visits, basePath: basePath, projectId: projectId);
  }
}
