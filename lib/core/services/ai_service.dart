import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/question_model.dart';
import '../constants/prompts.dart';

class AIService {
  final String _groqKey;
  final String _cerebrasKey;

  AIService()
    : _groqKey = dotenv.env['GROQ_API_KEY'] ?? '',
      _cerebrasKey = dotenv.env['CEREBRAS_API_KEY'] ?? '';

  // ─── Core: Groq → Cerebras fallback ─────────────────────────────────────

  Future<String> _postPrompt(
    String prompt,
    double temperature, {
    required String requestLabel,
  }) async {
    debugPrint('[AI][$requestLabel] Starting request');

    // 1. Try Groq
    if (_groqKey.isNotEmpty) {
      try {
        debugPrint('[AI][$requestLabel] Trying Groq');
        final res = await _callOpenAICompatible(
          url: 'https://api.groq.com/openai/v1/chat/completions',
          model: AppConstants.groqModel,
          key: _groqKey,
          prompt: prompt,
          temperature: temperature,
          label: 'Groq',
        );
        if (res != null) {
          debugPrint('[AI][$requestLabel] Groq succeeded');
          return res;
        }
        debugPrint('[AI][$requestLabel] Groq returned no usable response');
      } catch (e) {
        debugPrint('[AI][$requestLabel] Groq threw: $e');
      }
    }

    // 2. Fallback: Cerebras
    if (_cerebrasKey.isNotEmpty) {
      try {
        debugPrint('[AI][$requestLabel] Trying Cerebras');
        final res = await _callOpenAICompatible(
          url: 'https://api.cerebras.ai/v1/chat/completions',
          model: AppConstants.cerebrasModel,
          key: _cerebrasKey,
          prompt: prompt,
          temperature: temperature,
          label: 'Cerebras',
        );
        if (res != null) {
          debugPrint('[AI][$requestLabel] Cerebras succeeded');
          return res;
        }
        debugPrint('[AI][$requestLabel] Cerebras returned no usable response');
      } catch (e) {
        debugPrint('[AI][$requestLabel] Cerebras threw: $e');
      }
    }

    debugPrint('[AI][$requestLabel] All providers failed or were rate limited');
    throw Exception('All AI providers failed or rate limited.');
  }

  // ─── Shared OpenAI-compatible caller (Groq + Cerebras same format) ───────

  Future<String?> _callOpenAICompatible({
    required String url,
    required String model,
    required String key,
    required String prompt,
    required double temperature,
    required String label,
  }) async {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $key',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': model,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'temperature': temperature,
      }),
    );

    debugPrint(
      '[AI][$label] HTTP ${response.statusCode}: ${_shortBody(response.body)}',
    );

    if (response.statusCode == 429) return null;
    if (response.statusCode != 200) return null;

    try {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] as String;
    } catch (e) {
      debugPrint('[AI][$label] Parse failed: $e');
      return null;
    }
  }

  String _extractJsonArray(String responseText) {
    final cleaned = responseText
        .trim()
        .replaceAll('```json', '')
        .replaceAll('```JSON', '')
        .replaceAll('```', '')
        .trim();

    final startIndex = cleaned.indexOf('[');
    final endIndex = cleaned.lastIndexOf(']');

    if (startIndex == -1 || endIndex == -1 || endIndex < startIndex) {
      throw Exception('Could not find JSON array in response.');
    }

    return cleaned.substring(startIndex, endIndex + 1);
  }

  String _shortBody(String body) {
    final compact = body.replaceAll('\n', ' ').trim();
    if (compact.length <= 300) return compact;
    return '${compact.substring(0, 300)}...';
  }

  // ─── Public methods ───────────────────────────────────────────────────────

  Future<List<bool>> evaluateAnswers(List<Question> questions) async {
    final questionsJson = questions
        .map(
          (q) => {
            'question': q.question,
            'user_answer': q.userAnswer ?? '',
            'correct_answer': q.correctAnswer,
            'type': q.type.name,
          },
        )
        .toList();

    final prompt =
        '''
You are an expert teacher evaluating student answers.

For each question below, evaluate if the student's answer is correct or acceptable.
- For MCQ: check if it matches the correct answer
- For short/long/conceptual: check if the student's answer conveys the correct meaning, even if worded differently

Return ONLY a JSON array of booleans (true/false), one per question, in the same order.
Example: [true, false, true, true, false]

Questions:
${jsonEncode(questionsJson)}
''';

    final rawText = await _postPrompt(
      prompt,
      0.1,
      requestLabel: 'evaluateAnswers',
    );
    final jsonString = _extractJsonArray(rawText);
    final List<dynamic> results = jsonDecode(jsonString);
    return results.map((e) => e as bool).toList();
  }

  Future<List<Question>> generateQuestions(
    String pdfText,
    QuestionType type,
  ) async {
    final prompt = Prompts.generateQuiz(pdfText, type);
    final rawText = await _postPrompt(
      prompt,
      0.7,
      requestLabel: 'generateQuestions:${type.name}',
    );
    final jsonString = _extractJsonArray(rawText);

    List<dynamic> jsonList;
    try {
      jsonList = jsonDecode(jsonString);
    } catch (e) {
      throw Exception('Failed to parse JSON: $e');
    }

    if (jsonList.isEmpty) throw Exception('AI returned empty question list.');

    return jsonList
        .map((item) => Question.fromJson(item as Map<String, dynamic>, type))
        .toList();
  }
}
