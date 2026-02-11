enum RecommendationType {
  payNow,
  schedulePayday,
  remindLater,
}

class Recommendation {
  final RecommendationType type;
  final String rationale;
  final DateTime? suggestedDate;
  final double confidence;

  Recommendation({
    required this.type,
    required this.rationale,
    this.suggestedDate,
    required this.confidence,
  });

  String get displayText {
    switch (type) {
      case RecommendationType.payNow:
        return 'Pay Now';
      case RecommendationType.schedulePayday:
        return suggestedDate != null
            ? 'Schedule for ${_formatDate(suggestedDate!)}'
            : 'Schedule for Payday';
      case RecommendationType.remindLater:
        return suggestedDate != null
            ? 'Remind me on ${_formatDate(suggestedDate!)}'
            : 'Remind Later';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
