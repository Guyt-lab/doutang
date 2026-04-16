import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'profile.dart';
import 'listing.dart';
import 'visit.dart';

const _uuid = Uuid();

class DoutangProject {
  final String id;
  final String name;
  final ProjectType type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<UserProfile> profiles;
  final List<Listing> listings;
  final List<Visit> visits;

  static const String appVersion = '1.0';

  DoutangProject({
    String? id,
    required this.name,
    required this.type,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<UserProfile>? profiles,
    List<Listing>? listings,
    List<Visit>? visits,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        profiles = profiles ?? [],
        listings = listings ?? [],
        visits = visits ?? [];

  DoutangProject copyWith({
    String? name,
    ProjectType? type,
    DateTime? updatedAt,
    List<UserProfile>? profiles,
    List<Listing>? listings,
    List<Visit>? visits,
  }) {
    return DoutangProject(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      profiles: profiles ?? this.profiles,
      listings: listings ?? this.listings,
      visits: visits ?? this.visits,
    );
  }

  Map<String, dynamic> toJson() => {
        'version': appVersion,
        'app': 'doutang',
        'project': {
          'id': id,
          'name': name,
          'type': type.name,
          'created_at': createdAt.toIso8601String(),
          'updated_at': updatedAt.toIso8601String(),
        },
        'profiles': profiles.map((p) => p.toJson()).toList(),
        'listings': listings.map((l) => l.toJson()).toList(),
        'visits': visits.map((v) => v.toJson()).toList(),
      };

  factory DoutangProject.fromJson(Map<String, dynamic> json) {
    final projectData = json['project'] as Map<String, dynamic>;
    return DoutangProject(
      id: projectData['id'] as String,
      name: projectData['name'] as String,
      type: ProjectType.values.firstWhere(
        (t) => t.name == projectData['type'],
        orElse: () => ProjectType.location,
      ),
      createdAt: DateTime.parse(projectData['created_at'] as String),
      updatedAt: DateTime.parse(projectData['updated_at'] as String),
      profiles: (json['profiles'] as List<dynamic>)
          .map((p) => UserProfile.fromJson(p as Map<String, dynamic>))
          .toList(),
      listings: (json['listings'] as List<dynamic>)
          .map((l) => Listing.fromJson(l as Map<String, dynamic>))
          .toList(),
      visits: (json['visits'] as List<dynamic>)
          .map((v) => Visit.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  String toFileContent() => const JsonEncoder.withIndent('  ').convert(toJson());

  factory DoutangProject.fromFileContent(String content) =>
      DoutangProject.fromJson(jsonDecode(content) as Map<String, dynamic>);
}

enum ProjectType { location, achat }
