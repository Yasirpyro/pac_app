import '../../domain/entities/recommendation.dart';
import '../models/bill_model.dart';
import '../models/cashflow_input_model.dart';

class RecommendationService {
  Recommendation getRecommendation({
    required BillModel bill,
    required CashflowInputModel cashflow,
  }) {
    final now = DateTime.now();
    final daysUntilDue = bill.dueDate.difference(now).inDays;
    final balanceAfterPayment = cashflow.currentBalance - bill.amount;
    final remainingAfterBuffer = balanceAfterPayment - cashflow.safetyBuffer;

    // Calculate recommendation type based on rules from PRD
    final type = _calculateRecommendationType(
      daysUntilDue: daysUntilDue,
      remainingAfterBuffer: remainingAfterBuffer,
      payday: cashflow.nextPaydayDate,
      dueDate: bill.dueDate,
    );

    // Calculate confidence
    final confidence = _calculateConfidence(
      cashflow: cashflow,
      bill: bill,
    );

    // Get suggested date
    final suggestedDate = _getSuggestedDate(type, cashflow.nextPaydayDate);

    // Build rationale
    final rationale = _buildRationale(
      type: type,
      bill: bill,
      cashflow: cashflow,
      daysUntilDue: daysUntilDue,
      remainingAfterBuffer: remainingAfterBuffer,
    );

    return Recommendation(
      type: type,
      rationale: rationale,
      suggestedDate: suggestedDate,
      confidence: confidence,
    );
  }

  RecommendationType _calculateRecommendationType({
    required int daysUntilDue,
    required double remainingAfterBuffer,
    required DateTime payday,
    required DateTime dueDate,
  }) {
    // Rule 1: Pay Now
    // Conditions: daysUntilDue <= 7 AND remainingAfterBuffer >= safetyBuffer (500)
    if (daysUntilDue <= 7 && remainingAfterBuffer >= 500) {
      return RecommendationType.payNow;
    }

    // Rule 2: Schedule Payday
    // Conditions: daysUntilDue <= 7 AND remainingAfterBuffer < safetyBuffer AND payday < dueDate
    if (daysUntilDue <= 7 &&
        remainingAfterBuffer < 500 &&
        (payday.isBefore(dueDate) || payday.isAtSameMomentAs(dueDate))) {
      return RecommendationType.schedulePayday;
    }

    // Rule 3: Remind Later (fallback)
    // Conditions: daysUntilDue > 7 or insufficient data
    return RecommendationType.remindLater;
  }

  double _calculateConfidence({
    required CashflowInputModel cashflow,
    required BillModel bill,
  }) {
    double confidence = 0.5;

    if (cashflow.currentBalance > 0) confidence += 0.2;
    if (cashflow.safetyBuffer > 0) confidence += 0.15;
    if (bill.amount > 0) confidence += 0.15;

    return confidence.clamp(0.0, 1.0);
  }

  DateTime? _getSuggestedDate(
    RecommendationType type,
    DateTime payday,
  ) {
    switch (type) {
      case RecommendationType.payNow:
        return DateTime.now();
      case RecommendationType.schedulePayday:
        return payday;
      case RecommendationType.remindLater:
        return DateTime.now().add(const Duration(days: 2));
    }
  }

  String _buildRationale({
    required RecommendationType type,
    required BillModel bill,
    required CashflowInputModel cashflow,
    required int daysUntilDue,
    required double remainingAfterBuffer,
  }) {
    switch (type) {
      case RecommendationType.payNow:
        if (remainingAfterBuffer >= 1000) {
          return 'Paying now is safe! Your balance comfortably covers this bill while maintaining your safety buffer of \$${cashflow.safetyBuffer.toStringAsFixed(0)}.';
        } else {
          return 'You can pay now, but this will leave \$${remainingAfterBuffer.toStringAsFixed(0)} above your safety buffer. Consider your upcoming expenses.';
        }

      case RecommendationType.schedulePayday:
        final paydayStr = _formatDate(cashflow.nextPaydayDate);
        return 'Waiting until payday ($paydayStr) is smarter here. Paying now would leave you with less cushion (\$${remainingAfterBuffer.toStringAsFixed(0)} above buffer) for upcoming obligations.';

      case RecommendationType.remindLater:
        if (daysUntilDue > 7) {
          return 'This bill is due in $daysUntilDue days. We\'ll remind you closer to the due date for better timing.';
        } else {
          return 'This bill needs attention soon. Please review your cashflow and decide the best timing to pay.';
        }
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}
