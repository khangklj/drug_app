class OcrResult {
  final String message;
  final List<String> ids;
  final Map<String, double> score;

  OcrResult({required this.message, required this.ids, required this.score});

  // Factory constructor to create an OcrResult from a JSON map
  factory OcrResult.fromJson(Map<String, dynamic> json) {
    final List<String> parsedIds = List<String>.from(json['ids']);

    final Map<String, double> parsedScore = {};
    if (json['score'] != null) {
      (json['score'] as Map<String, dynamic>).forEach((key, value) {
        parsedScore[key] = (value as num).toDouble(); // Convert to double
      });
    }

    return OcrResult(
      message: json['message'] as String,
      ids: parsedIds,
      score: parsedScore,
    );
  }
}
