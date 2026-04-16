import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/profile.dart';

/// Persiste le [UserProfile] local dans un fichier JSON sur l'appareil.
///
/// Le paramètre [basePath] est réservé aux tests : il permet d'injecter
/// un répertoire temporaire sans dépendance à la plateforme.
class ProfileStorageService {
  ProfileStorageService._();

  static const _filename = 'profile.json';

  static Future<File> _file({String? basePath}) async {
    final dir = basePath != null
        ? Directory(basePath)
        : await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_filename');
  }

  static Future<void> save(UserProfile profile, {String? basePath}) async {
    final file = await _file(basePath: basePath);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(profile.toJson()),
    );
  }

  static Future<UserProfile?> load({String? basePath}) async {
    final file = await _file(basePath: basePath);
    if (!file.existsSync()) return null;
    final content = await file.readAsString();
    return UserProfile.fromJson(
      jsonDecode(content) as Map<String, dynamic>,
    );
  }

  static Future<void> delete({String? basePath}) async {
    final file = await _file(basePath: basePath);
    if (file.existsSync()) await file.delete();
  }
}
