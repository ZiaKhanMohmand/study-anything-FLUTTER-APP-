import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/question_model.dart';
import '../constants/prompts.dart';

class GroqService {
  final String _apiKey;

  GroqService() : _apiKey = dotenv.env['GROQ_API_KEY'] ?? '' {
    if (_apiKey.isEmpty) {
      throw Exception('GROQ_API_KEY not found in .env file');
    }
  }

  Future<String> _postPrompt(String prompt, double temperature) async {
    final response = await http.post(
      Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
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

    if (response.statusCode != 200) {
      throw Exception('Groq API error: ${response.body}');
    }

    return response.body;
  }

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

    final responseBody = await _postPrompt(prompt, 0.1);
    final data = jsonDecode(responseBody);
    final rawText = data['choices'][0]['message']['content'] as String;

    String cleaned = rawText
        .trim()
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    final startIndex = cleaned.indexOf('[');
    final endIndex = cleaned.lastIndexOf(']');
    final jsonString = cleaned.substring(startIndex, endIndex + 1);

    final List<dynamic> results = jsonDecode(jsonString);
    return results.map((e) => e as bool).toList();
  }

  Future<List<Question>> generateQuestions(
    String pdfText,
    QuestionType type,
  ) async {
    final prompt = Prompts.generateQuiz(pdfText, type);

    final responseBody = await _postPrompt(prompt, 0.7);
    final data = jsonDecode(responseBody);
    final rawText = data['choices'][0]['message']['content'] as String;

    String cleaned = rawText.trim();
    cleaned = cleaned
        .replaceAll('```json', '')
        .replaceAll('```JSON', '')
        .replaceAll('```', '')
        .trim();

    final startIndex = cleaned.indexOf('[');
    final endIndex = cleaned.lastIndexOf(']');

    if (startIndex == -1 || endIndex == -1) {
      throw Exception(
        'Could not find JSON array in response.\nRaw: ${cleaned.substring(0, cleaned.length.clamp(0, 200))}',
      );
    }

    final jsonString = cleaned.substring(startIndex, endIndex + 1);

    List<dynamic> jsonList;
    try {
      jsonList = jsonDecode(jsonString);
    } catch (e) {
      throw Exception(
        'Failed to parse JSON: $e\nRaw: ${jsonString.substring(0, jsonString.length.clamp(0, 200))}',
      );
    }

    if (jsonList.isEmpty) {
      throw Exception('Groq returned an empty question list.');
    }

    return jsonList
        .map((item) => Question.fromJson(item as Map<String, dynamic>, type))
        .toList();
  }
}
