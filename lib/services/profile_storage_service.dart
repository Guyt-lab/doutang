import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/profile.dart';

class ProfileStorageService {
  ProfileStorageService._();

  static const _defaultFilename = 'profile.json';

  static String _filename(String projectId) =>
      projectId.isEmpty ? _defaultFilename : '${projectId}_profile.json';

  static Future<File> _file({String? basePath, String projectId = ''}) async {
    final dir = basePath != null
        ? Directory(basePath)
        : await getApplicationDocumentsDirectory();
    return File('${dir.path}/${_filename(projectId)}');
  }

  static Future<void> save(
    UserProfile profile, {
    String? basePath,
    String projectId = '',
  }) async {
    final file = await _file(basePath: basePath, projectId: projectId);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(profile.toJson()),
    );
  }

  static Future<UserProfile?> load({
    String? basePath,
    String projectId = '',
  }) async {
    final file = await _file(basePath: basePath, projectId: projectId);
    if (!file.existsSync()) return null;
    final content = await file.readAsString();
    return UserProfile.fromJson(
      jsonDecode(content) as Map<String, dynamic>,
    );
  }

  static Future<void> delete({
    String? basePath,
    String projectId = '',
  }) async {
    final file = await _file(basePath: basePath, projectId: projectId);
    if (file.existsSync()) await file.delete();
  }
}
