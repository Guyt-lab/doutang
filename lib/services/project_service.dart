import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/enums.dart';
import '../models/project.dart';

const _uuid = Uuid();

/// Métadonnées légères d'un projet (index, sans données embarquées).
class ProjectMeta {
  final String id;
  final String name;
  final ProjectType type;
  final PropertyType propertyType;
  final int color;
  final DateTime createdAt;

  const ProjectMeta({
    required this.id,
    required this.name,
    required this.type,
    required this.propertyType,
    required this.color,
    required this.createdAt,
  });

  factory ProjectMeta.create({
    required String name,
    required ProjectType type,
    required PropertyType propertyType,
    required int color,
  }) =>
      ProjectMeta(
        id: _uuid.v4(),
        name: name,
        type: type,
        propertyType: propertyType,
        color: color,
        createdAt: DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'propertyType': propertyType.name,
        'color': color,
        'created_at': createdAt.toIso8601String(),
      };

  factory ProjectMeta.fromJson(Map<String, dynamic> json) => ProjectMeta(
        id: json['id'] as String,
        name: json['name'] as String,
        type: ProjectType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => ProjectType.location,
        ),
        propertyType: PropertyType.values.firstWhere(
          (t) => t.name == (json['propertyType'] as String? ?? 'appartement'),
          orElse: () => PropertyType.appartement,
        ),
        color: json['color'] as int? ?? 0xFF2D6A4F,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

/// Gère la liste des projets et le projet actif (persiste dans documents dir).
class ProjectService {
  ProjectService._();

  static const _projectsFilename = 'projects.json';
  static const _activeIdFilename = 'active_project_id.json';

  static Future<File> _projectsFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_projectsFilename');
  }

  static Future<File> _activeIdFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_activeIdFilename');
  }

  static Future<List<ProjectMeta>> loadAll() async {
    final file = await _projectsFile();
    if (!file.existsSync()) return [];
    final raw = jsonDecode(await file.readAsString()) as List<dynamic>;
    return raw
        .map((e) => ProjectMeta.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveAll(List<ProjectMeta> projects) async {
    final file = await _projectsFile();
    await file.writeAsString(
      const JsonEncoder.withIndent('  ')
          .convert(projects.map((p) => p.toJson()).toList()),
    );
  }

  static Future<String?> getActiveId() async {
    final file = await _activeIdFile();
    if (!file.existsSync()) return null;
    final content = (await file.readAsString()).trim();
    return content.isEmpty ? null : content;
  }

  static Future<void> setActive(String id) async {
    final file = await _activeIdFile();
    await file.writeAsString(id);
  }

  static Future<ProjectMeta?> getActive() async {
    final id = await getActiveId();
    if (id == null) return null;
    final projects = await loadAll();
    try {
      return projects.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  static Future<ProjectMeta> create({
    required String name,
    required ProjectType type,
    required PropertyType propertyType,
    required int color,
  }) async {
    final project = ProjectMeta.create(
      name: name,
      type: type,
      propertyType: propertyType,
      color: color,
    );
    final projects = await loadAll();
    projects.add(project);
    await saveAll(projects);
    return project;
  }

  static Future<void> delete(String id) async {
    final projects = await loadAll();
    projects.removeWhere((p) => p.id == id);
    await saveAll(projects);
    final activeId = await getActiveId();
    if (activeId == id) {
      final file = await _activeIdFile();
      await file.writeAsString('');
    }
  }
}
