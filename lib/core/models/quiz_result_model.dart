import 'question_model.dart';

class QuizResult {
  final String id;
  final String pdfName;
  final QuestionType questionType;
  final List<Question> questions;
  final DateTime takenAt;

  QuizResult({
    required this.id,
    required this.pdfName,
    required this.questionType,
    required this.questions,
    required this.takenAt,
  });

  int get totalQuestions => questions.length;

  int get correctCount => questions.where((q) => q.isCorrect).length;

  double get scorePercent =>
      totalQuestions == 0 ? 0 : (correctCount / totalQuestions) * 100;

  String get grade {
    if (scorePercent >= 90) return 'A+';
    if (scorePercent >= 80) return 'A';
    if (scorePercent >= 70) return 'B';
    if (scorePercent >= 60) return 'C';
    return 'F';
  }
}
