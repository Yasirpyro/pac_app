import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../database/dao/settings_dao.dart';

class AIService {
  final SettingsDao _settingsDao;
  static const int _timeoutSeconds = 10;

  AIService({required SettingsDao settingsDao}) : _settingsDao = settingsDao;

  Future<String> generateRationale({
    required String payee,
    required double amount,
    required String dueDate,
    required double currentBalance,
    required String nextPayday,
    required double safetyBuffer,
    required String recommendation,
    List<Map<String, dynamic>>? upcomingPayments,
  }) async {
    try {
      // Check if demo mode is enabled
      final settings = await _settingsDao.getSettings();
      if (settings.demoMode) {
        return _getCachedRationale(
          recommendation: recommendation,
          amount: amount,
          currentBalance: currentBalance,
          safetyBuffer: safetyBuffer,
        );
      }

      // In live mode, try to call Gemini API with timeout
      return await _callGeminiAPI(
        payee: payee,
        amount: amount,
        dueDate: dueDate,
        currentBalance: currentBalance,
        nextPayday: nextPayday,
        safetyBuffer: safetyBuffer,
        recommendation: recommendation,
        upcomingPayments: upcomingPayments,
      ).timeout(
        const Duration(seconds: _timeoutSeconds),
        onTimeout: () {
          // Fall back to cached response on timeout
          return _getCachedRationale(
            recommendation: recommendation,
            amount: amount,
            currentBalance: currentBalance,
            safetyBuffer: safetyBuffer,
          );
        },
      );
    } catch (e) {
      // Fall back to cached response on any error
      return _getCachedRationale(
        recommendation: recommendation,
        amount: amount,
        currentBalance: currentBalance,
        safetyBuffer: safetyBuffer,
      );
    }
  }

  Future<String> _callGeminiAPI({
    required String payee,
    required double amount,
    required String dueDate,
    required double currentBalance,
    required String nextPayday,
    required double safetyBuffer,
    required String recommendation,
    List<Map<String, dynamic>>? upcomingPayments,
  }) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    if (apiKey.isEmpty) {
      throw Exception('Gemini API key not found in .env');
    }

    // Using Gemini 1.5 Flash as requested (2.5 is not yet available)
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );

    final upcomingPaymentsStr = upcomingPayments != null && upcomingPayments.isNotEmpty
        ? upcomingPayments
            .map((p) => '${p['name']}: \$${p['amount']} on ${p['date']}')
            .join(', ')
        : 'None';

    final prompt = '''
You are a helpful financial assistant for a banking app. Generate a brief, friendly explanation (max 50 words) for why we recommend this payment timing.

Context:
- Bill: $payee \$$amount due $dueDate
- Current balance: \$$currentBalance
- Next payday: $nextPayday
- Safety buffer: \$$safetyBuffer
- Known upcoming: $upcomingPaymentsStr

Recommendation: $recommendation

Generate explanation focusing on the main factor (buffer, timing, upcoming obligations). Use simple language. Start with "Why?" or directly explain.

Example output:
"Paying now leaves only \$620 before your rent is due on Feb 16. Waiting until payday on Feb 19 keeps a healthy \$1,420 buffer."
''';

    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    return response.text?.trim() ?? _getCachedRationale(
      recommendation: recommendation,
      amount: amount,
      currentBalance: currentBalance,
      safetyBuffer: safetyBuffer,
    );
  }

  String _getCachedRationale({
    required String recommendation,
    required double amount,
    required double currentBalance,
    required double safetyBuffer,
  }) {
    final remainingBalance = currentBalance - amount - safetyBuffer;

    switch (recommendation) {
      case 'payNow':
        if (remainingBalance >= 500) {
          return 'Paying now is safe! Your balance comfortably covers this bill while maintaining your safety buffer of \$${safetyBuffer.toStringAsFixed(0)}.';
        } else {
          return 'You can pay now, but this will leave \$${remainingBalance.toStringAsFixed(0)} above your safety buffer. Consider your upcoming expenses.';
        }

      case 'schedulePayday':
        if (remainingBalance < 0) {
          return 'Waiting until payday is essential here. Paying now would put you below your safety buffer, risking overdraft fees.';
        } else {
          return 'Waiting until payday is smarter here. Paying now would leave you with less cushion for upcoming obligations.';
        }

      case 'remindLater':
        return 'This bill needs more review. Please check your cashflow and decide the best timing to pay.';

      default:
        return 'This timing helps maintain your safety buffer and avoids conflicts with other payments.';
    }
  }
}
