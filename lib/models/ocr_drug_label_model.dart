class OCRDrugLabelModel {
  final String message;
  final List<String> ids;
  final Map<String, double> score;

  OCRDrugLabelModel({
    required this.message,
    required this.ids,
    required this.score,
  });

  // Factory constructor to create an OcrResult from a JSON map
  factory OCRDrugLabelModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final List<String> parsedIds = List<String>.from(data['ids']);

    final Map<String, double> parsedScore = {};
    if (data['score'] != null) {
      (data['score'] as Map<String, dynamic>).forEach((key, value) {
        parsedScore[key] = (value as num).toDouble(); // Convert to double
      });
    }

    return OCRDrugLabelModel(
      message: json['message'] as String,
      ids: parsedIds,
      score: parsedScore,
    );
  }
}
