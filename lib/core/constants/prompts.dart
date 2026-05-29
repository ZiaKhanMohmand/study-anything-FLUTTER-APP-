import '../models/question_model.dart';
import 'app_constants.dart';

class Prompts {
  static String generateQuiz(String pdfText, QuestionType type) {
    final typeInstructions = switch (type) {
      QuestionType.mcq =>
        '''
Generate exactly ${AppConstants.mcqCount} multiple choice questions.
Return a JSON array where each object has:
- "question": the question text
- "options": array of exactly 4 options like ["A. option1", "B. option2", "C. option3", "D. option4"]
- "correct_answer": the full correct option e.g. "A. option1"
- "explanation": why this answer is correct
''',
      QuestionType.shortQuestion =>
        '''
Generate exactly ${AppConstants.shortQCount} short answer questions.
Return a JSON array where each object has:
- "question": the question text
- "correct_answer": a concise model answer (2-3 sentences)
- "explanation": key points the answer should cover
''',
      QuestionType.longQuestion =>
        '''
Generate exactly ${AppConstants.longQCount} long/essay questions.
Return a JSON array where each object has:
- "question": the question text
- "correct_answer": a detailed model answer (1-2 paragraphs)
- "explanation": the main concepts and points that should be covered
''',
      QuestionType.conceptual =>
        '''
Generate exactly ${AppConstants.conceptualQCount} conceptual understanding questions (Why/How/Explain type).
Return a JSON array where each object has:
- "question": the conceptual question
- "correct_answer": the conceptual explanation
- "explanation": the underlying principle or concept being tested
''',
    };

    return '''
You are an expert exam question generator.
Analyze the following study material and generate questions strictly based on it.

$typeInstructions

IMPORTANT RULES:
- Return ONLY a valid JSON array. No markdown, no backticks, no extra text.
- Base ALL questions strictly on the provided content.
- Make questions educational and meaningful.

STUDY MATERIAL:
$pdfText
''';
  }
}
