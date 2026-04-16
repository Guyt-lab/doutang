import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class Visit {
  final String id;
  final String listingId;
  final String owner;
  final DateTime visitedAt;
  final VisitAnswers answers;
  final int feeling;
  final double score;
  final List<String> photos;
  final DateTime updatedAt;

  Visit({
    String? id,
    required this.listingId,
    required this.owner,
    DateTime? visitedAt,
    VisitAnswers? answers,
    int? feeling,
    double? score,
    List<String>? photos,
    DateTime? updatedAt,
  })  : id = id ?? _uuid.v4(),
        visitedAt = visitedAt ?? DateTime.now(),
        answers = answers ?? VisitAnswers(),
        feeling = feeling ?? 3,
        score = score ?? 0.0,
        photos = photos ?? [],
        updatedAt = updatedAt ?? DateTime.now();

  Visit copyWith({
    VisitAnswers? answers,
    int? feeling,
    double? score,
    List<String>? photos,
  }) {
    return Visit(
      id: id,
      listingId: listingId,
      owner: owner,
      visitedAt: visitedAt,
      answers: answers ?? this.answers,
      feeling: feeling ?? this.feeling,
      score: score ?? this.score,
      photos: photos ?? this.photos,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'listing_id': listingId,
        'owner': owner,
        'visited_at': visitedAt.toIso8601String(),
        'answers': answers.toJson(),
        'feeling': feeling,
        'score': score,
        'photos': photos,
        'updated_at': updatedAt.toIso8601String(),
      };

  factory Visit.fromJson(Map<String, dynamic> json) => Visit(
        id: json['id'] as String,
        listingId: json['listing_id'] as String,
        owner: json['owner'] as String,
        visitedAt: DateTime.parse(json['visited_at'] as String),
        answers: VisitAnswers.fromJson(
            json['answers'] as Map<String, dynamic>),
        feeling: (json['feeling'] as num).toInt(),
        score: (json['score'] as num).toDouble(),
        photos: List<String>.from(json['photos'] as List? ?? []),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
}

class VisitAnswers {
  // Critères notés de 1 à 5
  final int? luminosite;
  final int? calme;
  final int? etatGeneral;
  final int? cuisine;
  final int? salleDeBain;
  final int? rangements;
  final int? chauffage;
  final int? quartier;

  // Critères booléens
  final bool? doubleVitrage;
  final bool? gardien;
  final bool? cave;
  final bool? balconOuTerrasse;
  final bool? ascenseur;
  final bool? digicode;

  // Texte libre
  final String? coupDeCoeur;
  final String? pointRedhibitoire;

  VisitAnswers({
    this.luminosite,
    this.calme,
    this.etatGeneral,
    this.cuisine,
    this.salleDeBain,
    this.rangements,
    this.chauffage,
    this.quartier,
    this.doubleVitrage,
    this.gardien,
    this.cave,
    this.balconOuTerrasse,
    this.ascenseur,
    this.digicode,
    this.coupDeCoeur,
    this.pointRedhibitoire,
  });

  Map<String, int?> get ratedAnswers => {
        'luminosite': luminosite,
        'calme': calme,
        'etat_general': etatGeneral,
        'cuisine': cuisine,
        'salle_de_bain': salleDeBain,
        'rangements': rangements,
        'chauffage': chauffage,
        'quartier': quartier,
      };

  Map<String, dynamic> toJson() => {
        'luminosite': luminosite,
        'calme': calme,
        'etat_general': etatGeneral,
        'cuisine': cuisine,
        'salle_de_bain': salleDeBain,
        'rangements': rangements,
        'chauffage': chauffage,
        'quartier': quartier,
        'double_vitrage': doubleVitrage,
        'gardien': gardien,
        'cave': cave,
        'balcon_ou_terrasse': balconOuTerrasse,
        'ascenseur': ascenseur,
        'digicode': digicode,
        'coup_de_coeur': coupDeCoeur,
        'point_redhibitoire': pointRedhibitoire,
      };

  factory VisitAnswers.fromJson(Map<String, dynamic> json) => VisitAnswers(
        luminosite: (json['luminosite'] as num?)?.toInt(),
        calme: (json['calme'] as num?)?.toInt(),
        etatGeneral: (json['etat_general'] as num?)?.toInt(),
        cuisine: (json['cuisine'] as num?)?.toInt(),
        salleDeBain: (json['salle_de_bain'] as num?)?.toInt(),
        rangements: (json['rangements'] as num?)?.toInt(),
        chauffage: (json['chauffage'] as num?)?.toInt(),
        quartier: (json['quartier'] as num?)?.toInt(),
        doubleVitrage: json['double_vitrage'] as bool?,
        gardien: json['gardien'] as bool?,
        cave: json['cave'] as bool?,
        balconOuTerrasse: json['balcon_ou_terrasse'] as bool?,
        ascenseur: json['ascenseur'] as bool?,
        digicode: json['digicode'] as bool?,
        coupDeCoeur: json['coup_de_coeur'] as String?,
        pointRedhibitoire: json['point_redhibitoire'] as String?,
      );
}
