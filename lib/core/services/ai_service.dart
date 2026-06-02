import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/question_model.dart';
import '../constants/prompts.dart';

class AIService {
  final String _groqKey;
  final String _geminiKey;

  AIService()
    : _groqKey = dotenv.env['GROQ_API_KEY'] ?? '',
      _geminiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  // ─── Core: try Groq → fallback Gemini ───────────────────────────────────

  Future<String> _postPrompt(String prompt, double temperature) async {
    // 1. Try Groq
    if (_groqKey.isNotEmpty) {
      try {
        final res = await _callGroq(prompt, temperature);
        if (res != null) return res;
      } catch (_) {}
    }

    // 2. Fallback: Gemini
    if (_geminiKey.isNotEmpty) {
      try {
        final res = await _callGemini(prompt);
        if (res != null) return res;
      } catch (_) {}
    }

    throw Exception('All AI providers failed or rate limited.');
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

  Future<String?> _callGroq(String prompt, double temperature) async {
    final response = await http.post(
      Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_groqKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': AppConstants.groqModel,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'temperature': temperature,
      }),
    );

    if (response.statusCode == 429) return null; // rate limited → fallback
    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'] as String;
  }

  Future<String?> _callGemini(String prompt) async {
    final response = await http.post(
      Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/${AppConstants.geminiModel}:generateContent?key=$_geminiKey',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {'temperature': 0.7},
      }),
    );

    if (response.statusCode == 429) return null;
    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body);
    return data['candidates'][0]['content']['parts'][0]['text'] as String;
  }

  // ─── Public methods (unchanged logic) ───────────────────────────────────

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

    final rawText = await _postPrompt(prompt, 0.1);
    final jsonString = _extractJsonArray(rawText);

    final List<dynamic> results = jsonDecode(jsonString);
    return results.map((e) => e as bool).toList();
  }

  Future<List<Question>> generateQuestions(
    String pdfText,
    QuestionType type,
  ) async {
    final prompt = Prompts.generateQuiz(pdfText, type);
    final rawText = await _postPrompt(prompt, 0.7);
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
