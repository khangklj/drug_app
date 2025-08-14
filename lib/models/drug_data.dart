class DrugData {
  final String id;
  final String displayName;
  final String? displayTag;
  final String _image;
  final String indications;
  final String pharmacodynamics;
  final String pharmacokinetics;
  final String dosage;
  final String adverseEffects;
  final String contraindications;
  final String generalWarnings;
  final String pregnacyWarnings;
  final String breastfeedingWarnings;
  final String drivingWarnings;
  final String interactions;
  final String preservation;

  DrugData({
    required this.id,
    required this.displayName,
    this.displayTag,
    required String image,
    required this.indications,
    required this.pharmacodynamics,
    required this.pharmacokinetics,
    required this.dosage,
    required this.adverseEffects,
    required this.contraindications,
    required this.generalWarnings,
    required this.pregnacyWarnings,
    required this.breastfeedingWarnings,
    required this.drivingWarnings,
    required this.interactions,
    required this.preservation,
  }) : _image = image;

  DrugData copyWith({
    String? id,
    String? displayName,
    String? displayTag,
    String? image,
    String? indications,
    String? pharmacodynamics,
    String? pharmacokinetics,
    String? dosage,
    String? adverseEffects,
    String? contraindications,
    String? generalWarnings,
    String? pregnacyWarnings,
    String? breastfeedingWarnings,
    String? drivingWarnings,
    String? interactions,
    String? preservation,
  }) {
    return DrugData(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      displayTag: displayTag ?? this.displayTag,
      image: image ?? _image,
      indications: indications ?? this.indications,
      pharmacodynamics: pharmacodynamics ?? this.pharmacodynamics,
      pharmacokinetics: pharmacokinetics ?? this.pharmacokinetics,
      dosage: dosage ?? this.dosage,
      adverseEffects: adverseEffects ?? this.adverseEffects,
      contraindications: contraindications ?? this.contraindications,
      generalWarnings: generalWarnings ?? this.generalWarnings,
      pregnacyWarnings: pregnacyWarnings ?? this.pregnacyWarnings,
      breastfeedingWarnings:
          breastfeedingWarnings ?? this.breastfeedingWarnings,
      drivingWarnings: drivingWarnings ?? this.drivingWarnings,
      interactions: interactions ?? this.interactions,
      preservation: preservation ?? this.preservation,
    );
  }

  factory DrugData.fromJson(Map<String, dynamic> json) {
    return DrugData(
      id: json['id'],
      displayName: json['display_name'],
      displayTag: json['display_tag'],
      image: json['image'],
      indications: json['indications'],
      pharmacodynamics: json['pharmacodynamics'],
      pharmacokinetics: json['pharmacokinetics'],
      dosage: json['dosage'],
      adverseEffects: json['adverse_effects'],
      contraindications: json['contraindications'],
      generalWarnings: json['general_warnings'],
      pregnacyWarnings: json['pregnacy_warnings'],
      breastfeedingWarnings: json['breastfeeding_warnings'],
      drivingWarnings: json['driving_warnings'],
      interactions: json['interactions'],
      preservation: json['preservation'],
    );
  }

  String getImage({String? thumb}) {
    if (thumb == null) return _image;
    if (_image.contains('?thumb')) {
      return '$_image&thumb=$thumb';
    } else {
      return '$_image?thumb=$thumb';
    }
  }
}
